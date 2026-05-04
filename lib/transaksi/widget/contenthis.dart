import 'package:cashier/manage/formater.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContentHis extends StatefulWidget {
  final Map a;
  ContentHis({required this.a});
  @override
  _ContentHisState createState() => _ContentHisState();
}

class _ContentHisState extends State<ContentHis> {
  final tg = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
  final jam = DateFormat('HH:mm', 'id_ID');
  bool x = false;

  IconData _getMetodeIcon(String metode) {
    switch (metode) {
      case 'Transfer':
        return Icons.account_balance_rounded;
      case 'QRIS':
        return Icons.qr_code_rounded;
      case 'E-Wallet':
        return Icons.wallet_rounded;
      default:
        return Icons.money_rounded;
    }
  }

  Color _getMetodeColor(String metode) {
    switch (metode) {
      case 'Transfer':
        return AppColors.info;
      case 'QRIS':
        return AppColors.teal;
      case 'E-Wallet':
        return AppColors.amber;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.a['data'] as Map<String, dynamic>;
    final String metode = (data['metode'] ?? 'Cash').toString();
    DateTime? tglDate;
    try {
      tglDate = data['tgl'].toDate();
    } catch (e) {
      tglDate = null;
    }

    return Container(
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
      child: Theme(
        data: ThemeData(fontFamily: 'm').copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              color: _getMetodeColor(metode).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getMetodeIcon(metode),
              color: _getMetodeColor(metode),
              size: 22,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tglDate != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        tg.format(tglDate),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      jam.format(tglDate),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    uang.format((data['bayar'] as num?)?.toInt() ?? 0),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getMetodeColor(metode).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      metode,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getMetodeColor(metode),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(
            x ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          onExpansionChanged: (value) {
            setState(() {
              x = value;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          flex: 3,
                          child: Text('Barang',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('Qty',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Subtotal',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    for (var b in data['data'])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                (b['nama'] ?? '').toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                (b['jumlahbeli'] ?? 0).toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                uang.format(b['totharga'] ?? 0),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
