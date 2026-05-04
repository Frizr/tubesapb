import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:cashier/controller/barangcontroller.dart';

class TransaksiController extends GetxController {
  List transaksi = [];
  StreamSubscription? _sub;
  CollectionReference dbtransaksi =
      FirebaseFirestore.instance.collection('transaksi');

  addtransaksi({required var data, required int bayar, String metode = 'Cash'}) async {
    // Ensure each item has 'modal' using local cache (no Firestore reads) to avoid permission errors
    List itemsWithModal = [];
    Getbarang? gb;
    try {
      gb = Get.find<Getbarang>();
    } catch (e) {
      gb = null;
    }

    for (var item in data) {
      try {
        var newItem = Map<String, dynamic>.from(item);
        if (!newItem.containsKey('modal') || newItem['modal'] == null) {
          String idb = '';
          if (newItem.containsKey('idb') && newItem['idb'] != null)
            idb = newItem['idb'].toString();
          else if (newItem.containsKey('id') && newItem['id'] != null)
            idb = newItem['id'].toString();

          int modal = 0;
          if (idb.isNotEmpty && gb != null) {
            try {
              var found = gb.barang.firstWhere((e) => e['id'] == idb);
              if (found != null &&
                  found['data'] != null &&
                  (found['data'] as Map).containsKey('modal')) {
                modal = ((found['data'] as Map)['modal'] as num).toInt();
              }
            } catch (e) {
              modal = 0;
            }
          }
          newItem['modal'] = modal;
        }
        itemsWithModal.add(newItem);
      } catch (e) {
        itemsWithModal.add(item);
      }
    }

    await dbtransaksi.add({
      'data': itemsWithModal,
      'bayar': bayar,
      'metode': metode,
      'tgl': DateTime.now(),
    });
    // After saving transaction, decrement stock for sold items
    try {
      Map<String, int> qtyMap = {};
      for (var it in itemsWithModal) {
        String idb = '';
        if (it is Map && it.containsKey('idb') && it['idb'] != null)
          idb = it['idb'].toString();
        else if (it is Map && it.containsKey('id') && it['id'] != null)
          idb = it['id'].toString();
        int q = 0;
        try {
          q = (it['jumlahbeli'] as num?)?.toInt() ?? 0;
        } catch (e) {
          q = 0;
        }
        if (idb.isNotEmpty && q > 0) {
          qtyMap[idb] = (qtyMap[idb] ?? 0) + q;
        }
      }

      for (var entry in qtyMap.entries) {
        final idb = entry.key;
        final reduceBy = entry.value;
        final docRef = FirebaseFirestore.instance.collection('barang').doc(idb);
        try {
          await FirebaseFirestore.instance.runTransaction((tran) async {
            final snap = await tran.get(docRef);
            if (!snap.exists) return;
            final data = snap.data();
            int current = 0;
            if (data != null && data.containsKey('jumlah')) {
              try {
                current = (data['jumlah'] as num).toInt();
              } catch (e) {
                current = 0;
              }
            }
            int updated = current - reduceBy;
            if (updated < 0) updated = 0;
            tran.update(docRef, {'jumlah': updated});
          });
        } catch (e) {
          // ignore individual update errors
        }
      }
      // refresh local cache (stream listener should also update)
      try {
        final gb = Get.find<Getbarang>();
        gb.getbarang();
      } catch (e) {}
    } catch (e) {
      // ignore
    }

    update();
  }

  void gettransaksi() {
    _sub?.cancel();
    transaksi.clear();
    _sub = dbtransaksi
        .orderBy('tgl', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen(
      (querySnapshot) {
        transaksi.clear();
        querySnapshot.docs.forEach(
          (res) {
            transaksi.add(
              {
                'id': res.id,
                'data': res.data(),
              },
            );
          },
        );
        update();
      },
    );
  }

  /// Get transactions filtered by date range
  List getTransaksiByDateRange(DateTime start, DateTime end) {
    return transaksi.where((wrap) {
      try {
        var trx = wrap['data'] as Map<String, dynamic>;
        DateTime tgl = (trx['tgl'] as dynamic).toDate();
        return tgl.isAfter(start.subtract(const Duration(seconds: 1))) &&
            tgl.isBefore(end.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Get today's transactions
  List getTodayTransactions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getTransaksiByDateRange(startOfDay, endOfDay);
  }

  /// Get this month's transactions
  List getMonthTransactions() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getTransaksiByDateRange(startOfMonth, endOfMonth);
  }

  /// Get this week's transactions
  List getWeekTransactions() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return getTransaksiByDateRange(start, end);
  }

  /// Calculate total revenue from a list of transactions
  int calculateTotal(List trxList) {
    int total = 0;
    for (var wrap in trxList) {
      var trx = wrap['data'] as Map<String, dynamic>;
      total += (trx['bayar'] as num?)?.toInt() ?? 0;
    }
    return total;
  }

  /// Get daily totals for last 7 days (for chart)
  List<Map<String, dynamic>> getLast7DaysTotals() {
    List<Map<String, dynamic>> result = [];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final start = DateTime(day.year, day.month, day.day);
      final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
      final dayTrx = getTransaksiByDateRange(start, end);
      result.add({
        'date': day,
        'total': calculateTotal(dayTrx),
        'count': dayTrx.length,
      });
    }
    return result;
  }
  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
