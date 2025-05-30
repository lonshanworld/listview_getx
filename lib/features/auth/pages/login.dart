// lib/app/modules/auth/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listview_getx/controllers/auth_controller.dart';
import 'package:listview_getx/features/auth/components/login_btn.dart';
import 'package:listview_getx/features/auth/components/text_field.dart';
import 'package:listview_getx/utils/debug_print.dart';

class LoginPage extends GetView<AuthController> {
  static const String routeName = '/login';
  final _formKey = GlobalKey<FormState>();

  LoginPage({super.key});



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [


                  LoginTxtField(
                      txtController: controller.usernameController,
                      labelTxt: 'Username',
                      icn: Icon(Icons.person),
                      secureTxt: false,
                  ),
                  const SizedBox(height: 16.0),
                  LoginTxtField(
                    txtController: controller.passwordController,
                    labelTxt: 'Password',
                    icn: Icon(Icons.lock),
                    secureTxt: true,
                  ),
                  const SizedBox(height: 24.0),

                  controller.obx(
                        (state) {
                      cusDebugPrint('checking state, $state');

                      if (controller.status.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return LoginBtn(onPressed: (){
                        if (_formKey.currentState!.validate()) {
                          controller.login();
                        }
                      });
                    },
                    onLoading: const Center(child: CircularProgressIndicator(color: Colors.teal,)), // This covers the initial load
                    onError: (error) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Error: Something went wrong', style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 10.0),
                        LoginBtn(onPressed: (){
                          if (_formKey.currentState!.validate()) {
                            controller.login();
                          }
                        }),
                      ],
                    ),
                    onEmpty: LoginBtn(onPressed: (){
                      if (_formKey.currentState!.validate()) {
                        controller.login();
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}