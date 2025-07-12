import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yumm/Authentication/userlogin.dart';
import 'package:yumm/service/auth.dart';
import 'package:yumm/service/shared_pref.dart';
import 'package:yumm/widget/widget_support.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? profile, name, email, phone, id;
  bool isLoading = false;
  bool isUploading = false;
  final ImagePicker _picker = ImagePicker();
  
  // Cloudinary Configuration - SECURITY WARNING: Don't expose secrets in production
 static final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  static final String uploadPresetP = dotenv.env['CLOUDINARY_UPLOAD_PRESET_P'] ?? '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      // Get data from SharedPreferences
      id = await SharedPreferenceHelper().getUserId();
      name = await SharedPreferenceHelper().getUserName();
      email = await SharedPreferenceHelper().getUserEmail();
      phone = await SharedPreferenceHelper().getUserPhone();
      profile = await SharedPreferenceHelper().getUserProfile();
      
      // Debug prints to check if data is loaded
      print('=== PROFILE DEBUG ===');
      print('User ID: $id');
      print('User Name: $name');
      print('User Email: $email');
      print('User Phone: $phone');
      print('User Profile: $profile');
      print('Profile is null: ${profile == null}');
      print('Profile is empty: ${profile?.isEmpty}');
      
      // Also check directly from Firestore as fallback
      if (id != null && id!.isNotEmpty) {
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('user')
              .doc(id)
              .get();
          
          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            print('Firestore Profile: ${userData["Profile"]}');
            
            // If SharedPreferences profile is null/empty but Firestore has it, update SharedPreferences
            if ((profile == null || profile!.isEmpty) && userData["Profile"] != null && userData["Profile"].toString().isNotEmpty) {
              profile = userData["Profile"];
              await SharedPreferenceHelper().saveUserProfile(profile!);
              print('Updated SharedPreferences profile from Firestore: $profile');
            }
            
            // Also sync other data if needed
            if (name == null || name!.isEmpty) {
              name = userData["Name"] ?? "";
              await SharedPreferenceHelper().saveUserName(name!);
            }
            if (email == null || email!.isEmpty) {
              email = userData["Email"] ?? "";
              await SharedPreferenceHelper().saveUserEmail(email!);
            }
            if (phone == null || phone!.isEmpty) {
              phone = userData["Mobile"] ?? "";
              await SharedPreferenceHelper().saveUserPhone(phone!);
            }
          }
        } catch (e) {
          print('Error checking Firestore: $e');
        }
      }
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error!', 'Failed to load user data', ContentType.failure);
    }
  }

  Future<String> _uploadToCloudinary(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      print('Starting Cloudinary upload...');
      print('File path: ${imageFile.path}');
      print('File size: ${await imageFile.length()} bytes');
      
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      
      // Add the image file
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      request.files.add(multipartFile);
      
      // Method 1: Using Upload Preset (Recommended)
      request.fields['upload_preset'] = uploadPresetP;
      
      // Optional fields
      request.fields['folder'] = 'profile_pictures';
      request.fields['resource_type'] = 'image';
      
      print('Request fields: ${request.fields}');
      print('Uploading to: $url');
      
      // Send request with timeout
      var response = await request.send().timeout(
        Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Upload timeout - please check your internet connection');
        },
      );
      
      print('Response status code: ${response.statusCode}');
      
      var responseData = await response.stream.bytesToString();
      print('Response data: $responseData');
      
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        
        if (jsonResponse['secure_url'] != null) {
          print('Upload successful: ${jsonResponse['secure_url']}');
          return jsonResponse['secure_url'];
        } else {
          throw Exception('No secure_url in response');
        }
      } else {
        print('Cloudinary upload failed with status: ${response.statusCode}');
        print('Error response: $responseData');
        
        // Try to parse error message
        try {
          var errorJson = json.decode(responseData);
          String errorMessage = errorJson['error']?.toString() ?? 'Unknown error';
          throw Exception('Cloudinary error: $errorMessage');
        } catch (e) {
          throw Exception('Upload failed: ${response.statusCode} - $responseData');
        }
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      rethrow;
    }
  }

  Future<void> _updateProfilePicture(String imageUrl) async {
    try {
      if (id != null && id!.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(id)
            .update({'Profile': imageUrl});
        print('Profile updated in Firestore');
      } else {
        throw Exception('User ID is null or empty');
      }
    } catch (e) {
      print('Error updating profile in Firestore: $e');
      throw e;
    }
  }

  void _showSnackBar(String title, String message, ContentType contentType) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: contentType,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromSource(ImageSource.gallery);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImageFromSource(ImageSource.camera);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.deepOrange,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      print('Starting image picker...');
      
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        print('Image picked: ${pickedFile.path}');
        
        setState(() {
          isUploading = true;
        });

        // Check file size
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        print('File size: $fileSize bytes');
        
        if (fileSize > 10 * 1024 * 1024) { // 10MB limit
          throw Exception('Image file is too large. Please select a smaller image.');
        }

        // Upload to Cloudinary
        print('Starting Cloudinary upload...');
        String imageUrl = await _uploadToCloudinary(file);
        print('Cloudinary upload completed: $imageUrl');
        
        // Update Firestore
        print('Updating Firestore...');
        await _updateProfilePicture(imageUrl);
        print('Firestore update completed');
        
        // Update local state
        setState(() {
          profile = imageUrl;
          isUploading = false;
        });

        // Save to SharedPreferences
        await SharedPreferenceHelper().saveUserProfile(imageUrl);
        print('SharedPreferences updated with new profile: $imageUrl');
        
        _showSnackBar('Success!', 'Profile picture updated successfully', ContentType.success);
      } else {
        print('No image selected');
        setState(() {
          isUploading = false;
        });
      }
    } catch (e) {
      print('Error in _pickImageFromSource: $e');
      setState(() {
        isUploading = false;
      });
      
      String errorMessage = e.toString();
      if (errorMessage.contains('permissions')) {
        errorMessage = 'Permission denied. Please allow camera/gallery access.';
      } else if (errorMessage.contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (errorMessage.contains('timeout')) {
        errorMessage = 'Upload timeout. Please try again.';
      } else if (errorMessage.contains('too large')) {
        errorMessage = 'Image file is too large. Please select a smaller image.';
      } else {
        errorMessage = 'Failed to upload image. Please try again.';
      }
      
      _showSnackBar('Error!', errorMessage, ContentType.failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Container with gradient
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(90),
                        bottomRight: Radius.circular(90)
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.03),
                        // Profile Image with Upload Button
                        Stack(
                          children: [
                            Container(
                              height: screenWidth * 0.35,
                              width: screenWidth * 0.35,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: profile != null && profile!.isNotEmpty
                                    ? Image.network(
                                        profile!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          print('Error loading profile image: $error');
                                          return Icon(
                                            Icons.person,
                                            size: screenWidth * 0.15,
                                            color: Colors.grey[400],
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: screenWidth * 0.15,
                                        color: Colors.grey[400],
                                      ),
                              ),
                            ),
                            // Upload/Loading indicator
                            if (isUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                            // Camera Icon
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: isUploading ? null : _showImagePickerBottomSheet,
                                child: Container(
                                  height: screenWidth * 0.1,
                                  width: screenWidth * 0.1,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.deepOrange,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: screenWidth * 0.05,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Name
                        Text(
                          name ?? "Loading...",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                      ],
                    ),
                  ),
                  
                  // Profile Information Cards
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      children: [
                        // Contact Information Card
                        Card(
                          elevation: 3,
                          color: const Color.fromARGB(255, 237, 237, 237),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                              topRight: Radius.circular(50)
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Information',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                
                                // Phone
                                if (phone != null && phone!.isNotEmpty)
                                  _buildInfoRow(
                                    icon: Icons.phone,
                                    label: 'Phone',
                                    value: phone!,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                
                                if (phone != null && phone!.isNotEmpty && 
                                    email != null && email!.isNotEmpty)
                                  Divider(height: screenHeight * 0.03),
                                
                                // Email
                                if (email != null && email!.isNotEmpty)
                                  _buildInfoRow(
                                    icon: Icons.email,
                                    label: 'Email',
                                    value: email!,
                                    isSmallScreen: isSmallScreen,
                                  ),
                                
                                SizedBox(height: screenHeight * 0.03),
                        
                                // Action Buttons
                                _buildActionButton(
                                  text: "Delete Account",
                                  icon: Icons.delete_outline,
                                  color: Colors.red,
                                  isOutlined: true,
                                  onPressed: () {
                                    _showDeleteConfirmationDialog();
                                  },
                                  screenWidth: screenWidth,
                                ),
                                
                                SizedBox(height: screenHeight * 0.02),
                                
                                _buildActionButton(
                                  text: "Logout",
                                  icon: Icons.logout,
                                  color: Colors.deepOrange,
                                  isOutlined: false,
                                  onPressed: () {
                                    _showLogoutConfirmationDialog();
                                  },
                                  screenWidth: screenWidth,
                                ),
                                
                                SizedBox(height: screenHeight * 0.03),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isSmallScreen,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.deepOrange,
            size: isSmallScreen ? 16 : 18,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required bool isOutlined,
    required VoidCallback onPressed,
    required double screenWidth,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: color),
              label: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: screenWidth < 360 ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.white),
              label: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth < 360 ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Color.fromARGB(255, 237, 237, 237),
          title: Text('Delete Account', style: AppWidget.getPlaywriteOrangeTitleTextStyle()),
          content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Color.fromARGB(255, 237, 237, 237),
          title: Text('Logout', style: AppWidget.getPlayLargeOrangeTextStyle()),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await Authmethods().deleteUser();
      _showSnackBar('Account Deleted', 'Your account has been deleted', ContentType.warning);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Userlogin()),
      );
    } catch (e) {
      print('Error deleting account: $e');
      _showSnackBar('Error!', 'Failed to delete account', ContentType.failure);
    }
  }

  Future<void> _logout() async {
    try {
      await SharedPreferenceHelper().clearUserData();
      await Authmethods().SignOut();
      _showSnackBar('Success!', 'Account Signed Out', ContentType.success);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Userlogin()),
      );
    } catch (e) {
      print('Error signing out: $e');
      _showSnackBar('Error!', 'Failed to sign out', ContentType.failure);
    }
  }
}