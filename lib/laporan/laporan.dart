import 'dart:io';

import 'package:cashier/controller/transaksicontroller.dart';
import 'package:cashier/manage/formater.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Laporan extends StatefulWidget {
  @override
  _LaporanState createState() => _LaporanState();
}

class _LaporanState extends State<Laporan> {
  int _selectedFilter = 0; // 0=Hari ini, 1=Minggu, 2=Bulan, 3=Semua
  final List<String> _filterLabels = [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
    'Semua'
  ];

  List _getFilteredTransactions(TransaksiController val) {
    switch (_selectedFilter) {
      case 0:
        return val.getTodayTransactions();
      case 1:
        return val.getWeekTransactions();
      case 2:
        return val.getMonthTransactions();
      default:
        return val.transaksi;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Laporan',
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
              color: AppColors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () => _exportCSV(),
              icon: const Icon(Icons.download_rounded, color: AppColors.teal),
              tooltip: 'Export CSV',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: GetBuilder<TransaksiController>(
          builder: (val) {
            final filteredTrx = _getFilteredTransactions(val);

            // Calculate totals
            int totalRevenue = 0;
            int totalCost = 0;
            Map<String, Map<String, dynamic>> stats = {};

            for (var wrap in filteredTrx) {
              var trx = wrap['data'] as Map<String, dynamic>;
              totalRevenue += (trx['bayar'] as num?)?.toInt() ?? 0;
              var items = trx['data'] as List<dynamic>? ?? [];
              for (var it in items) {
                String idb =
                    (it['idb'] ?? it['id'] ?? it['kode'] ?? '').toString();
                int qty = (it['jumlahbeli'] as num?)?.toInt() ?? 0;
                int revenue = (it['totharga'] as num?)?.toInt() ??
                    ((it['harga'] as num?)?.toInt() ?? 0) * qty;
                int modalVal = (it['modal'] as num?)?.toInt() ?? 0;
                int cost = modalVal * qty;
                totalCost += cost;
                if (!stats.containsKey(idb)) {
                  stats[idb] = {
                    'name': it['nama'] ?? '',
                    'qty': qty,
                    'revenue': revenue,
                    'cost': cost,
                  };
                } else {
                  stats[idb]!['qty'] = (stats[idb]!['qty'] as int) + qty;
                  stats[idb]!['revenue'] =
                      (stats[idb]!['revenue'] as int) + revenue;
                  stats[idb]!['cost'] = (stats[idb]!['cost'] as int) + cost;
                }
              }
            }

            var entries = stats.entries.toList();
            entries.sort((a, b) =>
                (b.value['qty'] as int).compareTo(a.value['qty'] as int));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter tabs
                _buildFilterTabs(),
                const SizedBox(height: 16),

                // Summary cards
                _buildSummaryCards(
                    totalRevenue, totalCost, filteredTrx.length),
                const SizedBox(height: 20),

                // Bar Chart
                _buildBarChart(val),
                const SizedBox(height: 20),

                // Pembukuan Kasir
                _buildPembukuan(filteredTrx),
                const SizedBox(height: 20),

                // Top selling products
                _buildTopProducts(entries),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_filterLabels.length, (i) {
          bool isActive = _selectedFilter == i;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = i;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _filterLabels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color:
                          isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCards(int totalRevenue, int totalCost, int count) {
    int profit = totalRevenue - totalCost;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                label: 'Total Penjualan',
                value: uang.format(totalRevenue),
                icon: Icons.trending_up_rounded,
                gradient: AppColors.primaryGradient,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                label: 'Total Modal',
                value: uang.format(totalCost),
                icon: Icons.account_balance_wallet_outlined,
                gradient: AppColors.amberGradient,
                textDark: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statCard(
                label: 'Laba / Rugi',
                value: uang.format(profit),
                icon: profit >= 0
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                gradient: profit >= 0
                    ? const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34D399)])
                    : const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFF87171)]),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                label: 'Jumlah Transaksi',
                value: count.toString(),
                icon: Icons.receipt_long_rounded,
                gradient: AppColors.tealGradient,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required LinearGradient gradient,
    bool textDark = false,
  }) {
    final textColor = textDark ? AppColors.textPrimary : Colors.white;
    final subColor = textDark ? AppColors.textSecondary : Colors.white70;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, color: subColor)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(TransaksiController tVal) {
    final data = tVal.getLast7DaysTotals();
    final maxVal = data.fold<int>(
        0, (prev, e) => (e['total'] as int) > prev ? (e['total'] as int) : prev);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppColors.navy, size: 20),
              SizedBox(width: 8),
              Text(
                'Grafik Penjualan 7 Hari',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final total = d['total'] as int;
                final date = d['date'] as DateTime;
                double fraction = maxVal > 0 ? total / maxVal : 0;
                if (fraction < 0.03 && total > 0) fraction = 0.03;

                final isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month &&
                    date.year == DateTime.now().year;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (total > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              _formatShort(total),
                              style: TextStyle(
                                fontSize: 9,
                                color: isToday
                                    ? AppColors.teal
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          height: 100 * fraction,
                          decoration: BoxDecoration(
                            gradient: isToday
                                ? AppColors.tealGradient
                                : AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('EEE', 'id_ID').format(date),
                          style: TextStyle(
                            fontSize: 10,
                            color: isToday
                                ? AppColors.teal
                                : AppColors.textSecondary,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatShort(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}jt';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}rb';
    return value.toString();
  }

  Widget _buildPembukuan(List filteredTrx) {
    // Group transactions by date
    Map<String, List<dynamic>> grouped = {};
    for (var wrap in filteredTrx) {
      var trx = wrap['data'] as Map<String, dynamic>;
      DateTime? tglDate;
      try {
        tglDate = trx['tgl'].toDate();
      } catch (e) {
        continue;
      }
      if (tglDate == null) continue;
      String dateKey = DateFormat('yyyy-MM-dd').format(tglDate);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(wrap);
    }

    if (grouped.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort dates descending
    var sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.navy, size: 20),
              SizedBox(width: 8),
              Text(
                'Pembukuan Kasir',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortedDates.take(7).map((dateKey) {
            final dayTrx = grouped[dateKey]!;
            int dayTotal = 0;
            for (var wrap in dayTrx) {
              var trx = wrap['data'] as Map<String, dynamic>;
              dayTotal += (trx['bayar'] as num?)?.toInt() ?? 0;
            }
            DateTime date = DateTime.parse(dateKey);
            bool isToday = dateKey ==
                DateFormat('yyyy-MM-dd').format(DateTime.now());

            return GestureDetector(
              onTap: () {
                _showDailyTransactions(context, date, dayTrx);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isToday
                    ? AppColors.teal.withOpacity(0.05)
                    : AppColors.bgLight,
                borderRadius: BorderRadius.circular(10),
                border: isToday
                    ? Border.all(color: AppColors.teal.withOpacity(0.2))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.teal.withOpacity(0.1)
                          : AppColors.navy.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? AppColors.teal
                                : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('MMM', 'id_ID').format(date),
                          style: TextStyle(
                            fontSize: 9,
                            color: isToday
                                ? AppColors.teal
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE', 'id_ID').format(date),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${dayTrx.length} transaksi',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    uang.format(dayTotal),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isToday ? AppColors.teal : AppColors.navy,
                    ),
                  ),
                ],
              ),
            ));
          }),
        ],
      ),
    );
  }

  void _showDailyTransactions(BuildContext context, DateTime date, List<dynamic> dayTrx) {
    String dateStr = DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaksi $dateStr',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: dayTrx.length,
                itemBuilder: (context, index) {
                  var wrap = dayTrx[index];
                  var trx = wrap['data'] as Map<String, dynamic>;
                  var bayar = (trx['bayar'] as num?)?.toInt() ?? 0;
                  var id = wrap['id'] ?? 'Unknown';
                  var tglDate = trx['tgl']?.toDate();
                  String timeStr = tglDate != null ? DateFormat('HH:mm').format(tglDate) : '';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.bgLight,
                      child: Icon(Icons.receipt, color: AppColors.navy),
                    ),
                    title: Text(
                      'Transaksi $id',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(timeStr, style: const TextStyle(fontSize: 11)),
                    trailing: Text(
                      uang.format(bayar),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  Widget _buildTopProducts(

      List<MapEntry<String, Map<String, dynamic>>> entries) {
    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(width: 12),
            Text(
              'Belum ada data produk terjual',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events_rounded,
                  color: AppColors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Produk Terlaris',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...entries.take(10).toList().asMap().entries.map((entry) {
            int index = entry.key;
            final v = entry.value.value;
            int revenue = v['revenue'] as int;
            int cost = v['cost'] as int;
            int profit = revenue - cost;

            Color medalColor;
            if (index == 0) {
              medalColor = const Color(0xFFFFD700);
            } else if (index == 1) {
              medalColor = const Color(0xFFC0C0C0);
            } else if (index == 2) {
              medalColor = const Color(0xFFCD7F32);
            } else {
              medalColor = AppColors.textSecondary;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: medalColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: medalColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v['name'].toString(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Terjual: ${v['qty']}  •  ${uang.format(revenue)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: profit >= 0
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      uang.format(profit),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            profit >= 0 ? AppColors.success : AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _exportCSV() async {
    final t = Get.find<TransaksiController>();
    int totalRevenue = 0;
    int totalCost = 0;
    Map<String, Map<String, dynamic>> stats = {};
    for (var wrap in t.transaksi) {
      var trx = wrap['data'] as Map<String, dynamic>;
      totalRevenue += (trx['bayar'] as num?)?.toInt() ?? 0;
      var items = trx['data'] as List<dynamic>? ?? [];
      for (var it in items) {
        String idb = (it['idb'] ?? it['id'] ?? it['kode'] ?? '').toString();
        int qty = (it['jumlahbeli'] as num?)?.toInt() ?? 0;
        int revenue = (it['totharga'] as num?)?.toInt() ??
            ((it['harga'] as num?)?.toInt() ?? 0) * qty;
        int modalVal = (it['modal'] as num?)?.toInt() ?? 0;
        int cost = modalVal * qty;
        totalCost += cost;
        if (!stats.containsKey(idb)) {
          stats[idb] = {
            'name': it['nama'] ?? '',
            'qty': qty,
            'revenue': revenue,
            'cost': cost,
          };
        } else {
          stats[idb]!['qty'] = (stats[idb]!['qty'] as int) + qty;
          stats[idb]!['revenue'] = (stats[idb]!['revenue'] as int) + revenue;
          stats[idb]!['cost'] = (stats[idb]!['cost'] as int) + cost;
        }
      }
    }

    List<List<String>> rows = [];
    rows.add(['Product ID', 'Name', 'Qty Sold', 'Revenue', 'Cost', 'Profit']);
    stats.forEach((id, v) {
      int qty = v['qty'] as int;
      int revenue = v['revenue'] as int;
      int cost = v['cost'] as int;
      int profit = revenue - cost;
      rows.add([
        id,
        v['name'].toString(),
        qty.toString(),
        revenue.toString(),
        cost.toString(),
        profit.toString()
      ]);
    });
    rows.add([]);
    rows.add([
      'Total',
      '',
      '',
      totalRevenue.toString(),
      totalCost.toString(),
      (totalRevenue - totalCost).toString()
    ]);

    String csv = rows
        .map((r) => r.map((e) => '"${e.replaceAll('"', '""')}"').join(','))
        .join('\n');

    try {
      Directory? dir;
      try {
        dir = await getExternalStorageDirectory();
      } catch (e) {
        dir = await getApplicationDocumentsDirectory();
      }
      final path = dir?.path ?? '.';
      final file = File(
          '$path/laporan_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);
      Get.snackbar(
        'Sukses',
        'Laporan diekspor: ${file.path}',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Ekspor laporan gagal: $e',
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
}