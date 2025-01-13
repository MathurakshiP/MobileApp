import 'package:flutter/material.dart';

class RateUsScreen extends StatefulWidget {
  @override
  _RateUsScreenState createState() => _RateUsScreenState();
}

class _RateUsScreenState extends State<RateUsScreen> {
  double _rating = 0;
  TextEditingController _feedbackController = TextEditingController();

  void _submitFeedback() {
    String feedback = _feedbackController.text;
    print('Rating: $_rating');
    print('Feedback: $feedback');

    if (_rating >= 4) {
      // Optionally redirect to app store for a public review
      _redirectToAppStore();
    }

    _showThankYouMessage();

    // Clear the input fields
    setState(() {
      _rating = 0;
      _feedbackController.clear();
    });
  }

  void _redirectToAppStore() {
    // Add logic to redirect to the app store
    print('Redirecting to app store...');
  }

  void _showThankYouMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thank You!'),
        content: Text('Your feedback has been submitted.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _skipFeedback() {
    // Logic for skipping feedback
    print('User chose to skip feedback.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Enjoying the app? We\'d love your feedback!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    _rating >= index + 1 ? Icons.star : Icons.star_border,
                  ),
                  color: Colors.amber,
                  iconSize: 40,
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Your Feedback'),
              subtitle: TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your feedback here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: Text('Submit'),
            ),
            ListTile(
              title: TextButton(
                onPressed: _skipFeedback,
                child: Text('Skip/Remind Later'),
              ),
            ),
            Spacer(),
            Text(
              'Your feedback helps us improve. We value your privacy.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
