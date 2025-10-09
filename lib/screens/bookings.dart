import 'package:flutter/material.dart';
import '../authentication/appointment_model.dart';
import '../authentication/appointment_card.dart';
import 'category_specialists_card.dart'; // Assuming the screen file name is correct


// --- Helper View for Tab Content ---

/// Renders a filtered list of appointments for a single tab.
class AppointmentListView extends StatelessWidget {
  final AppointmentStatus filterStatus;
  final List<Appointment> appointments;
  // New: Pass the callback for cancellation
  final Function(String appointmentId) onCancelAppointment; 
  
  const AppointmentListView({
    super.key, 
    required this.filterStatus,
    required this.appointments, // New: Accept the list from the stateful parent
    required this.onCancelAppointment, // New: Accept the cancellation handler
  });

  @override
  Widget build(BuildContext context) {
    // Filter the live data based on the required status
    final filteredList = appointments.where((appt) {
      if (filterStatus == AppointmentStatus.canceled) {
        // Canceled/Missed tab needs both canceled and missed status
        return appt.status == AppointmentStatus.canceled || appt.status == AppointmentStatus.missed;
      }
      return appt.status == filterStatus;
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          'No ${filterStatus == AppointmentStatus.canceled ? 'Canceled/Missed' : filterStatus.name} appointments.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return AppointmentCard(
          appointment: filteredList[index],
          // Pass the callback to the card
          onCancel: onCancelAppointment,
        );
      },
    );
  }
}


// --- Main Screen Implementation (Converted to StatefulWidget) ---

/// The main screen displaying the appointment tabs and booking button.
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  // 1. MANAGE THE APPOINTMENT LIST STATE
  // We use a copy of mockAppointments so we can modify it
  List<Appointment> currentAppointments = List.from(mockAppointments);

  /// Handles the navigation to the booking page.
  void _onBookAppointmentTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CategorySpecialistsScreen(),
      ),
    );
  }

  // 2. NEW METHOD: Update the status of an appointment
  void _cancelAppointment(String appointmentId) {
    setState(() {
      final index = currentAppointments.indexWhere((appt) => appt.id == appointmentId);
      if (index != -1 && currentAppointments[index].status == AppointmentStatus.upcoming) {
        // Create a new Appointment object with the CANCELED status
        currentAppointments[index] = Appointment(
          id: currentAppointments[index].id,
          date: currentAppointments[index].date,
          time: currentAppointments[index].time,
          serviceName: currentAppointments[index].serviceName,
          doctorName: currentAppointments[index].doctorName,
          status: AppointmentStatus.canceled,
          cancellationReason: 'Canceled by user.', // Add a default reason
        );
        // Show confirmation to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment successfully canceled.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use DefaultTabController to manage the three tabs
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary, 
          
          // Custom AppBar bottom to include the button above the tabs
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100.0), // Height for button + tabs
            child: Column(
              children: [
                // Book an Appointment Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _onBookAppointmentTap(context),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Book an Appointment'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
                
                // Tab Bar
                const TabBar(
                  indicatorColor: Colors.blue,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Completed'),
                    Tab(text: 'Canceled/Missed'), 
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Tab Bar View - Pass the stateful data and the callback
        body: TabBarView(
          children: [
            // Upcoming Tab Content
            AppointmentListView(
              filterStatus: AppointmentStatus.upcoming,
              appointments: currentAppointments,
              onCancelAppointment: _cancelAppointment,
            ),
            
            // Completed Tab Content
            AppointmentListView(
              filterStatus: AppointmentStatus.completed,
              appointments: currentAppointments,
              onCancelAppointment: _cancelAppointment,
            ),
            
            // Canceled/Missed Tab Content
            AppointmentListView(
              filterStatus: AppointmentStatus.canceled,
              appointments: currentAppointments,
              onCancelAppointment: _cancelAppointment,
            ),
          ],
        ),
      ),
    );
  }
}