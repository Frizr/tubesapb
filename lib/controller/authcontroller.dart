import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────────────
  /// The currently logged-in user document (includes 'id' key injected on login).
  /// null = no one is logged in.
  final Rx<Map<String, dynamic>?> currentUser = Rx(null);

  /// True while a login/logout Firestore call is in progress.
  final RxBool isLoading = false.obs;

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoggedIn => currentUser.value != null;
  bool get isAdmin => currentUser.value?['role'] == 'admin';
  bool get isKaryawan => currentUser.value?['role'] == 'karyawan';
  String get displayName => currentUser.value?['nama'] ?? '';

  // ── Private ────────────────────────────────────────────────────────────────
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  // ── Methods ────────────────────────────────────────────────────────────────

  /// Queries Firestore for a matching username/password and logs the user in.
  Future<void> login(String username, String password) async {
    if (isLoading.value) return;

    // Guard: empty fields
    if (username.trim().isEmpty || password.trim().isEmpty) {
      _showError('Username dan password tidak boleh kosong');
      return;
    }

    isLoading.value = true;
    try {
      final QuerySnapshot snap = await _users
          .where('username', isEqualTo: username.trim())
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        _showError('Username tidak ditemukan');
        return;
      }

      final doc = snap.docs.first;
      final data = doc.data() as Map<String, dynamic>;

      // Check account status
      if (data['aktif'] != true) {
        _showError('Akun dinonaktifkan');
        return;
      }

      // Check password
      if (data['password'] != password) {
        _showError('Password salah');
        return;
      }

      // Success — inject document ID into the map so callers can reference it
      currentUser.value = {
        ...data,
        'id': doc.id,
      };

      debugPrint('[AuthController] Login berhasil: ${data['username']} (${data['role']})');

      // Navigate to main app shell
      Get.offAllNamed('/main');
    } catch (e) {
      debugPrint('[AuthController] Login error: $e');
      _showError('Terjadi kesalahan. Coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears the current session and sends the user back to LoginPage.
  Future<void> logout() async {
    currentUser.value = null;
    debugPrint('[AuthController] Logout berhasil.');
    Get.offAllNamed('/login');
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _showError(String message) {
    Get.rawSnackbar(
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      backgroundColor: const Color(0xFFEF4444), // AppColors.danger
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
}
