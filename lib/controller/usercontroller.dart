import 'dart:async';

import 'package:cashier/controller/authcontroller.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  StreamSubscription? _sub;
  
  // Real-time list of users
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  /// Sets up a real-time listener for the 'users' collection
  void fetchUsers() {
    _sub?.cancel();
    _sub = _usersCollection
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen(
      (snap) {
        users.clear();
        for (var doc in snap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          users.add({
            'id': doc.id,
            ...data,
          });
        }
      },
      onError: (e) {
        debugPrint('[UserController] fetchUsers error: $e');
      },
    );
  }

  /// Creates a new user if the username is unique
  Future<bool> createUser({
    required String nama,
    required String username,
    required String password,
    required String role,
  }) async {
    if (isLoading.value) return false;
    isLoading.value = true;

    try {
      // Check if username already exists
      final query = await _usersCollection
          .where('username', isEqualTo: username.trim())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        _showError('Username sudah digunakan');
        return false;
      }

      await _usersCollection.add({
        'nama': nama.trim(),
        'username': username.trim(),
        'password': password,
        'role': role,
        'aktif': true,
        'createdAt': Timestamp.now(),
      });

      _showSuccess('Pengguna berhasil ditambahkan');
      return true;
    } catch (e) {
      debugPrint('[UserController] createUser error: $e');
      _showError('Gagal menambahkan pengguna');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Deletes a user document
  Future<void> deleteUser(String docId) async {
    final auth = Get.find<AuthController>();
    
    // Prevent deleting oneself
    if (auth.currentUser.value?['id'] == docId) {
      _showError('Tidak dapat menghapus akun Anda sendiri yang sedang aktif');
      return;
    }

    try {
      await _usersCollection.doc(docId).delete();
      _showSuccess('Pengguna berhasil dihapus');
    } catch (e) {
      debugPrint('[UserController] deleteUser error: $e');
      _showError('Gagal menghapus pengguna');
    }
  }

  /// Toggles the 'aktif' status of a user
  Future<void> toggleAktif(String docId, bool currentValue) async {
    final auth = Get.find<AuthController>();
    
    // Prevent disabling oneself
    if (auth.currentUser.value?['id'] == docId) {
      _showError('Tidak dapat menonaktifkan akun Anda sendiri');
      return;
    }

    try {
      await _usersCollection.doc(docId).update({
        'aktif': !currentValue,
      });
      // No success snackbar needed here as the UI switch updates instantly
    } catch (e) {
      debugPrint('[UserController] toggleAktif error: $e');
      _showError('Gagal memperbarui status');
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _showError(String message) {
    Get.rawSnackbar(
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: AppColors.danger,
      duration: const Duration(seconds: 3),
      icon: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.error_outline_rounded, color: Colors.white, size: 26),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontFamily: 'm',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    Get.rawSnackbar(
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: AppColors.success,
      duration: const Duration(seconds: 3),
      icon: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 26),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontFamily: 'm',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
