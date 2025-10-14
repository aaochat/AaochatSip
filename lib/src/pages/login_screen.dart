import 'package:callingproject/src/Providers/login_provider.dart';
import 'package:callingproject/src/pages/main_page.dart';
import 'package:callingproject/src/utils/extension_util.dart';
import 'package:callingproject/src/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/layout_util.dart';
import '../utils/snackbar_util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<LoginScreen> {
  OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    
    borderSide: BorderSide(color: Colors.grey),
  );

  OutlineInputBorder focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    
    borderSide: BorderSide(color: Colors.grey),
  );

  bool _obscureText = true;

  @override
  initState() {
    ExtensionUtil.deleteAllAccounts(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mLoginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      appBar: ThemeAppBar(),
      body: Center(
        child: Container(
          width: double.infinity,
          color: Colors.white30,
          constraints: const BoxConstraints(maxWidth: 500,),
          child: Center(child: _buildMobileLayout2(context, mLoginProvider)),
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
      // Future.delayed(Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainPage()),
        (Route<dynamic> route) => false,
      );
      // });
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
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),

          // Logo Panel on top
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _logoPanel(context),
                    const SizedBox(height: 40),
                    Container(
                        constraints: BoxConstraints(maxWidth: 350),
                        child: TextField(
                          cursorColor: Theme
                              .of(context)
                              .primaryColorLight,
                          controller: mLoginProvider.mEmailController,
                          autofocus: true,
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
                        child: TextField(
                          controller: mLoginProvider.mPasswordController,
                          obscureText: _obscureText,
                          autocorrect: false,
                          textInputAction: TextInputAction.done,
                          cursorColor: Theme
                              .of(context)
                              .primaryColorLight,
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
                        child: Consumer<LoginProvider>(
                          builder: (context, provider, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _onSubmit(provider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme
                                      .of(context)
                                      .primaryColorLight,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
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

  Widget _buildMobileLayout2(BuildContext context,
      LoginProvider mLoginProvider,) {
    final theme = Theme.of(context);
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              Padding(padding: EdgeInsets.only(left: 8, top: 8),
                  child: IconButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    icon: Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  )),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo Panel on top
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/voip_logo.png',
                              height: 60,
                              width: 60,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Aao VOIP',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Thanks you for get back to VOIP,lest access our the\nbest recommendation for you',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                                constraints: BoxConstraints(maxWidth: 350),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.text,
                                  cursorColor: Theme
                                      .of(context)
                                      .primaryColorLight,
                                  controller: mLoginProvider.mEmailController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    labelText: "Username",
                                    labelStyle: TextStyle(color: Colors.grey.shade700),
                                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  onSubmitted: (_) => _onSubmit(mLoginProvider),
                                )

                            ),
                            const SizedBox(height: 20),
                            Container(
                                constraints: BoxConstraints(maxWidth: 350),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: mLoginProvider.mPasswordController,
                                  obscureText: _obscureText,
                                  autocorrect: false,
                                  textInputAction: TextInputAction.done,
                                  cursorColor: Theme
                                      .of(context)
                                      .primaryColorLight,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    // enabledBorder: border,
                                    // focusedBorder: focusBorder,
                                    labelStyle: TextStyle(color: Colors.grey.shade700),
                                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                                child: Consumer<LoginProvider>(
                                  builder: (context, provider, child) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: LayoutUtil.isMobile() ? 50 : 45,
                                      child: ElevatedButton(
                                        onPressed: () => _onSubmit(provider),
                                        style: ElevatedButton.styleFrom(
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.zero,
                                          backgroundColor: Colors.transparent,
                                        ).copyWith(
                                          backgroundColor: MaterialStateProperty.all(
                                              Colors.transparent),
                                        ),
                                        child: Ink(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                theme.primaryColor,
                                                theme.primaryColor.withOpacity(0.8),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: provider.isLoading
                                                ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ) : const Text(
                                              "Login",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _logoPanel(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/voip_logo.png', height: 100, fit: BoxFit.contain),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Sign in to continue and manage your account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
