import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:skiller/config/constants.dart';
import 'package:skiller/controllers/auth/auth_controller.dart';
import 'package:skiller/controllers/auth/login_controller.dart';
import 'package:skiller/screens/main_screen.dart';

import 'package:skiller/widgets/common/loading_spinner.dart';

import '../server/mutations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailTEC = TextEditingController();
  var passwordTEC = TextEditingController();
  bool isLoading = false;
  final LoginController _loginController = Get.put(LoginController());

  @override
  void dispose() {
    emailTEC.dispose();
    passwordTEC.dispose();
    _loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              height: 150,
              image: AssetImage('assets/images/login_image.png'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: Constants.minPadding,
                  horizontal: Constants.minPadding * 6),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: emailTEC,
                      decoration: InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          prefixIcon: const Icon(Icons.email)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: passwordTEC,
                      obscureText: true,
                      obscuringCharacter: '●',
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        prefixIcon: const Icon(Icons.password),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Mutation(
                      options: MutationOptions(
                          document: gql(Mutations.loginMutation),
                          onCompleted: (response) {
                            debugPrint('Login completed');
                            debugPrint('Response : $response');
                            if (response?['login']['__typename'] !=
                                'LoginError') {
                              debugPrint(
                                  'login token : ${response!['login']['token']}');

                              Get.find<AuthController>().initializeUser(
                                  context: context,
                                  json: Map<String, dynamic>.from(
                                      response['login']!));
                              _loginController.updateProfile(context: context);
                              setState(() {
                                isLoading = false;
                              });
                              Get.to(() => const MainScreen());
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              Get.snackbar(
                                'Invalid credentials!',
                                'Wrong username or password',
                                duration: const Duration(seconds: 4),
                                snackPosition: SnackPosition.BOTTOM,
                                colorText: Colors.white,
                                backgroundColor: Colors.black,
                              );
                            }
                          }),
                      builder: (MultiSourceResult<dynamic> Function(
                                  Map<String, dynamic>,
                                  {Object? optimisticResult})
                              runMutation,
                          QueryResult<dynamic>? result) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 50,
                          child: ElevatedButton(
                              child: isLoading
                                  ? const LoadingSpinner(color: Colors.white)
                                  : const Text('Login',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      )),
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                setState(() {
                                  isLoading = true;
                                });
                                runMutation({
                                  'email': emailTEC.text,
                                  'password': passwordTEC.text
                                });
                              }),
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot password ?',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
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
