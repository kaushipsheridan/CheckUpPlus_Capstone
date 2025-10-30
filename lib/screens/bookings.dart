import 'package:flutter/material.dart';
import '../authentication/appointment_card.dart';
import '../authentication/appointment_model.dart';
import 'category_specialists_card.dart'; // The category grid screen
import 'doctor_model.dart'; // Import this to avoid errors

// --- Helper View for Tab Content ---

/// Renders a filtered list of appointments for a single tab.
class AppointmentListView extends StatelessWidget {
  final AppointmentStatus filterStatus;
  final List<Appointment> appointments;
  final Function(String appointmentId) onCancelAppointment;

  const AppointmentListView({
    super.key,
    required this.filterStatus,
    required this.appointments,
    required this.onCancelAppointment,
  });

  @override
  Widget build(BuildContext context) {
    // Filter the live data based on the required status
    final filteredList = appointments.where((appt) {
      if (filterStatus == AppointmentStatus.canceled) {
        // Canceled/Missed tab needs both canceled and missed status
        return appt.status == AppointmentStatus.canceled ||
            appt.status == AppointmentStatus.missed;
      }
      return appt.status == filterStatus;
    }).toList();

    // Sort the list: upcoming = soonest first, completed/canceled = newest first
    if (filterStatus == AppointmentStatus.upcoming) {
      filteredList.sort((a, b) => a.date.compareTo(b.date));
    } else {
      filteredList.sort((a, b) => b.date.compareTo(a.date));
    }


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
          onCancel: onCancelAppointment,
        );
      },
    );
  }
}

// --- Main Screen Implementation (StatefulWidget) ---

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  // 1. MANAGE THE APPOINTMENT LIST STATE
  
  // *** THIS IS THE CHANGE ***
  // We now start with an empty list instead of the mock data.
  List<Appointment> currentAppointments = [];
  // List<Appointment> currentAppointments = List.from(mockAppointments); // This was the old line

  /// *** UPDATED METHOD ***
  /// Handles navigation to the booking page AND receives the result.
  void _onBookAppointmentTap(BuildContext context) async {
    // Make it async
    // 1. Push the category screen and WAIT for a result
    final newAppointment = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CategorySpecialistsScreen(),
      ),
    );

    // 2. Check if the user completed the whole flow and returned an appointment
    if (newAppointment != null && newAppointment is Appointment) {
      // 3. Add the new appointment to our state!
      setState(() {
        currentAppointments.add(newAppointment);
      });

      // 4. Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment successfully booked!'),
          backgroundColor: Colors.green,
        ),
      );

      // 5. (Optional) Auto-switch to the "Upcoming" tab to see the new appointment
      // This 'context' has access to the DefaultTabController
      DefaultTabController.of(context).animateTo(0);
    }
  }

  // 2. Method to update the status of an appointment
  void _cancelAppointment(String appointmentId) {
    setState(() {
      final index =
          currentAppointments.indexWhere((appt) => appt.id == appointmentId);
      if (index != -1 &&
          currentAppointments[index].status == AppointmentStatus.upcoming) {
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      // *** Use the updated method ***
                      onPressed: () => _onBookAppointmentTap(context),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Book an Appointment'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
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

