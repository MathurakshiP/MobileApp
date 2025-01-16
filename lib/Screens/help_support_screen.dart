import 'package:flutter/material.dart';

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
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for help...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // FAQs Section
              const Text(
                'FAQs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const ListTile(
                title: Text('How to use the app?'),
                subtitle:
                    Text('A guide on how to use the main features of the app.'),
              ),
              const ListTile(
                title: Text('How to reset my password?'),
                subtitle: Text('Instructions on how to reset your password.'),
              ),
              // Add more FAQs as needed

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
              ListTile(
                leading: Icon(Icons.phone),
                title: const Text('Call Us'),
                onTap: () {
                  // Logic to initiate a phone call
                },
              ),

              // User Guide or Tutorials Section
              const SizedBox(height: 16),
              const Text(
                'User Guide & Tutorials',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: Icon(Icons.play_circle_fill),
                title: const Text('Watch Tutorials'),
                onTap: () {
                  // Logic to open video tutorials
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
                  // Logic to report a problem
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
