import 'package:cashier/barang/widget/addbarang/addbarang.dart';
import 'package:cashier/barang/widget/list/listbarang.dart';
import 'package:cashier/barang/widget/totalup.dart';
import 'package:cashier/controller/authcontroller.dart';
import 'package:cashier/controller/barangcontroller.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class Barang extends StatefulWidget {
  @override
  _BarangState createState() => _BarangState();
}

class _BarangState extends State<Barang> {
  Getbarang b = Get.put(Getbarang());
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.bgLight,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: isSearching
                ? TextField(
                    controller: searchController,
                    autofocus: true,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari Produk...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.5),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      b.setSearchQueryBarang(val);
                    },
                  )
                : const Text(
                    'Produk',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                      if (!isSearching) {
                        searchController.clear();
                        b.setSearchQueryBarang('');
                      }
                    });
                  },
                  icon: Icon(isSearching ? Icons.close : Icons.search, color: AppColors.navy),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TotalUp(),
                ),
                const SizedBox(height: 8),
                ListBarang(),
              ],
            ),
          ),
          floatingActionButton: Obx(() {
            final isAdmin = Get.find<AuthController>().isAdmin;
            if (!isAdmin || isKeyboardVisible) return const SizedBox.shrink();
            return FloatingActionButton.extended(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                onPressed: () {
                  Get.bottomSheet(
                    AddBaranG(),
                    isScrollControlled: true,
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Tambah Produk',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              );
          }),
        );
      },
    );
  }
}
