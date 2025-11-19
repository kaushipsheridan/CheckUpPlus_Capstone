import 'package:flutter/material.dart';
import 'appointment_model.dart';

// --- REUSABLE WIDGETS ---

/// Custom Card to display appointment details and action buttons.
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  // New: Callback to inform the parent screen when an appointment is canceled
  final Function(String appointmentId) onCancel; 
  
  const AppointmentCard({
    super.key, 
    required this.appointment,
    required this.onCancel, // New: Required
  });

  @override
  Widget build(BuildContext context) {
    // Determine card color and status text based on status for quick visual feedback
    // ... (unchanged status color/text logic)
    Color statusColor;
    String statusText;
    switch (appointment.status) {
      case AppointmentStatus.upcoming:
        statusColor = Colors.blue.shade100;
        statusText = 'Upcoming';
        break;
      case AppointmentStatus.completed:
        statusColor = Colors.green.shade100;
        statusText = 'Completed';
        break;
      case AppointmentStatus.canceled:
        statusColor = Colors.red.shade100;
        statusText = 'Canceled';
        break;
      case AppointmentStatus.missed:
        statusColor = Colors.orange.shade100;
        statusText = 'Missed';
        break;
    }


    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: statusColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status, Date, Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appointment.formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                Text(
                  '${appointment.formattedTime} - $statusText',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            const Divider(height: 10, color: Colors.black26),
            
            // Details
            Text(
              appointment.serviceName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${appointment.doctorName}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 10),

            // Cancellation Reason (for Canceled/Missed)
            if (appointment.cancellationReason != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Reason: ${appointment.cancellationReason}',
                  style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.red),
                ),
              ),
              
            // Action Buttons
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _buildActionButtons(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build buttons based on appointment status
  List<Widget> _buildActionButtons(BuildContext context) {
    // These actions are currently simple placeholders using SnackBar
    void showSnackbar(String action) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action Tapped: $action ${appointment.id}')),
      );
    }

    switch (appointment.status) {
      case AppointmentStatus.upcoming:
        return [
          TextButton(
            onPressed: () => showSnackbar('Reschedule'),
            child: const Text('Reschedule'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            // KEY FIX: Call the onCancel callback here
            onPressed: () => onCancel(appointment.id), 
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: const Text('Cancel'),
          ),
        ];
      case AppointmentStatus.completed:
        return [
          TextButton.icon(
            onPressed: () => showSnackbar('Review'),
            icon: const Icon(Icons.star_border),
            label: const Text('Leave Review'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => showSnackbar('Rebook'),
            child: const Text('Rebook'),
          ),
        ];
      case AppointmentStatus.canceled:
      case AppointmentStatus.missed:
        return [
          ElevatedButton(
            onPressed: () => showSnackbar('Rebook'),
            child: const Text('Rebook'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white)
          ),
        ];
    }
  }
}