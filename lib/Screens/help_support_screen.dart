import 'package:flutter/material.dart';
import 'report_issue_screen.dart'; // Import the new screen
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'cookifyrecipes1234@gmail.com', // Replace with your support email
      queryParameters: {
        'subject': 'Support Request',
        'body': '...',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email client';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        height: 1000,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 255, 255, 255)],
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //   ),
        // ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Support Section
                  const SizedBox(height: 16),
                  const Text(
                    'Contact Support',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5,
                    color: isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
                    child: ListTile(
                      leading: Icon(Icons.email, color: Colors.deepPurple),
                      title: Text(
                        'Email Us', 
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      onTap: _launchEmail,
                    ),
                  ),
                  // Report a Problem Section
                  const SizedBox(height: 16),
                  const Text(
                    'Report a Problem',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),                
                    elevation: 5,
                    child: ListTile(
                      leading: Icon(Icons.bug_report, color: Colors.deepPurple),
                      title: Text(
                        'Report an Issue', 
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportIssueScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  // App Updates and Release Notes Section
                  const SizedBox(height: 16),
                  const Text(
                    'App Updates',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
                    elevation: 5,
                    child: ListTile(
                      leading: Icon(Icons.update, color: Colors.deepPurple),
                      title: Text(
                        'View Latest Updates', 
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkMode ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('All Caught Up!'),
                              content: Text(
                                'Great news! You’re already using the latest version. Stay tuned for more updates to enhance your experience!',
                                style: TextStyle(fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text(
                                    'Awesome!',
                                    style: TextStyle(color: Colors.deepPurple),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
