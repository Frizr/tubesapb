import 'package:cashier/controller/transaksicontroller.dart';
import 'package:cashier/transaksi/widget/contenthis.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransaksiController>(
      builder: (val) {
        return Scaffold(
          backgroundColor: AppColors.bgLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.navy),
            title: const Text(
              'Riwayat Transaksi',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '${val.transaksi.length} transaksi',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: val.transaksi.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: AppColors.textSecondary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada transaksi',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (var a in val.transaksi)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ContentHis(a: a),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
