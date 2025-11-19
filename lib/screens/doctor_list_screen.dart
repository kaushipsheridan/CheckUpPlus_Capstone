import 'package:flutter/material.dart';
import 'package:checkupplus_capstone/models/doctor_model.dart';
import 'package:checkupplus_capstone/services/doctor_service.dart';
import 'booking_calendar_screen.dart';

class DoctorListScreen extends StatefulWidget {
  final String category;

  const DoctorListScreen({super.key, required this.category});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final DoctorService _doctorService = DoctorService();
  List<DoctorModel> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  /// Load doctors from Firestore based on specialty
  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    
    try {
      final doctors = await _doctorService.getDoctorsBySpecialty(widget.category);
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading doctors: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading doctors: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.category} Specialists')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctors.isEmpty
              ? Center(
                  child: Text(
                    'No ${widget.category} specialists found.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _doctors.length,
                  itemBuilder: (context, index) {
                    return DoctorCard(
                      doctor: _doctors[index],
                      onAppointmentBooked: (appointmentId) {
                        // Pop back with the appointment ID
                        Navigator.of(context).pop(appointmentId);
                      },
                    );
                  },
                ),
    );
  }
}

/// Updated DoctorCard to work with DoctorModel
class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final ValueChanged<String> onAppointmentBooked;

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
                  if (doctor.clinicName != null)
                    Text(
                      doctor.clinicName!,
                      style: const TextStyle(
                          fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (doctor.rating != null) ...[
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text('${doctor.rating!.toStringAsFixed(1)} Rating'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to booking screen
                  final appointmentId = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          BookingCalendarScreen(doctor: doctor),
                    ),
                  );

                  // If appointment was created, pass the ID back
                  if (appointmentId != null && appointmentId is String) {
                    onAppointmentBooked(appointmentId);
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