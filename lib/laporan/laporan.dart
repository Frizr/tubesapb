import 'dart:io';

import 'package:cashier/controller/transaksicontroller.dart';
import 'package:cashier/manage/formater.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class Laporan extends StatefulWidget {
  @override
  _LaporanState createState() => _LaporanState();
}

class _LaporanState extends State<Laporan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          shadowColor: Colors.black,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: Text(
            "Laporan",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                  // export CSV - write to app documents directory (no external storage permission needed)
                final t = Get.find<TransaksiController>();
                // generate CSV
                int totalRevenue = 0;
                int totalCost = 0;
                Map<String, Map<String, dynamic>> stats = {};
                for (var wrap in t.transaksi) {
                  var trx = wrap['data'] as Map<String, dynamic>;
                  totalRevenue += (trx['bayar'] as num).toInt();
                  var items = trx['data'] as List<dynamic>? ?? [];
                  for (var it in items) {
                    String idb = (it['idb'] ?? it['id'] ?? it['kode'] ?? '').toString();
                    int qty = (it['jumlahbeli'] as num?)?.toInt() ?? 0;
                    int revenue = (it['totharga'] as num?)?.toInt() ?? ((it['harga'] as num?)?.toInt() ?? 0) * qty;
                    int modal = (it['modal'] as num?)?.toInt() ?? 0;
                    int cost = modal * qty;
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
                  rows.add([id, v['name'].toString(), qty.toString(), revenue.toString(), cost.toString(), profit.toString()]);
                });
                rows.add([]);
                rows.add(['Total', '', '', totalRevenue.toString(), totalCost.toString(), (totalRevenue - totalCost).toString()]);

                String csv = rows.map((r) => r.map((e) => '"${e.replaceAll('"', '""')}"').join(',')).join('\n');

                try {
                  Directory? dir;
                  try {
                    dir = await getExternalStorageDirectory();
                  } catch (e) {
                    dir = await getApplicationDocumentsDirectory();
                  }
                  final path = dir?.path ?? '.';
                  final file = File('$path/laporan_${DateTime.now().millisecondsSinceEpoch}.csv');
                  await file.writeAsString(csv);
                  Get.snackbar('Sukses', 'Laporan diekspor: ${file.path}');
                } catch (e) {
                  Get.snackbar('Gagal', 'Ekspor laporan gagal: $e');
                }
              },
              icon: Icon(Icons.download_outlined, color: Colors.black),
            ),
            SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
            child: GetBuilder<TransaksiController>(
          init: TransaksiController(),
          builder: (val) {
            // aggregate sales
            int totalRevenue = 0;
            int totalCost = 0;
            Map<String, Map<String, dynamic>> stats = {};
            for (var wrap in val.transaksi) {
              var trx = wrap['data'] as Map<String, dynamic>;
              totalRevenue += (trx['bayar'] as num).toInt();
              var items = trx['data'] as List<dynamic>? ?? [];
              for (var it in items) {
                String idb = (it['idb'] ?? it['id'] ?? it['kode'] ?? '').toString();
                int qty = (it['jumlahbeli'] as num?)?.toInt() ?? 0;
                int revenue = (it['totharga'] as num?)?.toInt() ?? ((it['harga'] as num?)?.toInt() ?? 0) * qty;
                int modal = (it['modal'] as num?)?.toInt() ?? 0;
                int cost = modal * qty;
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

            // sort top selling
            var entries = stats.entries.toList();
            entries.sort((a, b) => (b.value['qty'] as int).compareTo(a.value['qty'] as int));

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ringkasan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Total Penjualan'), SizedBox(height: 8), Text(uang.format(totalRevenue), style: TextStyle(fontWeight: FontWeight.bold))])),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Total Biaya (modal)'), SizedBox(height: 8), Text(uang.format(totalCost), style: TextStyle(fontWeight: FontWeight.bold))])),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Laba / Rugi'), SizedBox(height: 8), Text(uang.format(totalRevenue - totalCost), style: TextStyle(fontWeight: FontWeight.bold, color: (totalRevenue - totalCost) >= 0 ? Colors.green : Colors.red))])),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text('Barang Terlaris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 10),
                  ...entries.take(10).map((e) {
                    final v = e.value;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(v['name'].toString()),
                      subtitle: Text('Terjual: ${v['qty']}  •  Pendapatan: ${uang.format(v['revenue'])}'),
                      trailing: Text('Profit: ${uang.format((v['revenue'] as int) - (v['cost'] as int))}', style: TextStyle(color: ((v['revenue'] as int) - (v['cost'] as int)) >= 0 ? Colors.green : Colors.red)),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        )));
  }
}
