import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/Screens/RateUsScreen.dart';
import 'package:mobile_app/Screens/change_password_screen.dart';
import 'package:mobile_app/providers/theme_provider.dart';
import 'package:mobile_app/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/Screens/help_support_screen.dart';
import 'package:mobile_app/Screens/privacy_policy_screen.dart';
import 'package:mobile_app/Screens/notification_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'User Name';
  String userEmail = 'username@example.com';
  String? userImage;
  bool hasUnseenNotifications = true;
  final ImagePicker _picker = ImagePicker(); // Image Picker instance
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // FirebaseFirestore instance

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUnseenNotifications();
  }

  void _loadUnseenNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot notificationsSnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('seen', isEqualTo: false) // Only unseen notifications
          .get();

      setState(() {
        hasUnseenNotifications = notificationsSnapshot.docs.isNotEmpty;
      });
    }
  }

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? 'User Name';
          userEmail = userDoc['email'] ?? 'username@example.com';
          userImage = userDoc['image'] ?? 'https://via.placeholder.com/150';
        });
      }
    }
  }

  void _logOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        userImage = pickedFile.path; // Update image path immediately
      });

      // Get the current user's UID
      User? user = _auth.currentUser;

      if (user != null) {
        try {
          // Save the local image path to Firestore under the user's document
          await _firestore.collection('users').doc(user.uid).update({
            'image': pickedFile.path, // Save the local file path as the image path
          });

          // Update the state with the new image path
          setState(() {
            userImage = pickedFile.path; // Update the UI with the local image path
          });
        } catch (e) {
          print("Error saving image path: $e");
        }
      }
    }
  }

  // Function to show options for selecting image
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: customPurple,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EditProfileDialog(
                  currentName: userName,
                  currentEmail: userEmail,
                  currentImage: userImage ?? 'https://via.placeholder.com/150',
                  onSave: (newName, newEmail, newImage) {
                    setState(() {
                      userName = newName;
                      userEmail = newEmail;
                      userImage = newImage;
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showImagePicker,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: userImage != null
                          ? FileImage(File(userImage!)) as ImageProvider
                          : const NetworkImage('https://via.placeholder.com/150'),
                      child: userImage == null
                          ? const Icon(Icons.camera_alt, size: 30, color: Colors.white70)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
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
                  MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen()),
                );
              },
            ),
            ListTile(
              leading: Stack(
                children: [
                  const Icon(Icons.notifications),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('notifications')
                        .where('unread', isEqualTo: true) // Listening to only unread notifications
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        return Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              snapshot.data!.docs.length.toString(), // Show count of unread notifications
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink(); // Hide red mark if no unread notifications
                    },
                  ),
                ],
              ),
              title: const Text('Notifications'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(userId: FirebaseAuth.instance.currentUser!.uid),
                  ),
                );

                // Mark all notifications as read after viewing
                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('notifications')
                    .where('unread', isEqualTo: true)
                    .get();

                for (var doc in querySnapshot.docs) {
                  await doc.reference.update({'unread': false});
                }
              },
            ),
            const Divider(),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
             ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('Rate Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RateUsScreen()),
                ); // Logic to redirect user to app rating page
              },
            ),

            // Dark Mode Setting with Modern UI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Dark Mode',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    trailing: Switch.adaptive(
                      value: themeProvider.isDarkMode,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.black,
                      inactiveThumbColor: Colors.grey.shade300,
                      inactiveTrackColor: Colors.grey.shade600,
                      onChanged: (bool value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  );
                },
              ),
            ),


            // Log Out Button with Gradient Styling
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: double.infinity, // Full-width button
                  child: ElevatedButton(
                    onPressed: _logOut,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: customPurple, // Fallback color
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255)],
                      ).createShader(bounds),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white, // Keeps text visible with gradient
                            ),
                          ),
                        ],
                      ),
                    ),
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

/// Edit Profile Dialog
class EditProfileDialog extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final String currentImage;
  final Function(String, String, String) onSave;

  EditProfileDialog({
    required this.currentName,
    required this.currentEmail,
    required this.currentImage,
    required this.onSave,
  });

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
    _emailController.text = widget.currentEmail;
  }

  /// Pick an image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  /// Save edited details to Firestore
  void _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'image': _imagePath ?? widget.currentImage, // Use old image if not changed
      });

      widget.onSave(
        _nameController.text,
        _emailController.text,
        _imagePath ?? widget.currentImage,
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit Profile"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: _imagePath != null
                  ? FileImage(File(_imagePath!)) // Load selected image
                  : NetworkImage(widget.currentImage) as ImageProvider, // Load existing image
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: "Email"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: _saveProfile,
          child: Text("Save"),
        ),
      ],
    );
  }
}