import 'package:cashier/barang/barang.dart';
import 'package:cashier/controller/barangcontroller.dart';
import 'package:cashier/controller/transaksicontroller.dart';
import 'package:cashier/dashboard/dashboard.dart';
import 'package:cashier/laporan/laporan.dart';
import 'package:cashier/theme/app_colors.dart';
import 'package:cashier/theme/app_theme.dart';
import 'package:cashier/transaksi/transaksi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  await Permission.storage.request();
  await Firebase.initializeApp();
  await initializeDateFormatting('id_ID', null).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return GetMaterialApp(
      title: 'Kasir Kilat',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: MainWrapper(),
    );
  }
}

class MainWrapper extends StatefulWidget {
  @override
  _MainWrapperState createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  final PageController _pageController =
      PageController(initialPage: 0, keepPage: true);
  final Getbarang b = Get.put(Getbarang());
  final TransaksiController t = Get.put(TransaksiController());
  bool _isRefreshing = false;
  double _verticalDrag = 0.0;

  @override
  void initState() {
    super.initState();
    b.getbarang();
    t.gettransaksi();
  }

  Future<void> _refreshCurrentPage() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
    });

    try {
      // call relevant controller methods depending on current page
      switch (_currentIndex) {
        case 0:
          b.getbarang();
          t.gettransaksi();
          break;
        case 1:
          t.gettransaksi();
          break;
        case 2:
          b.getbarang();
          break;
        case 3:
          t.gettransaksi();
          break;
        default:
          b.getbarang();
          t.gettransaksi();
      }

      // small delay to allow UI to show refresh indicator
      await Future.delayed(const Duration(milliseconds: 350));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _verticalDrag = 0.0;
        });
      }
    }
  }

  void _goToPage(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragUpdate: (details) {
              _verticalDrag += details.delta.dy;
            },
            onVerticalDragEnd: (details) {
              if (_verticalDrag < -120) {
                _refreshCurrentPage();
              } else if (_verticalDrag > 120) {
                _refreshCurrentPage();
              }
              _verticalDrag = 0.0;
            },
            child: PageView(
              physics: const BouncingScrollPhysics(),
              controller: _pageController,
              children: [
                Dashboard(goToPage: _goToPage),
                Transaksi(),
                Barang(),
                Laporan(),
              ],
              onPageChanged: (value) {
                setState(() {
                  _currentIndex = value;
                });
              },
            ),
          ),
          if (_isRefreshing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.25),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_rounded,
                    Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(1, Icons.swap_horiz_rounded,
                    Icons.swap_horiz_rounded, 'Transaksi'),
                _buildNavItem(2, Icons.inventory_2_rounded,
                    Icons.inventory_2_outlined, 'Produk'),
                _buildNavItem(3, Icons.bar_chart_rounded,
                    Icons.bar_chart_rounded, 'Laporan'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () => _goToPage(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              isActive ? AppColors.navy.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppColors.navy : AppColors.textSecondary,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
