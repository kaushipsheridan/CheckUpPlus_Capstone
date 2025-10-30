import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'doctor_model.dart'; // For the Doctor object
import '../authentication/appointment_model.dart'; // For the Appointment object

/// A screen for selecting a date and time to book an appointment with a specific doctor.
class BookingCalendarScreen extends StatefulWidget {
  final Doctor doctor;

  const BookingCalendarScreen({super.key, required this.doctor});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // --- Mock Data for the Calendar ---

  // Generate the next 7 days for selection
  final List<DateTime> _upcomingDates = List.generate(7, (index) {
    return DateTime.now().add(Duration(days: index));
  });

  // Make some days unavailable (e.g., Sunday)
  final Set<int> _unavailableWeekdays = {DateTime.sunday};

  // Mock available time slots for any given *available* day
  // In a real app, this would come from an API based on the date
  final List<TimeOfDay> _availableTimeSlots = [
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 9, minute: 30),
    const TimeOfDay(hour: 10, minute: 30),
    const TimeOfDay(hour: 11, minute: 0),
    const TimeOfDay(hour: 14, minute: 0),
    const TimeOfDay(hour: 14, minute: 30),
    const TimeOfDay(hour: 15, minute: 30),
  ];

  // --- End Mock Data ---

  /// Called when the "Confirm Appointment" button is pressed.
  void _confirmBooking() {
    if (_selectedDate == null || _selectedTime == null) return;

    // 1. Create a new Appointment object
    final newAppointment = Appointment(
      // Create a unique ID (simple way for mock data)
      id: 'A${DateTime.now().millisecondsSinceEpoch}',
      date: _selectedDate!,
      time: _selectedTime!,
      serviceName: widget.doctor.specialty, // Use specialty as service name
      doctorName: widget.doctor.name,
      status: AppointmentStatus.upcoming,
    );

    // 2. Pop this screen and return the new appointment
    //    to the *previous* screen (DoctorListScreen)
    Navigator.of(context).pop(newAppointment);
  }

  @override
  Widget build(BuildContext context) {
    final bool isBookingEnabled = _selectedDate != null && _selectedTime != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Book with ${widget.doctor.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Doctor Info Header ---
            Card(
              elevation: 0,
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(Icons.person, color: Colors.blue.shade800),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.doctor.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(widget.doctor.specialty, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),

            // --- 2. Date Selector ---
            const Text('Select a Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _upcomingDates.map((date) {
                final bool isUnavailable = _unavailableWeekdays.contains(date.weekday);
                final bool isSelected = _selectedDate != null && DateUtils.isSameDay(_selectedDate, date);

                return ChoiceChip(
                  label: Text(DateFormat('EEE, MMM d').format(date)), // "Wed, Oct 29"
                  selected: isSelected,
                  backgroundColor: isUnavailable ? Colors.grey.shade300 : null,
                  labelStyle: TextStyle(
                    color: isUnavailable ? Colors.grey.shade600 : null,
                    decoration: isUnavailable ? TextDecoration.lineThrough : null,
                  ),
                  onSelected: isUnavailable
                      ? null // Disable selection if unavailable
                      : (isSelected) {
                          setState(() {
                            _selectedDate = date;
                            _selectedTime = null; // Reset time when date changes
                          });
                        },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // --- 3. Time Selector (shows only if a date is selected) ---
            if (_selectedDate != null) ...[
              const Text('Select a Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _availableTimeSlots.map((time) {
                  final bool isSelected = _selectedTime == time;
                  return ChoiceChip(
                    label: Text(time.format(context)), // "10:30 AM"
                    selected: isSelected,
                    onSelected: (isSelected) {
                      setState(() {
                        _selectedTime = time;
                      });
                    },
                  );
                }).toList(),
              ),
            ],

            const Spacer(), // Pushes the button to the bottom

            // --- 4. Confirm Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isBookingEnabled ? _confirmBooking : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Confirm Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
