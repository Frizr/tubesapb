import 'package:cashier/controller/authcontroller.dart';
import 'package:cashier/controller/barangcontroller.dart';
import 'package:cashier/manage/formater.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class Expa extends StatefulWidget {
  final String id;
  final String kode;
  final String nama;
  final int harga;
  final int stock;
  final int modal;
  Expa(
      {required this.id,
      required this.kode,
      required this.nama,
      required this.harga,
      required this.stock,
      this.modal = 0});
  @override
  _ExpaState createState() => _ExpaState();
}

class _ExpaState extends State<Expa> {
  TextEditingController nama = TextEditingController();
  TextEditingController harga = TextEditingController();
  TextEditingController stock = TextEditingController();
  TextEditingController modal = TextEditingController();
  bool ex = false;
  Getbarang b = Get.put(Getbarang());

  @override
  void initState() {
    super.initState();
  }

  Color _statusColor() {
    if (widget.stock <= 0) return AppColors.danger;
    if (widget.stock <= 10) return AppColors.warning;
    return AppColors.success;
  }

  String _statusText() {
    if (widget.stock <= 0) return 'Habis';
    if (widget.stock <= 10) return 'Hampir Habis';
    return 'Tersedia';
  }

  Widget _editField({
    required String label,
    required TextEditingController c,
    TextInputType tp = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.bgLight,
            border: Border.all(color: AppColors.navy.withOpacity(0.08)),
          ),
          child: TextField(
            keyboardType: tp,
            onChanged: (value) {
              setState(() {});
            },
            cursorColor: AppColors.navy,
            style: const TextStyle(fontSize: 13),
            controller: c,
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final isAdmin = Get.find<AuthController>().isAdmin;
        return Slidable(
          key: ValueKey(widget.id),
          startActionPane: isAdmin
              ? ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      label: 'Hapus',
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_outline_rounded,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                      onPressed: (context) {
                        b.deletbarang(id: widget.id, nama: widget.nama);
                      },
                    ),
                  ],
                )
              : null,
          endActionPane: isAdmin
              ? ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      label: 'Hapus',
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_outline_rounded,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      onPressed: (context) {
                        b.deletbarang(id: widget.id, nama: widget.nama);
                      },
                    ),
                  ],
                )
              : null,
        child: Theme(
          data: ThemeData(fontFamily: 'm').copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.navy.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  color: AppColors.navy, size: 22),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        uang.format(widget.harga),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: _statusColor().withOpacity(0.1),
                      ),
                      child: Text(
                        widget.stock.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: _statusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _statusText(),
                      style: TextStyle(
                        fontSize: 10,
                        color: _statusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: AnimatedRotation(
              turns: ex ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    _editField(label: 'Nama', c: nama),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _editField(
                                label: 'Harga',
                                c: harga,
                                tp: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _editField(
                                label: 'Modal',
                                c: modal,
                                tp: TextInputType.number)),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _editField(
                                label: 'Stok',
                                c: stock,
                                tp: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (isAdmin)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            b.editbarang(
                              id: widget.id,
                              nama: nama.text,
                              harga: int.tryParse(harga.text) ?? 0,
                              stock: int.tryParse(stock.text) ?? 0,
                              modal: int.tryParse(modal.text) ?? 0,
                            );
                          },
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: const Text('Simpan',
                              style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onExpansionChanged: (value) {
              setState(() {
                if (value) {
                  nama.text = widget.nama;
                  harga.text = widget.harga.toString();
                  stock.text = widget.stock.toString();
                  modal.text = widget.modal.toString();
                }
                ex = value;
              });
            },
          ),
        ),
        );
      }),
    );
  }
}
