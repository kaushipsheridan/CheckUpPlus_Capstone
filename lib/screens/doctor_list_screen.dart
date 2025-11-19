import 'package:flutter/material.dart';
import '../models/doctor_model.dart'; // Import the data models
import 'booking_calendar_screen.dart'; // Import the new booking screen
import '../models/appointment_model.dart'; // Import for the Appointment class

class DoctorListScreen extends StatelessWidget {
  final String category;

  const DoctorListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final doctors = getDoctorsForCategory(category);

    return Scaffold(
      appBar: AppBar(title: Text('$category Specialists')),
      body: doctors.isEmpty
          ? Center(
              child: Text(
                'No $category specialists found nearby.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                // Pass the doctor to the updated card
                return DoctorCard(
                  doctor: doctors[index],
                  // Handle the result when this card's flow finishes
                  onAppointmentBooked: (newAppointment) {
                    // When the calendar screen pops, it gives us the appointment.
                    // We pop *this* screen and pass the appointment back to
                    // CategorySpecialistsScreen.
                    Navigator.of(context).pop(newAppointment);
                  },
                );
              },
            ),
    );
  }
}

/// A custom card widget to display a single doctor's details
class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  // New: Callback to pass the booked appointment back up
  final ValueChanged<Appointment> onAppointmentBooked;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onAppointmentBooked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar/Icon placeholder
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 15),
            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specialty,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    doctor.clinicName,
                    style: const TextStyle(
                        fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('${doctor.rating.toStringAsFixed(1)} Rating'),
                      const SizedBox(width: 15),
                      Icon(Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18),
                      const SizedBox(width: 4),
                      Text('${doctor.distanceKm} km away'),
                    ],
                  ),
                  if (doctor.isUrgentCare)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'Urgent Care Available',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                // *** UPDATED onPressed ***
                onPressed: () async {
                  // Make it async
                  // 1. Push the calendar screen and wait for a result
                  final newAppointment = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingCalendarScreen(doctor: doctor),
                    ),
                  );

                  // 2. Check if we got a valid appointment back
                  if (newAppointment != null &&
                      newAppointment is Appointment) {
                    // 3. If yes, call the callback to pass it up to the list screen
                    onAppointmentBooked(newAppointment);
                  }
                },
                child: const Text('Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
