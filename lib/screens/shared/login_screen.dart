import 'package:flutter/material.dart';
import '../../services/db/db_helper.dart';
import '../../utils/colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_form.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';

  void _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    final user = await DBHelper.instance.login(username, password);
    if (user != null) {
      if (user['role'] == 'admin') {
        Navigator.pushNamed(context, '/admin', arguments: username);
      } else {
        Navigator.pushNamed(context, '/cashier', arguments: username);
      }
    } else {
      setState(() {
        errorMessage = 'اسم المستخدم أو كلمة المرور غير صحيحه';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsDark.bgColor,
      appBar: AppBar(
        backgroundColor:  Colors.transparent,
          elevation: 0.0,
          title: const Text(
              'تسجيل الدخول',
            style: TextStyle(
              fontSize: 22,
              color: Colors.white
            ),
          )
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomFormField(
                  controller: usernameController,
                  hint: "اسم المستخدم",
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 12),
                CustomFormField(
                    hint: "رمز الدخول",
                    controller: passwordController,
                  isPassword: true,
                ),
                const SizedBox(height: 10),
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                CustomButton(
                    text: "تسجيل دخول",
                    onPressed: _login),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
