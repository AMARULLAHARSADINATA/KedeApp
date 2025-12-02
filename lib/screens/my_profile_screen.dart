// lib/screens/my_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Akses User Login
import 'package:cloud_firestore/cloud_firestore.dart'; // Database Profile
import '../main.dart'; // Akses warna kPrimaryColor, dll

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  // Referensi ke koleksi 'users' di Firestore
  final CollectionReference usersCollection = 
      FirebaseFirestore.instance.collection('users');

  // --- FUNGSI UPDATE (EDIT DATA) ---
  Future<void> _editField(String fieldName, String currentValue) async {
    String newValue = currentValue;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("Edit $fieldName", style: const TextStyle(color: kTextColor)),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter new $fieldName",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) => newValue = value,
        ),
        actions: [
          // Tombol Batal
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          // Tombol Simpan
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              
              // Update ke Firestore
              if (newValue.isNotEmpty && currentUser != null) {
                await usersCollection.doc(currentUser!.uid).set({
                  fieldName: newValue, // field yang diedit
                }, SetOptions(merge: true)); // merge=true agar data lain tidak hilang
              }
            },
            child: const Text('Save', style: TextStyle(color: kPrimaryColor)),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI DELETE (HAPUS AKUN) ---
  Future<void> _deleteAccount() async {
    // Konfirmasi dulu
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Akun?"),
        content: const Text("Tindakan ini tidak bisa dibatalkan. Data Anda akan hilang permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    ) ?? false;

    if (confirm && currentUser != null) {
      try {
        // 1. Hapus data di Firestore
        await usersCollection.doc(currentUser!.uid).delete();
        
        // 2. Hapus User Auth (Perlu Re-login biasanya untuk keamanan, tapi ini basic logicnya)
        await currentUser!.delete();

        if (mounted) {
          Navigator.pop(context); // Kembali ke halaman sebelumnya (biasanya login)
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
        }
      }
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
      
      // --- STREAM BUILDER (REALTIME READ) ---
      body: StreamBuilder<DocumentSnapshot>(
        stream: usersCollection.doc(currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          // 2. Ambil Data (Handle jika dokumen belum ada/baru register)
          if (snapshot.hasData) {
            Map<String, dynamic>? userData = snapshot.data!.data() as Map<String, dynamic>?;

            // Default value jika data belum diisi di database
            String name = userData?['name'] ?? currentUser?.displayName ?? 'No Name';
            String job = userData?['job'] ?? 'Tap to add job';
            String desc = userData?['description'] ?? 'Tap to add bio/description...';
            String phone = userData?['phone'] ?? 'Tap to add phone';
            String address = userData?['address'] ?? 'Tap to add address';
            String totalOrder = userData?['totalOrder'] ?? '0';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // --- GAMBAR PROFIL ---
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                      image: const DecorationImage(
                        // Menggunakan gambar aset default
                        image: AssetImage('assets/images/profile_picture.jpg'), 
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // --- NAMA & PEKERJAAN (EDITABLE) ---
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit, size: 16, color: kPrimaryColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  GestureDetector(
                    onTap: () => _editField('job', job),
                    child: Text(
                      job,
                      style: const TextStyle(color: kTextLightColor, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // --- DESKRIPSI (EDITABLE) ---
                  GestureDetector(
                    onTap: () => _editField('description', desc),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!)
                      ),
                      child: Text(
                        desc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: kTextLightColor,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // --- DAFTAR INFO (CRUD) ---
                  _buildProfileInfoRow('Email Address', currentUser?.email ?? 'No Email', isEditable: false), // Email tidak bisa diedit sembarangan
                  _buildProfileInfoRow('Phone', phone, fieldKey: 'phone'),
                  _buildProfileInfoRow('Shipping Address', address, fieldKey: 'address'),
                  _buildProfileInfoRow('Total Order', totalOrder, fieldKey: 'totalOrder', showDivider: false),
                  
                  const SizedBox(height: 40),
                  
                  // --- TOMBOL DELETE ACCOUNT ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _deleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50], // Merah muda
                        foregroundColor: Colors.red,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: const Text("Delete Account"),
                    ),
                  )
                ],
              ),
            );
          } else {
            return const Center(child: Text("Error fetching data"));
          }
        },
      ),
    );
  }

  // Widget helper yang sudah dimodifikasi agar bisa diklik (Tap to Edit)
  Widget _buildProfileInfoRow(String title, String value, {
    bool showDivider = true, 
    bool isEditable = true,
    String? fieldKey, // Nama field di database (misal: 'address')
  }) {
    return Column(
      children: [
        InkWell(
          // Jika isEditable true, maka jalankan fungsi edit saat diklik
          onTap: isEditable && fieldKey != null 
              ? () => _editField(fieldKey, value) 
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kTextLightColor,
                    fontSize: 16,
                  ),
                ),
                // Row untuk Value + Icon Edit Kecil
                Row(
                  children: [
                    SizedBox(
                      width: 150, // Batasi lebar teks agar tidak overflow
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isEditable) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
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