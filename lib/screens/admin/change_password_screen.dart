import 'package:flutter/material.dart';
import '../../services/db/db_helper.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String username;
  const ChangePasswordScreen({super.key, required this.username});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final newPasswordController = TextEditingController();
  String message = '';

  void _changePassword() async {
    final newPassword = newPasswordController.text.trim();
    if (newPassword.isEmpty) {
      setState(() => message = 'أدخل كلمة مرور جديدة');
      return;
    }

    await DBHelper.instance.changePassword(widget.username, newPassword);
    setState(() => message = 'تم تغيير كلمة المرور بنجاح');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تغيير كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(labelText: 'كلمة مرور جديدة'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _changePassword, child: const Text('تغيير')),
                const SizedBox(height: 10),
                Text(message, style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
