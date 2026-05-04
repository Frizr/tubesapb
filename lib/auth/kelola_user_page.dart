import 'package:cashier/controller/authcontroller.dart';
import 'package:cashier/controller/usercontroller.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class KelolaUserPage extends StatefulWidget {
  const KelolaUserPage({super.key});

  @override
  State<KelolaUserPage> createState() => _KelolaUserPageState();
}

class _KelolaUserPageState extends State<KelolaUserPage> {
  final AuthController _auth = Get.find<AuthController>();
  final UserController _userCtrl = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    // Guard: Kick out if not admin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_auth.isKaryawan) {
        Get.back();
        Get.rawSnackbar(
          messageText: const Text(
            'Akses ditolak. Halaman ini hanya untuk admin.',
            style: TextStyle(
                fontFamily: 'm',
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.danger,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Kelola Pengguna',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'm',
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (_userCtrl.users.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada pengguna',
              style: TextStyle(fontFamily: 'm', color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _userCtrl.users.length,
          itemBuilder: (context, index) {
            final user = _userCtrl.users[index];
            final String docId = user['id'];
            final String nama = user['nama'] ?? '';
            final String username = user['username'] ?? '';
            final String role = user['role'] ?? 'karyawan';
            final bool isAktif = user['aktif'] ?? false;
            final bool isAdminRole = role == 'admin';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Slidable(
                key: ValueKey(docId),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      label: 'Hapus',
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_outline_rounded,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      onPressed: (context) => _userCtrl.deleteUser(docId),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isAdminRole
                              ? AppColors.navy.withOpacity(0.1)
                              : AppColors.teal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontFamily: 'm',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isAdminRole
                                  ? AppColors.navy
                                  : AppColors.teal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              style: const TextStyle(
                                fontFamily: 'm',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '@$username',
                                  style: const TextStyle(
                                    fontFamily: 'm',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isAdminRole
                                        ? AppColors.navy
                                        : AppColors.teal,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    role.toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'm',
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Toggle Active
                      Switch(
                        value: isAktif,
                        activeColor: AppColors.teal,
                        onChanged: (val) {
                          _userCtrl.toggleAktif(docId, !val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        onPressed: _showAddUserSheet,
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }

  void _showAddUserSheet() {
    final namaCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'karyawan';
    bool obscurePass = true;

    Get.bottomSheet(
      StatefulBuilder(builder: (context, setModalState) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tambah Pengguna Baru',
                  style: TextStyle(
                    fontFamily: 'm',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 20),

                // Nama
                _buildField(
                  ctrl: namaCtrl,
                  label: 'Nama Lengkap',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 16),

                // Username
                _buildField(
                  ctrl: usernameCtrl,
                  label: 'Username',
                  icon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: 16),

                // Password
                TextField(
                  controller: passCtrl,
                  obscureText: obscurePass,
                  style: const TextStyle(fontFamily: 'm', fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(
                        fontFamily: 'm', fontSize: 13, color: Colors.grey),
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePass ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setModalState(() {
                          obscurePass = !obscurePass;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.bgLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Role
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRole,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      style: const TextStyle(
                        fontFamily: 'm',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'karyawan', child: Text('Karyawan')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedRole = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                Obx(() {
                  final isLoading = _userCtrl.isLoading.value;
                  return SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isLoading
                          ? null
                          : () async {
                              final nm = namaCtrl.text;
                              final un = usernameCtrl.text;
                              final pw = passCtrl.text;

                              if (nm.isEmpty || un.isEmpty || pw.isEmpty) {
                                Get.rawSnackbar(
                                  messageText: const Text('Semua kolom harus diisi',
                                      style: TextStyle(
                                          fontFamily: 'm',
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  backgroundColor: AppColors.danger,
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 12,
                                );
                                return;
                              }

                              final success = await _userCtrl.createUser(
                                nama: nm,
                                username: un,
                                password: pw,
                                role: selectedRole,
                              );

                              if (success) {
                                Get.back(); // close bottom sheet
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text(
                              'Simpan Pengguna',
                              style: TextStyle(
                                  fontFamily: 'm',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontFamily: 'm', fontSize: 14),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(
            fontFamily: 'm', fontSize: 13, color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: AppColors.bgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// PageView slot placeholder — mapped to index 4 in main.dart
class KelolaPlaceholder extends StatelessWidget {
  const KelolaPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgLight,
    );
  }
}
