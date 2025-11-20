import 'package:flutter/material.dart';
import 'package:checkupplus_capstone/widgets/appointment_card.dart';
import 'package:checkupplus_capstone/models/appointment_model.dart';
import 'package:checkupplus_capstone/services/appointment_service.dart';
import 'package:checkupplus_capstone/services/doctor_service.dart';
import 'package:checkupplus_capstone/services/clinic_service.dart';
import 'package:checkupplus_capstone/models/doctor_model.dart';
import 'package:checkupplus_capstone/models/clinic_model.dart';
import 'package:checkupplus_capstone/screens/category_specialists_card.dart';
import 'package:checkupplus_capstone/screens/reschedule_appointment_screen.dart'; // FIXED - No hide needed now
 

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  final ClinicService _clinicService = ClinicService();

  List<AppointmentModel> _appointments = [];
  Map<String, DoctorModel> _doctorsCache = {};
  Map<String, ClinicModel> _clinicsCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  /// Load appointments from Firestore
  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);

    try {
      final appointments = await _appointmentService.getUserAppointments();
      
      // Load doctor and clinic details for each appointment
      for (var appointment in appointments) {
        // Cache doctor details
        if (!_doctorsCache.containsKey(appointment.doctorId)) {
          final doctor = await _doctorService.getDoctor(appointment.doctorId);
          if (doctor != null) {
            _doctorsCache[appointment.doctorId] = doctor;
          }
        }

        // Cache clinic details
        if (!_clinicsCache.containsKey(appointment.clinicId)) {
          final clinic = await _clinicService.getClinic(appointment.clinicId);
          if (clinic != null) {
            _clinicsCache[appointment.clinicId] = clinic;
          }
        }
      }

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading appointments: $e')),
        );
      }
    }
  }

  /// Cancel an appointment
  Future<void> _cancelAppointment(String appointmentId, String reason) async {
    try {
      await _appointmentService.cancelAppointment(
        appointmentId: appointmentId,
        reason: reason,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        
        // Reload appointments
        _loadAppointments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show cancel confirmation dialog
  Future<void> _showCancelDialog(String appointmentId) async {
    final reasonController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this appointment?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Appointment'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelAppointment(
                appointmentId,
                reasonController.text.isEmpty 
                    ? 'Cancelled by user' 
                    : reasonController.text,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );
  }

  /// Navigate to reschedule screen
  Future<void> _rescheduleAppointment(AppointmentModel appointment) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RescheduleAppointmentScreen(
          appointment: appointment,
        ),
      ),
    );

    // Reload appointments if rescheduling was successful
    if (result == true) {
      _loadAppointments();
    }
  }

  /// Filter appointments by status
  List<AppointmentModel> _filterAppointments(String status) {
    switch (status) {
      case 'upcoming':
        return _appointments
            .where((apt) => apt.isUpcoming)
            .toList();
      case 'completed':
        return _appointments
            .where((apt) => apt.status == 'completed')
            .toList();
      case 'canceled':
        return _appointments
            .where((apt) => apt.status == 'canceled')
            .toList();
      default:
        return _appointments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Canceled'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Upcoming Tab
                  AppointmentListView(
                    appointments: _filterAppointments('upcoming'),
                    doctorsCache: _doctorsCache,
                    clinicsCache: _clinicsCache,
                    onCancelAppointment: _showCancelDialog,
                    onRescheduleAppointment: _rescheduleAppointment,
                    emptyMessage: 'No upcoming appointments',
                  ),
                  // Completed Tab
                  AppointmentListView(
                    appointments: _filterAppointments('completed'),
                    doctorsCache: _doctorsCache,
                    clinicsCache: _clinicsCache,
                    onCancelAppointment: null,
                    onRescheduleAppointment: null,
                    emptyMessage: 'No completed appointments',
                  ),
                  // Canceled Tab
                  AppointmentListView(
                    appointments: _filterAppointments('canceled'),
                    doctorsCache: _doctorsCache,
                    clinicsCache: _clinicsCache,
                    onCancelAppointment: null,
                    onRescheduleAppointment: null,
                    emptyMessage: 'No canceled appointments',
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CategorySpecialistsScreen(),
              ),
            );
            _loadAppointments();
          },
          icon: const Icon(Icons.add),
          label: const Text('Book Appointment'),
        ),
      ),
    );
  }
}

// --- Helper View for Tab Content ---

class AppointmentListView extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final Map<String, DoctorModel> doctorsCache;
  final Map<String, ClinicModel> clinicsCache;
  final Function(String appointmentId)? onCancelAppointment;
  final Function(AppointmentModel appointment)? onRescheduleAppointment;
  final String emptyMessage;

  const AppointmentListView({
    super.key,
    required this.appointments,
    required this.doctorsCache,
    required this.clinicsCache,
    this.onCancelAppointment,
    this.onRescheduleAppointment,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final doctor = doctorsCache[appointment.doctorId];
        final clinic = clinicsCache[appointment.clinicId];

        return AppointmentCard(
          appointment: appointment,
          doctorName: doctor?.name ?? 'Unknown Doctor',
          clinicName: clinic?.name ?? 'Unknown Clinic',
          clinicAddress: clinic?.address ?? '',
          onCancel: onCancelAppointment != null
              ? () => onCancelAppointment!(appointment.id!)
              : null,
          onReschedule: onRescheduleAppointment != null
              ? () => onRescheduleAppointment!(appointment)
              : null,
        );
      },
    );
  }
}