// lib/screens/my_profile_screen.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isLoading = true;

  // DATA PROFILE (STATE)
  String name = 'No Name';
  String job = 'Tap to add job';
  String desc = 'Tap to add bio/description...';
  String phone = 'Tap to add phone';
  String address = 'Tap to add address';
  String totalOrder = '0';
  String email = 'No Email';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ================= LOAD PROFILE =================
  Future<void> _loadProfile() async {
    final response = await ApiService.getProfile();

    if (mounted && response != null) {
      setState(() {
        name = response['name'] ?? name;
        job = response['job'] ?? job;
        desc = response['description'] ?? desc;
        phone = response['phone'] ?? phone;
        address = response['address'] ?? address;
        totalOrder = response['totalOrder']?.toString() ?? totalOrder;
        email = response['email'] ?? email;
        _isLoading = false;
      });
    }
  }

  // ================= EDIT FIELD =================
  Future<void> _editField(String fieldName, String currentValue) async {
    String newValue = currentValue;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Edit $fieldName",
            style: const TextStyle(color: kTextColor)),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter new $fieldName",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) => newValue = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (newValue.isNotEmpty) {
                await ApiService.updateProfile({fieldName: newValue});
                _loadProfile();
              }
            },
            child:
                const Text('Save', style: TextStyle(color: kPrimaryColor)),
          ),
        ],
      ),
    );
  }

  // ================= DELETE ACCOUNT =================
  Future<void> _deleteAccount() async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Hapus Akun?"),
            content: const Text(
                "Tindakan ini tidak bisa dibatalkan. Data Anda akan hilang permanen."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Batal")),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await ApiService.deleteAccount();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kPrimaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // ===== FOTO =====
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                      image: const DecorationImage(
                        image:
                            AssetImage('assets/images/profile_picture.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== NAMA =====
                  GestureDetector(
                    onTap: () => _editField('name', name),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              color: kTextColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit,
                            size: 16, color: kPrimaryColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  GestureDetector(
                    onTap: () => _editField('job', job),
                    child: Text(job,
                        style: const TextStyle(
                            color: kTextLightColor, fontSize: 16)),
                  ),
                  const SizedBox(height: 24),

                  // ===== DESKRIPSI =====
                  GestureDetector(
                    onTap: () => _editField('description', desc),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        desc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: kTextLightColor,
                            fontSize: 16,
                            height: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildProfileInfoRow('Email Address', email,
                      isEditable: false),
                  _buildProfileInfoRow('Phone', phone,
                      fieldKey: 'phone'),
                  _buildProfileInfoRow('Shipping Address', address,
                      fieldKey: 'address'),
                  _buildProfileInfoRow('Total Order', totalOrder,
                      showDivider: false),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _deleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Delete Account"),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildProfileInfoRow(
    String title,
    String value, {
    bool showDivider = true,
    bool isEditable = true,
    String? fieldKey,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: isEditable && fieldKey != null
              ? () => _editField(fieldKey, value)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: kTextLightColor, fontSize: 16)),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: kTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (isEditable) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios,
                          size: 12, color: Colors.grey),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: Colors.black12),
      ],
    );
  }
}
