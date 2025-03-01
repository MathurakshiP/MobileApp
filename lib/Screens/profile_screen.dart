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
  Color customPurple = const Color.fromARGB(255, 96, 26, 182);

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  // Function to pick an image
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        userImage = pickedFile.path; // Update image immediately
      });
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
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationScreen()),
                );
                setState(() {
                  hasUnseenNotifications = false;
                });
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