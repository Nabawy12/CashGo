import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/db/db_helper.dart';
import '../../services/provider/NotificationProvider.dart';
import '../../utils/colors.dart';
import '../Notification/notification.dart';
import 'product_management_screen.dart';
import 'stock_screen.dart';
import 'profit_screen.dart';
import 'change_password_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String username;
  const AdminDashboardScreen({super.key, required this.username});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _unseenCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnseen();
  }

  Future<void> _loadUnseen() async {
    try {
      final count = await DBHelper.instance.getLowStockUnseenCount();
      final count2 = await DBHelper.instance.getExpiringUnseenCount(daysThreshold: 10);
      setState(() => _unseenCount = count + count2);
    } catch (e) {
      // لو حصل خطأ (العمود غير موجود) حاول أن تضيف العمود ثم تعيد المحاولة
      await DBHelper.instance.ensureLowStockSeenColumn();
      await DBHelper.instance.ensureExpirySeenColumn();
      final count = await DBHelper.instance.getLowStockUnseenCount();
      setState(() => _unseenCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColorsDark.bgColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: const Text(
            'اداره التطبيق',
            style: TextStyle(
              color: Colors.white
            ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Tooltip(
                message: 'الاشعارات',
                waitDuration: const Duration(milliseconds: 01),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.white,size: 26,
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                    // بعد الرجوع حدث العداد
                    await _loadUnseen();
                  },
                ),
              ),
              if (_unseenCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_unseenCount',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          Tooltip(
            message: 'تغيير كلمة المرور',
            waitDuration: const Duration(milliseconds: 01),
            child: IconButton(
              mouseCursor: SystemMouseCursors.click,
              icon: const Icon(Icons.lock,color: Colors.white,size: 26,),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangePasswordScreen(username: widget.username),
                  ),
                );
              },
            ),
          ),
        ],
      ),
        body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagementScreen()));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColorsDark.mainColor,
                              width: 2,
                            )
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 20,vertical: 1),
                          child: const Text(
                            'اداره المنتجات',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                  ),
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitScreen()));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColorsDark.mainColor,
                              width: 2,
                            )
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 20,vertical: 1),
                          child: const Text(
                            'نسبه الارباح',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      )
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                  child: Text(
                      'الفواتير هنا',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30
                    ),
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
