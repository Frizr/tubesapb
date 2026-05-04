import 'package:cashier/controller/barangcontroller.dart';
import 'package:cashier/controller/transaksicontroller.dart';
import 'package:cashier/manage/formater.dart';
import 'package:cashier/notification/notification_helper.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:cashier/transaksi/history.dart';
import 'package:cashier/transaksi/widget/listsearch.dart';
// search page not needed when embedding product list
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Transaksi extends StatefulWidget {
  @override
  _TransaksiState createState() => _TransaksiState();
}

class _TransaksiState extends State<Transaksi> {
  TransaksiController t = Get.put(TransaksiController());
  Getbarang b = Get.put(Getbarang());
  final TextEditingController _searchController = TextEditingController();

  void _showPaymentDialog(int totalBayar) {
    String selectedMetode = 'Cash';
    TextEditingController cashController = TextEditingController();
    int kembalian = 0;
    bool showKembalian = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pembayaran',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          uang.format(totalBayar),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _paymentChip('Cash', Icons.money_rounded,
                          selectedMetode == 'Cash', () {
                        setModalState(() {
                          selectedMetode = 'Cash';
                          showKembalian = false;
                        });
                      }),

                      _paymentChip('QRIS', Icons.qr_code_rounded,
                          selectedMetode == 'QRIS', () {
                        setModalState(() {
                          selectedMetode = 'QRIS';
                          showKembalian = false;
                        });
                      }),
                    ],
                  ),
                  if (selectedMetode == 'Cash') ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Nominal Bayar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.teal.withOpacity(0.3),
                        ),
                      ),
                      child: TextField(
                        controller: cashController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Masukkan nominal',
                          border: InputBorder.none,
                          prefixText: 'Rp. ',
                          prefixStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        onChanged: (value) {
                          int nominal = int.tryParse(value) ?? 0;
                          setModalState(() {
                            kembalian = nominal - totalBayar;
                            showKembalian = nominal > 0;
                          });
                        },
                      ),
                    ),
                    if (showKembalian) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kembalian >= 0
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              kembalian >= 0 ? 'Kembalian' : 'Kurang',
                              style: TextStyle(
                                color: kembalian >= 0
                                    ? AppColors.success
                                    : AppColors.danger,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              uang.format(kembalian.abs()),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kembalian >= 0
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (selectedMetode == 'Cash' &&
                              cashController.text.isNotEmpty &&
                              kembalian < 0)
                          ? null
                          : () {
                              Navigator.of(ctx).pop();
                              t.addtransaksi(
                                data: b.beli,
                                bayar: totalBayar,
                                metode: selectedMetode,
                              );
                              b.hapusbeliall();
                              NotificationHelper.showTransactionSuccess(
                                total: totalBayar,
                                metode: selectedMetode,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Konfirmasi Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _paymentChip(
      String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.navy.withOpacity(0.1)
              : AppColors.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.navy : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? AppColors.navy : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.navy : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        const Icon(Icons.store, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Transaksi',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
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
                Get.to(() => History(),
                    transition: Transition.rightToLeftWithFade);
              },
              icon: const Icon(Icons.history_rounded, color: AppColors.navy),
              tooltip: 'Riwayat',
            ),
          ),
        ],
      ),
      body: GetBuilder<Getbarang>(
        builder: (val) {
          final cart = val.beli;
          Widget productListWidget() {
            // if user typed something, show search results (temu), otherwise show all products
            final queryNotEmpty = _searchController.text.trim().isNotEmpty;
            final hasil = queryNotEmpty ? val.temu : val.barang;

            if ((hasil.isEmpty) && queryNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Barang tidak ditemukan',
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  for (var a in hasil)
                    ListSearch(
                      kode: (a['data'] != null && (a['data']['bar'] ?? '') != null)
                          ? (a['data']['bar'] ?? '').toString()
                          : (a['bar'] ?? '').toString(),
                      id: (a['id'] ?? '').toString(),
                      nama: (a['data'] != null && (a['data']['nama'] ?? '') != null)
                          ? (a['data']['nama'] ?? '').toString()
                          : (a['nama'] ?? '').toString(),
                      harga: (a['data'] != null && a['data']['harga'] != null)
                          ? (a['data']['harga'] as num).toInt()
                          : 0,
                      stock: (a['data'] != null && a['data']['jumlah'] != null)
                          ? (a['data']['jumlah'] as num).toInt()
                          : 0,
                      x: false,
                      i: 0,
                    ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: Colors.transparent,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              b.cari(cari: value);
                            });
                          },
                          cursorColor: AppColors.navy,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Cari barang...',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content area
              Expanded(
                child: Column(
                  children: [
                    // selected items (cart)
                    if (cart.isNotEmpty)
                      Expanded(
                        flex: 4,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            children: [
                              for (var i = 0; i < cart.length; i++)
                                ListSearch(
                                  kode: (cart[i]['kode'] ?? '').toString(),
                                  id: (cart[i]['idb'] ?? cart[i]['id'] ?? '').toString(),
                                  nama: (cart[i]['nama'] ?? '').toString(),
                                  harga: (cart[i]['harga'] as num?)?.toInt() ?? 0,
                                  stock: (cart[i]['jumlah'] as num?)?.toInt() ?? 0,
                                  x: true,
                                  i: i,
                                  jumbel: (cart[i]['jumlahbeli'] as num?)?.toInt() ?? 0,
                                ),
                            ],
                          ),
                        ),
                      ),
                    // product list
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: productListWidget(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: GetBuilder<Getbarang>(
        builder: (val) {
          int totalBayar = 0;
          val.beli.forEach((item) {
            totalBayar += (item['totharga'] as num).toInt();
          });
          return val.beli.isNotEmpty
              ? InkWell(
                  onTap: () {
                    if (totalBayar == 0) return;
                    _showPaymentDialog(totalBayar);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 30),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navy.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.payment_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          uang.format(totalBayar),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(width: 40);
        },
      ),
    );
  }
}
