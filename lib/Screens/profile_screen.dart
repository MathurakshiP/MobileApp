import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/change_password_screen.dart';
import 'package:mobile_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

// import 'package:provider/provider.dart';
// import '../providers/theme_provider.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'User Name';
  String userEmail = 'username@example.com';
  String userImage = 'https://via.placeholder.com/150'; // Placeholder image
  bool isDarkMode = false;
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? 'User Name'; // Fetch user's name
        userEmail = user.email ?? 'username@example.com'; // Fetch user's email
      });
    }
  }


  void _logOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',style: TextStyle(
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.white,
                fontSize: 20,),
                ),
        backgroundColor: customPurple,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile page or open a dialog for editing
              showDialog(
                context: context,
                builder: (context) => EditProfileDialog(
                  currentName: userName,
                  currentEmail: userEmail,
                  currentImage: userImage,
                  onSave: (name, email, imageUrl) {
                    setState(() {
                      userName = name;
                      userEmail = email;
                      userImage = imageUrl;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(userImage), // User's profile picture
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            // Account Settings Section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Account Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                ); // Navigate to Change Password Screen or handle the logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              onTap: () {
                // Language change logic or navigation
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                // Navigate to Notifications settings or handle notifications settings
              },
            ),
            const Divider(),

            // App Settings Section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'App Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                // Show Privacy Policy or navigate to its screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {
                // Show Help & Support page or navigate to its screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('Rate Us'),
              onTap: () {
                // Logic to redirect user to app rating page
              },
            ),
            const Divider(),

            // Dark Mode Setting
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dark Mode', style: TextStyle(fontSize: 18)),
                      Switch(
                        value: themeProvider.isDarkMode,
                       onChanged: (bool value) {
              themeProvider.toggleTheme(); // Toggle the theme when the Switch is changed
            }, // Toggle theme
                      ),
                    ],
                  );
                },
              ),
            ),

            // Log Out Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _logOut,
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Log Out',
                    style: TextStyle(
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.white,
                    ),
                    ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 191, 0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Editing Dialog
class EditProfileDialog extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentImage;
  final Function(String, String, String) onSave;

  const EditProfileDialog({super.key, 
    required this.currentName,
    required this.currentEmail,
    required this.currentImage,
    required this.onSave,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // ignore: prefer_final_fields
  TextEditingController _imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
    _emailController.text = widget.currentEmail;
    _imageController.text = widget.currentImage;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _imageController,
            decoration: const InputDecoration(labelText: 'Image URL'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onSave(
              _nameController.text,
              _emailController.text,
              _imageController.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
