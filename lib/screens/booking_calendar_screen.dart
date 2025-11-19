import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:checkupplus_capstone/models/doctor_model.dart';
import 'package:checkupplus_capstone/services/appointment_service.dart';
import 'package:checkupplus_capstone/services/clinic_service.dart';

class BookingCalendarScreen extends StatefulWidget {
  final DoctorModel doctor; // Changed from Doctor to DoctorModel

  const BookingCalendarScreen({super.key, required this.doctor});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final ClinicService _clinicService = ClinicService();
  
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  List<String> _availableTimeSlots = [];
  List<String> _bookedTimeSlots = [];
  bool _isLoadingSlots = false;
  bool _isBooking = false;
  String? _clinicName;

  // Generate the next 30 days for selection
  final List<DateTime> _upcomingDates = List.generate(30, (index) {
    return DateTime.now().add(Duration(days: index));
  });

  // Make Sundays unavailable
  final Set<int> _unavailableWeekdays = {DateTime.sunday};

  // All possible time slots (9 AM - 5 PM, 30-min intervals)
  final List<String> _allTimeSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00'
  ];

  @override
  void initState() {
    super.initState();
    _loadClinicName();
  }

  /// Load clinic name
  Future<void> _loadClinicName() async {
    try {
      final clinic = await _clinicService.getClinic(widget.doctor.clinicId);
      if (clinic != null && mounted) {
        setState(() {
          _clinicName = clinic.name;
        });
      }
    } catch (e) {
      print('Error loading clinic: $e');
    }
  }

  /// Load booked time slots when a date is selected
  Future<void> _loadBookedTimeSlots(DateTime date) async {
    if (widget.doctor.id == null) return;

    setState(() => _isLoadingSlots = true);

    try {
      final bookedSlots = await _appointmentService.getBookedTimeSlots(
        doctorId: widget.doctor.id!,
        date: date,
      );

      setState(() {
        _bookedTimeSlots = bookedSlots;
        _availableTimeSlots = _allTimeSlots
            .where((slot) => !bookedSlots.contains(slot))
            .toList();
        _isLoadingSlots = false;
      });
    } catch (e) {
      print('Error loading time slots: $e');
      setState(() => _isLoadingSlots = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading available times: $e')),
        );
      }
    }
  }

  /// Confirm and save appointment to Firestore
  Future<void> _confirmBooking() async {
    if (_selectedDate == null || _selectedTimeSlot == null || widget.doctor.id == null) {
      return;
    }

    setState(() => _isBooking = true);

    try {
      // Create appointment in Firestore
      final appointmentId = await _appointmentService.createAppointment(
        clinicId: widget.doctor.clinicId,
        doctorId: widget.doctor.id!,
        date: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        serviceName: widget.doctor.specialty,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment successfully booked!'),
            backgroundColor: Colors.green,
          ),
        );

        // Pop back with the appointment ID
        Navigator.of(context).pop(appointmentId);
      }
    } catch (e) {
      setState(() => _isBooking = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Format time slot for display (e.g., "14:00" -> "2:00 PM")
  String _formatTimeSlot(String timeSlot) {
    final parts = timeSlot.split(':');
    if (parts.length != 2) return timeSlot;
    
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    
    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  @override
  Widget build(BuildContext context) {
    final bool isBookingEnabled = 
        _selectedDate != null && 
        _selectedTimeSlot != null && 
        !_isBooking;

    return Scaffold(
      appBar: AppBar(
        title: Text('Book with ${widget.doctor.name}'),
      ),
      body: _isBooking
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. Doctor Info Header ---
                  Card(
                    elevation: 0,
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(Icons.person,
                                color: Colors.blue.shade800),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.doctor.name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Text(widget.doctor.specialty,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700)),
                                if (_clinicName != null)
                                  Text(_clinicName!,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 32),

                  // --- 2. Date Selector ---
                  const Text('Select a Date',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _upcomingDates.length,
                      itemBuilder: (context, index) {
                        final date = _upcomingDates[index];
                        final bool isUnavailable =
                            _unavailableWeekdays.contains(date.weekday);
                        final bool isSelected = _selectedDate != null &&
                            DateUtils.isSameDay(_selectedDate, date);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(DateFormat('EEE\nMMM d').format(date)),
                            selected: isSelected,
                            backgroundColor:
                                isUnavailable ? Colors.grey.shade300 : null,
                            labelStyle: TextStyle(
                              color: isUnavailable
                                  ? Colors.grey.shade600
                                  : null,
                              fontSize: 12,
                            ),
                            onSelected: isUnavailable
                                ? null
                                : (selected) {
                                    setState(() {
                                      _selectedDate = date;
                                      _selectedTimeSlot = null;
                                    });
                                    _loadBookedTimeSlots(date);
                                  },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 3. Time Selector ---
                  if (_selectedDate != null) ...[
                    const Text('Select a Time',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (_isLoadingSlots)
                      const Center(child: CircularProgressIndicator())
                    else if (_availableTimeSlots.isEmpty)
                      Center(
                        child: Text(
                          'No available time slots for this date',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    else
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2.5,
                          ),
                          itemCount: _availableTimeSlots.length,
                          itemBuilder: (context, index) {
                            final timeSlot = _availableTimeSlots[index];
                            final bool isSelected =
                                _selectedTimeSlot == timeSlot;

                            return ChoiceChip(
                              label: Text(_formatTimeSlot(timeSlot)),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedTimeSlot = timeSlot;
                                });
                              },
                            );
                          },
                        ),
                      ),
                  ],

                  const SizedBox(height: 16),

                  // --- 4. Confirm Button ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isBookingEnabled ? _confirmBooking : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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