import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Getbarang extends GetxController {
  CollectionReference dbbarang =
      FirebaseFirestore.instance.collection('barang');
  List barang = [];
  List temu = [];
  List beli = [];
  List sortgl = [];

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
    temu = barang
        .where(
          (element) => element.toString().contains(
                cari.toLowerCase(),
              ),
        )
        .toList();
    update();
  }

  void getbarang() {
    barang.clear();
    dbbarang
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
            update();
            // print(barang);
            // update();
          },
        );
        update();
      },
    );

    update();
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
      margin: EdgeInsets.all(15),
      borderRadius: 15,
      backgroundColor: Colors.red,
      forwardAnimationCurve: Curves.elasticInOut,
      reverseAnimationCurve: Curves.elasticOut,
      messageText: Row(
        children: [
          Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
          ),
          Text(
            "$nama berhasil dihapus",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
    update();
  }
}
