import 'package:flutter/material.dart';
import 'report_issue_screen.dart'; // Import the new screen

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Support Section
              const SizedBox(height: 16),
              const Text(
                'Contact Support',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: const Text('Email Us'),
                onTap: () {
                  // Logic to open email client
                },
              ),

              // Report a Problem Section
              const SizedBox(height: 16),
              const Text(
                'Report a Problem',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: Icon(Icons.bug_report),
                title: const Text('Report an Issue'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReportIssueScreen()),
                  );
                },
              ),

              // App Updates and Release Notes Section
              const SizedBox(height: 16),
              const Text(
                'App Updates',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: Icon(Icons.update),
                title: const Text('View Latest Updates'),
                onTap: () {
                  // Logic to view app updates
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
