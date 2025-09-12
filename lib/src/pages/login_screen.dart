import 'package:callingproject/src/Providers/login_provider.dart';
import 'package:callingproject/src/pages/main_page.dart';
import 'package:callingproject/src/utils/extension_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/showAppSnackBar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<LoginScreen> {
  OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
  );

  OutlineInputBorder focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
  );

  bool _obscureText = true;

  @override
  initState() {
    super.initState();
    ExtensionUtil.deleteAllAccounts(context);
  }

  @override
  Widget build(BuildContext context) {
    final mLoginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          color: Colors.grey.shade900,
          constraints: const BoxConstraints(maxWidth: 500),
          child: Center(child: _buildMobileLayout(context, mLoginProvider)),
        ),
      ),
    );
  }

  Future<void> _onSubmit(LoginProvider provider) async {
    if (provider.validate() != null) {
      showAppSnackBar(context, message: provider.validate() ?? '');
      return;
    }
    final String? error = await provider.login(
      provider.mEmailController.text.toString(),
      provider.mPasswordController.text.toString(),
    );
    if (error == null) {
      await ExtensionUtil.initializeAccounts(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      showAppSnackBar(context, message: error);
    }
  }

  Widget _buildMobileLayout(
    BuildContext context,
    LoginProvider mLoginProvider,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(top: 20),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
              )),

          // Logo Panel on top
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _logoPanel(context),
                    const SizedBox(height: 20),
                      const SizedBox(height: 20),
          Container(
            constraints: BoxConstraints(maxWidth: 350),
            child: TextField(
                      cursorColor: Colors.deepOrangeAccent,
                      controller: mLoginProvider.mEmailController,

                      decoration: InputDecoration(
                        labelText: "Username",
                        enabledBorder: border,
                        focusedBorder: focusBorder,
                      ),
                      onSubmitted: (_) => _onSubmit(mLoginProvider),
                    )),
                     const SizedBox(height: 20),
          Container(
            constraints: BoxConstraints(maxWidth: 350),
            child:  TextField(
                      controller: mLoginProvider.mPasswordController,
                      obscureText: _obscureText,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      cursorColor: Colors.deepOrangeAccent,
                      decoration: InputDecoration(
                        labelText: "Password",
                        enabledBorder: border,
                        focusedBorder: focusBorder,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      onSubmitted: (_) => _onSubmit(mLoginProvider),
                    )),
                    const SizedBox(height: 24),
          Container(
            constraints: BoxConstraints(maxWidth: 350),
            child:  Consumer<LoginProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _onSubmit(provider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrangeAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                provider.isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text("Login"),
                          ),
                        );
                      },
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoPanel(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/voip_logo.png', height: 100, fit: BoxFit.contain),
          const SizedBox(height: 20),
          const Text(
            'Welcome Back!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Sign in to continue and manage your account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
