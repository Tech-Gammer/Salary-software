import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authprovider.dart';
import 'package:salary_soft/Auth/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;

    // Access the LoginProvider
    final loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            children: [
              Container(
                width: 300,
                child: Image.asset("images/logo.png"),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: screenWidth < 600
                      ? screenWidth * 0.8 // For mobile, use 80% of screen width
                      : 400, // For larger screens, set a fixed width
                  height: MediaQuery.of(context).size.height * 0.6, // Set height to 60% of screen height
                  padding: const EdgeInsets.all(8.0), // Add padding for better spacing
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              hintText: "Enter your E-mail Address",
                              label: Text("E-mail"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              hintText: "Enter Your Password",
                              labelText: "Password",
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        Card(
                          child: InkWell(
                            onTap: loginProvider.isLoggingIn
                                ? null
                                : () {
                              if (formKey.currentState?.validate() ?? false) {
                                loginProvider.loginUser(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  context: context,
                                );
                              }
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 50.0,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent,
                                    Colors.greenAccent,
                                  ],
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Center(
                                child: Text(
                                  loginProvider.isLoggingIn ? "Logging in..." : "Login",
                                  style: const TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("If not a registered member, click on"),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return const RegisterPage();
                                }));
                              },
                              child: const Text("Register"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
