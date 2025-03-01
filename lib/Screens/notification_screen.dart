import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<String> notifications = [
    'New recipe added!',
    'Discount on ingredients!',
    'New update available!'
  ];
  int unreadCount = 3;

  @override
  void initState() {
    super.initState();
    // Simulate marking notifications as read when the screen is opened
    _markNotificationsAsRead();
  }

  void _markNotificationsAsRead() {
    setState(() {
      unreadCount = 0; // Reset unread count after notifications are seen
    });
  }

  // Method to delete a notification from the list
  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);  // Remove the notification from the list
      unreadCount = notifications.length;  // Update the unread count
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color.fromARGB(255, 96, 26, 182),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(notifications[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Show a confirmation dialog before deleting
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Notification'),
                        content: const Text('Are you sure you want to delete this notification?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Delete the notification
                              _deleteNotification(index);
                              Navigator.of(context).pop();
                            },
                            child: const Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('No'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
