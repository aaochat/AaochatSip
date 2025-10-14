import 'package:callingproject/src/pages/login_screen.dart';
import 'package:callingproject/src/providers/signup_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/extension_util.dart';
import '../utils/layout_util.dart';
import '../utils/snackbar_util.dart';
import '../widget/appbar.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
    final mSignupProvider = Provider.of<SignupProvider>(context);

    return Scaffold(
      appBar: ThemeAppBar(),
      body: Center(
        child: Container(
          width: double.infinity,
          color: Colors.white30,
          constraints: const BoxConstraints(maxWidth: 500),
          child: Center(child: _buildMobileLayout(context, mSignupProvider)),
        ),
      ),
    );
  }

  Future<void> _onSubmit(SignupProvider provider) async {
    if (provider.validate() != null) {
      showAppSnackBar(context, message: provider.validate() ?? '');
      return;
    }
    final bool error = await provider.Signup(
      provider.mFNameController.text.toString(),
      provider.mLNameController.text.toString(),
      provider.mEmailController.text.toString(),
      provider.mPasswordController.text.toString(),
    );
    if (error == true) {
      showAlertDialog(context, provider.error);
    } else {
      showAppSnackBar(context, message: provider.error);
    }
  }

  Widget _buildMobileLayout(BuildContext context, SignupProvider mLoginProvider) {
    final theme = Theme.of(context);
    final double maxWidth = 350;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, top: 8),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              tooltip: 'Back',
            ),
          ),

          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Panel on top
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/voip_logo.png', height: 60, width: 60),
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
                    const Text(
                      'Signup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: maxWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
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
                                    cursorColor: Theme.of(context).primaryColorLight,
                                    controller: mLoginProvider.mFNameController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      labelText: "First Name",
                                      labelStyle: TextStyle(color: Colors.grey.shade700),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                    onSubmitted: (_) => _onSubmit(mLoginProvider),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Container(
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
                                    cursorColor: Theme.of(context).primaryColorLight,
                                    controller: mLoginProvider.mLNameController,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                      labelText: "Last Name",
                                      labelStyle: TextStyle(color: Colors.grey.shade700),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                    ),
                                    onSubmitted: (_) => _onSubmit(mLoginProvider),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          constraints: BoxConstraints(maxWidth: maxWidth),
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
                            cursorColor: Theme.of(context).primaryColorLight,
                            controller: mLoginProvider.mEmailController,
                            decoration: InputDecoration(
                              labelText: "Username",
                              labelStyle: TextStyle(color: Colors.grey.shade700),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: (_) => _onSubmit(mLoginProvider),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          constraints: BoxConstraints(maxWidth: maxWidth),
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
                            cursorColor: Theme.of(context).primaryColorLight,
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.grey.shade700),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                                color: Colors.grey,
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            onSubmitted: (_) => _onSubmit(mLoginProvider),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Consumer<SignupProvider>(
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
                                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
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
                                      child:
                                          provider.isLoading
                                              ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                              : const Text(
                                                "Signup",
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
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          height: 45,
                          child: Wrap(
                            children: [
                              Text("Do you have an account?"),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  Future<void> showAlertDialog(BuildContext context, String Message) async {
    final theme = Theme.of(context);
    await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap a button
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                SizedBox(width: 8),
                Text(
                  "Aao VOIP",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Text(Message, style: TextStyle(color: Colors.black54, fontSize: 15)),
            actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          ),
    );
  }
}
