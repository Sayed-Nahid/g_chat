import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:g_chat/pages/dashboard_screen.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Ensure FirebaseAuth is imported

class ProfileSetScreen extends StatefulWidget {
  const ProfileSetScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetScreen> createState() => _ProfileSetScreenState();
}

class _ProfileSetScreenState extends State<ProfileSetScreen> {
  static const _primaryColor = Color(0xFF81D8D0);
  static const _gradientColors = [Color(0xFF000000), Color(0xFF343434)];
  static const _textColor = Colors.white;
  static const _placeholderIconSize = 60.0;
  static const _profileImageSize = 120.0;
  static const _cameraIconSize = 20.0;
  static const _maxImageSize = 10 * 1024 * 1024; // 5MB in bytes

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isProcessingImage = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // Upload Profile Image to Firebase Storage
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final profileImagesRef = storageRef.child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = profileImagesRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        final imageUrl = await snapshot.ref.getDownloadURL();
        print("Image uploaded successfully: $imageUrl");
        return imageUrl;
      } else {
        print("Error uploading image: ${snapshot.state}");
      }

    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // Save Profile Data in Firestore
  Future<void> saveUserProfile(String firstName, String lastName, String imageUrl) async {
    try {
      // Get the current authenticated user's UID
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print("User is not authenticated.");
        return;
      }

      // Save profile data to Firestore under 'users' collection using user UID as document ID
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

      await userRef.set({
        'first_name': firstName,
        'last_name': lastName,
        'profile_image': imageUrl,
        'created_at': FieldValue.serverTimestamp(),
      });

      print("User profile saved successfully!");
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  // Crop Image
  Future<File?> _cropImage(XFile pickedFile) async {
    try {
      setState(() => _isProcessingImage = true);
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: true,
            showCropGrid: false,
            statusBarColor: Colors.black,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: _primaryColor,
            dimmedLayerColor: Colors.black.withOpacity(0.8),
          ),
          IOSUiSettings(
            title: 'Crop Profile',
            aspectRatioLockEnabled: true,
            resetButtonHidden: true,
            rotateButtonsHidden: true,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
        compressQuality: 85,
      );

      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cropping image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => _isProcessingImage = false);
      }
    }
  }

  // Process Image Selection (Gallery/Camera)
  Future<void> _processImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      final fileSize = await pickedFile.length();
      if (fileSize > _maxImageSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size must be less than 5MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final croppedFile = await _cropImage(pickedFile);
      if (croppedFile != null && mounted) {
        setState(() => _imageFile = croppedFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Open Image Picker (Gallery/Camera)
  Future<void> _pickImage() async {
    if (_isProcessingImage) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _processImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _processImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // Validate and Submit Profile Data
  void _validateAndSubmit() async {
    if (_firstNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your first name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your last name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profile picture'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Upload profile image to Firebase Storage
    String? imageUrl = await uploadProfileImage(_imageFile!);

    if (imageUrl != null) {
      // Save user profile data in Firestore
      await saveUserProfile(_firstNameController.text, _lastNameController.text, imageUrl);

      // Redirect to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading profile picture'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _isProcessingImage ? null : _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isProcessingImage)
            const CircularProgressIndicator(color: _primaryColor),

          if (!_isProcessingImage && _imageFile == null)
            Image.asset(
              'assets/images/profile_placeholder.png',
              width: _profileImageSize,
              height: _profileImageSize,
              errorBuilder: (_, __, ___) => Icon(
                Icons.person,
                size: _placeholderIconSize,
                color: Colors.white54,
              ),
            ),

          if (!_isProcessingImage && _imageFile != null)
            Container(
              width: _profileImageSize,
              height: _profileImageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _textColor, width: 2),
                image: DecorationImage(
                  image: FileImage(_imageFile!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          if (!_isProcessingImage)
            Positioned(
              bottom: 0,
              right: _imageFile == null ? 0 : 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: _cameraIconSize,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameInputField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Your $label',
        labelStyle: const TextStyle(color: _textColor),
        hintStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _textColor),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _textColor),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: const TextStyle(color: _textColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: _gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Complete Your Profile',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ) ?? const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 40),

                _buildProfileImage(),
                const SizedBox(height: 40),

                _buildNameInputField(_firstNameController, 'First Name'),
                const SizedBox(height: 20),

                _buildNameInputField(_lastNameController, 'Last Name'),
                const SizedBox(height: 60),

                ElevatedButton(
                  onPressed: _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 120, vertical: 18),
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
