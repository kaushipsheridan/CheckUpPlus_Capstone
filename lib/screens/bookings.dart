import 'package:flutter/material.dart';
import '../authentication/appointment_model.dart';
import '../authentication/appointment_card.dart';

// --- Helper View for Tab Content ---

/// Renders a filtered list of appointments for a single tab.
class AppointmentListView extends StatelessWidget {
  final AppointmentStatus filterStatus;
  
  const AppointmentListView({super.key, required this.filterStatus});

  @override
  Widget build(BuildContext context) {
    // Filter the mock data based on the required status
    final filteredList = mockAppointments.where((appt) {
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
        return AppointmentCard(appointment: filteredList[index]);
      },
    );
  }
}


// --- Main Screen Implementation ---

/// The main screen displaying the appointment tabs and booking button.
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  /// Handles the navigation to the booking page.
  void _onBookAppointmentTap(BuildContext context) {
    // Placeholder navigation for "Book an Appointment"
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Appointment Category')),
          body: const Center(child: Text('Category Selection Page')),
        ),
      ),
    );
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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary, // Use default theme color
          
          // Custom AppBar bottom to include the button above the tabs
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100.0), // Height for button + tabs
            child: Column(
              children: [
                // Book an Appointment Button (Always visible)
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
                    // Since AppointmentStatus doesn't have a combined 'Canceled/Missed', we use 'canceled' for the filter logic.
                    Tab(text: 'Canceled/Missed'), 
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Tab Bar View
        body: const TabBarView(
          children: [
            // Upcoming Tab Content
            AppointmentListView(filterStatus: AppointmentStatus.upcoming),
            
            // Completed Tab Content
            AppointmentListView(filterStatus: AppointmentStatus.completed),
            
            // Canceled/Missed Tab Content
            AppointmentListView(filterStatus: AppointmentStatus.canceled),
          ],
        ),
      ),
    );
  }
}