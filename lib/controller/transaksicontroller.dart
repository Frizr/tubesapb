import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:cashier/controller/barangcontroller.dart';

class TransaksiController extends GetxController {
  List transaksi = [];
  CollectionReference dbtransaksi =
      FirebaseFirestore.instance.collection('transaksi');

  addtransaksi({required var data, required int bayar}) async {
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
          if (newItem.containsKey('idb') && newItem['idb'] != null) idb = newItem['idb'].toString();
          else if (newItem.containsKey('id') && newItem['id'] != null) idb = newItem['id'].toString();

          int modal = 0;
          if (idb.isNotEmpty && gb != null) {
            try {
              var found = gb.barang.firstWhere((e) => e['id'] == idb);
              if (found != null && found['data'] != null && (found['data'] as Map).containsKey('modal')) {
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
      'tgl': DateTime.now(),
    });
    // After saving transaction, decrement stock for sold items
    try {
      Map<String, int> qtyMap = {};
      for (var it in itemsWithModal) {
        String idb = '';
        if (it is Map && it.containsKey('idb') && it['idb'] != null) idb = it['idb'].toString();
        else if (it is Map && it.containsKey('id') && it['id'] != null) idb = it['id'].toString();
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
            final data = snap.data() as Map<String, dynamic>?;
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
    transaksi.clear();
    dbtransaksi
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
}
