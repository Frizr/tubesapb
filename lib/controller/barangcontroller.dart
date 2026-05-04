import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Getbarang extends GetxController {
  CollectionReference dbbarang =
      FirebaseFirestore.instance.collection('barang');
  StreamSubscription? _sub;
  List barang = [];
  List temu = [];
  List beli = [];
  List sortgl = [];
  String searchQueryBarang = '';
  String sortOptionBarang = 'terbaru';

  void setSearchQueryBarang(String q) {
    searchQueryBarang = q.toLowerCase();
    update();
  }

  void setSortOptionBarang(String option) {
    sortOptionBarang = option;
    update();
  }

  List get displayBarang {
    List result = List.from(barang);
    if (searchQueryBarang.isNotEmpty) {
      result = result.where((element) {
        try {
          final data = element['data'] as Map<String, dynamic>?;
          final name = (data?['nama'] ?? '').toString().toLowerCase();
          final code = (data?['bar'] ?? '').toString().toLowerCase();
          return name.contains(searchQueryBarang) || code.contains(searchQueryBarang);
        } catch (e) {
          return element.toString().toLowerCase().contains(searchQueryBarang);
        }
      }).toList();
    }
    
    // Sort
    if (sortOptionBarang == 'lama') {
      result.sort((a, b) {
         final dateA = (a['data']?['tgl'] as Timestamp?)?.toDate() ?? DateTime.now();
         final dateB = (b['data']?['tgl'] as Timestamp?)?.toDate() ?? DateTime.now();
         return dateA.compareTo(dateB);
      });
    } else if (sortOptionBarang == 'terbaru') {
      result.sort((a, b) {
         final dateA = (a['data']?['tgl'] as Timestamp?)?.toDate() ?? DateTime.now();
         final dateB = (b['data']?['tgl'] as Timestamp?)?.toDate() ?? DateTime.now();
         return dateB.compareTo(dateA);
      });
    } else if (sortOptionBarang == 'stock banyak') {
      result.sort((a, b) => ((b['data']?['jumlah'] ?? 0) as num).compareTo((a['data']?['jumlah'] ?? 0) as num));
    } else if (sortOptionBarang == 'stock sedikit') {
      result.sort((a, b) => ((a['data']?['jumlah'] ?? 0) as num).compareTo((b['data']?['jumlah'] ?? 0) as num));
    } else if (sortOptionBarang == 'harga tinggi') {
      result.sort((a, b) => ((b['data']?['harga'] ?? 0) as num).compareTo((a['data']?['harga'] ?? 0) as num));
    } else if (sortOptionBarang == 'harga rendah') {
      result.sort((a, b) => ((a['data']?['harga'] ?? 0) as num).compareTo((b['data']?['harga'] ?? 0) as num));
    }
    
    return result;
  }

  hapusbeliall() {
    beli.clear();
    update();
  }

  hapusbeli({required int i}) {
    beli.removeAt(i);
    print(beli);
    update();
  }

  addbeli(
      {required String kode,
      required String nama,
      required int harga,
      required int jumlah,
      required String id,
      required int jumlahbeli,
      required int tot}) {
    beli.add({
      'idb': id,
      'kode': kode,
      'nama': nama,
      'harga': harga,
      'jumlah': jumlah,
      'jumlahbeli': jumlahbeli,
      'totharga': tot,
    });
    temu.clear();
    Get.back();
    update();
  }

  cari({required String cari}) async {
    final q = cari.trim().toLowerCase();
    if (q.isEmpty) {
      temu = [];
      update();
      return;
    }

    temu = barang.where((element) {
      try {
        final data = element['data'] as Map<String, dynamic>?;
        final name = (data?['nama'] ?? '').toString().toLowerCase();
        final code = (data?['bar'] ?? '').toString().toLowerCase();
        return name.contains(q) || code.contains(q);
      } catch (e) {
        // fallback to string match if structure unexpected
        return element.toString().toLowerCase().contains(q);
      }
    }).toList();
    update();
  }

  void getbarang() {
    _sub?.cancel();
    barang.clear();
    _sub = dbbarang
        .orderBy('tgl', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen(
      (querySnapshot) {
        barang.clear();
        querySnapshot.docs.forEach(
          (res) {
            barang.add(
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

  addbarang(
      {required String bar,
      required String nama,
      required int harga,
      required int jumlah,
      required int modal}) async {
    await dbbarang.add({
      'bar': bar,
      'nama': nama,
      'harga': harga,
      'jumlah': jumlah,
      'modal': modal,
      'tgl': DateTime.now(),
    });
    update();
  }

  editbarang(
      {required String id,
      required String nama,
      required int harga,
      required int stock,
      required int modal}) async {
    await dbbarang.doc(id).update({
      'nama': nama,
      'harga': harga,
      'jumlah': stock,
      'modal': modal,
    });
    update();
  }

  deletbarang({required String id, required String nama}) async {
    await dbbarang.doc(id).delete();
    Get.rawSnackbar(
      margin: const EdgeInsets.all(15),
      borderRadius: 15,
      backgroundColor: Colors.red,
      forwardAnimationCurve: Curves.elasticInOut,
      reverseAnimationCurve: Curves.elasticOut,
      messageText: Row(
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
          ),
          Text(
            "$nama berhasil dihapus",
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
    update();
  }

  /// Get products with low stock
  List<Map<String, dynamic>> getLowStockProducts({int threshold = 5}) {
    List<Map<String, dynamic>> lowStock = [];
    for (var item in barang) {
      final data = item['data'] as Map<String, dynamic>?;
      if (data != null) {
        int stock = (data['jumlah'] as num?)?.toInt() ?? 0;
        if (stock <= threshold) {
          lowStock.add({
            'id': item['id'],
            'nama': data['nama'] ?? '',
            'stock': stock,
          });
        }
      }
    }
    return lowStock;
  }

  /// Get total stock count
  int getTotalStock() {
    int total = 0;
    for (var item in barang) {
      final data = item['data'] as Map<String, dynamic>?;
      if (data != null) {
        total += (data['jumlah'] as num?)?.toInt() ?? 0;
      }
    }
    return total;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
