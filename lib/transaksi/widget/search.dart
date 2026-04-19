import 'package:cashier/controller/barangcontroller.dart';
import 'package:cashier/transaksi/widget/listsearch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// scan removed: searches no longer use camera

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Getbarang b = Get.put(Getbarang());
  TextEditingController barang = TextEditingController();

  Widget sc() {
    return Container(
      height: 40,
      padding: EdgeInsets.only(left: 15, right: 0, bottom: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            b.cari(cari: value);
          });
        },
        cursorColor: Colors.black,
        style: TextStyle(
          fontSize: 13,
        ),
        controller: barang,
        decoration: InputDecoration(
          hintText: "Cari barang",
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          b.temu.clear();
          Get.back();
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: sc(),
          ),
          body: SizedBox.expand(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  GetBuilder<Getbarang>(
                    init: Getbarang(),
                    builder: (val) {
                      return Column(
                        children: [
                          for (var a in val.temu)
                            ListSearch(
                              kode: (a['data'] != null &&
                                      (a['data']['bar'] ?? '') != null)
                                  ? (a['data']['bar'] ?? '').toString()
                                  : (a['bar'] ?? '').toString(),
                              id: (a['id'] ?? '').toString(),
                              nama: (a['data'] != null &&
                                      (a['data']['nama'] ?? '') != null)
                                  ? (a['data']['nama'] ?? '').toString()
                                  : ''.toString(),
                              harga: (a['data'] != null &&
                                      a['data']['harga'] != null)
                                  ? (a['data']['harga'] as num).toInt()
                                  : 0,
                              stock: (a['data'] != null &&
                                      a['data']['jumlah'] != null)
                                  ? (a['data']['jumlah'] as num).toInt()
                                  : 0,
                              x: false,
                              i: 0,
                            ),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
