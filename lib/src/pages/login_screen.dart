import 'package:callingproject/src/Providers/login_provider.dart';
import 'package:callingproject/src/pages/call_screen.dart';
import 'package:callingproject/src/utils/constants.dart';
import 'package:callingproject/src/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<LoginScreen> {

  @override
  void initState() {
    super.initState();
    // final provider = Provider.of<LoginProvider>(context);
    // provider.loadUsername();
  }

  @override
  Widget build(BuildContext context) {
    final mLoginProvider = Provider.of<LoginProvider>(context);
    OutlineInputBorder border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white, width: 2.0),
      borderRadius: BorderRadius.circular(15),
    );

    OutlineInputBorder focusBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
      borderRadius: BorderRadius.circular(15),
    );
    // return Scaffold(
    //   body: Center(
    //     child: Container(
    //       height: 500,
    //       width: double.infinity,
    //       constraints: BoxConstraints(maxWidth: 400),
    //       child: Card(
    //         elevation: 8,
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(16),
    //         ),
    //         child: Row(
    //           children: [
    //             // Left Panel (Design / Logo / Branding)
    //             Expanded(
    //               child: Container(
    //                 decoration: const BoxDecoration(
    //                   gradient: LinearGradient(
    //                     colors: [Colors.blue, Colors.blueAccent],
    //                     begin: Alignment.topLeft,
    //                     end: Alignment.bottomRight,
    //                   ),
    //                   borderRadius: BorderRadius.horizontal(
    //                     left: Radius.circular(16),
    //                   ),
    //                 ),
    //                 child: Center(
    //                   child: Column(
    //                     mainAxisSize: MainAxisSize.min,
    //                     children: [
    //                       Image.asset(
    //                         'assets/voip_logo.png',
    //                         height: 120,
    //                         width: MediaQuery.of(context).size.height * 0.3,
    //                         fit: BoxFit.contain,
    //                       ),
    //                       SizedBox(height: 20),
    //                       Text(
    //                         'Welcome Back!',
    //                         style: TextStyle(
    //                           color: Colors.white,
    //                           fontSize: 24,
    //                           fontWeight: FontWeight.bold,
    //                         ),
    //                       ),
    //                       Padding(
    //                         padding: EdgeInsets.all(20.0),
    //                         child: Text(
    //                           'Sign in to continue and manage your account.',
    //                           textAlign: TextAlign.center,
    //                           style: TextStyle(color: Colors.white70),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //
    //             // Right Panel (Login Form)
    //             Expanded(
    //               child: Container(
    //                 padding: const EdgeInsets.all(32.0),
    //                 decoration: const BoxDecoration(
    //                   gradient: LinearGradient(
    //                     colors: [Colors.black12, Colors.blueAccent],
    //                     begin: Alignment.topLeft,
    //                     end: Alignment.bottomRight,
    //                   ),
    //                   borderRadius: BorderRadius.horizontal(
    //                     right: Radius.circular(16),
    //                   ),
    //                 ),
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.center,
    //                   children: [
    //                     const Text(
    //                       "Login to Your Account",
    //                       style: TextStyle(
    //                         fontSize: 22,
    //                         fontWeight: FontWeight.bold,
    //                       ),
    //                     ),
    //                     const SizedBox(height: 24),
    //                     TextField(
    //                       controller: mLoginProvider.mEmailController,
    //                       keyboardType: TextInputType.text,
    //                       textInputAction: TextInputAction.done,
    //                       decoration: InputDecoration(
    //                         labelText: "Username",
    //                         enabledBorder: border,
    //                         focusedBorder: focusBorder,
    //                         border: OutlineInputBorder(
    //                           borderRadius: BorderRadius.circular(8),
    //                         ),
    //                       ),
    //                     ),
    //                     const SizedBox(height: 16),
    //                     TextField(
    //                       controller: mLoginProvider.mPasswordController,
    //                       autocorrect: false,
    //                         textInputAction: TextInputAction.done,
    //                       obscureText: _obscureText,
    //                       decoration: InputDecoration(
    //                         labelText: "Password",
    //                         enabledBorder: border,
    //                         focusedBorder: focusBorder,
    //                         border: OutlineInputBorder(
    //                           borderRadius: BorderRadius.circular(8),
    //                         ),
    //                         suffixIcon: IconButton(
    //                           icon: Icon(
    //                             _obscureText
    //                                 ? Icons.visibility
    //                                 : Icons.visibility_off,
    //                           ),
    //                           onPressed: () {
    //                             setState(() {
    //                               _obscureText = !_obscureText;
    //                             });
    //                           },
    //                         ),
    //                       ),
    //                         onSubmitted: (_) => _onSubmit(mLoginProvider)
    //                     ),
    //                     const SizedBox(height: 24),
    //                     Consumer<LoginProvider>(
    //                       builder: (context, provider, child) {
    //                         return SizedBox(
    //                           width: double.infinity, // Fixed width
    //                           height: 45,
    //                           child: ElevatedButton(
    //                             onPressed: () async {
    //                               _onSubmit(provider);
    //                             },
    //                             style: ElevatedButton.styleFrom(
    //                               foregroundColor: Colors.white,
    //                               backgroundColor: Colors.blueAccent,
    //                               padding: const EdgeInsets.symmetric(
    //                                 horizontal: 32,
    //                                 vertical: 16,
    //                               ),
    //                               shape: RoundedRectangleBorder(
    //                                 borderRadius: BorderRadius.circular(
    //                                   12,
    //                                 ), // Rounded corners
    //                               ),
    //                               elevation: 5,
    //                               // Shadow
    //                               textStyle: const TextStyle(
    //                                 fontSize: 18,
    //                                 fontWeight: FontWeight.bold,
    //                               ),
    //                             ),
    //                             child:
    //                                 provider.isLoading
    //                                     ? const SizedBox(
    //                                       height: 20,
    //                                       width: 20,
    //                                       child: CircularProgressIndicator(
    //                                         color: Colors.white,
    //                                         strokeWidth: 2,
    //                                       ),
    //                                     )
    //                                     : const Text('Login'),
    //                           ),
    //                         );
    //                       },
    //                     ),
    //                     const SizedBox(height: 12),
    //                     const Text(
    //                       "Forgot Password?",
    //                       style: TextStyle(color: Colors.blueAccent),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );


    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600; // 📱 breakpoint

            return Container(
              height: isMobile ? null : 500,
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 800),
              child: isMobile
                  ? _buildMobileLayout(context, mLoginProvider, border, focusBorder)
                  : _buildDesktopLayout(context, mLoginProvider, border, focusBorder),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onSubmit(LoginProvider provider) async {
    ClearData(context);
    if (!provider.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.ErrorMessage ?? 'error',
          ),
        ),
      );
      return;
    }
    final success = await provider.ApiCalling(
      context,
      provider.mEmailController.text.toString(),
      provider.mPasswordController.text
          .toString(),
    );
    if (success) {
      await SecureStorage().writebool(
        key: Constants.IS_LOGGEDIN,
        value: true,
      );

      provider.clearMyText();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreenWidget()
        ), (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ?? 'Login error',
          ),
        ),
      );
    }
  }

  Future<void> ClearData(BuildContext context) async {
    try {
      for (int i = 0; i < context
          .read<AccountsModel>()
          .length; i++) {
        await context.read<AccountsModel>().deleteAccount(i);
      }
    } catch (e) {
      print(e);
    }
  }


  Widget _buildDesktopLayout(BuildContext context, LoginProvider mLoginProvider,
      OutlineInputBorder border, OutlineInputBorder focusBorder) {
    return Row(
      children: [
        // Left Panel
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            child: _logoPanel(context),
          ),
        ),

        // Right Panel (Login)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black12, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
            ),
            child: _loginForm(context, mLoginProvider, border, focusBorder),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, LoginProvider mLoginProvider,
      OutlineInputBorder border, OutlineInputBorder focusBorder) {
    return SingleChildScrollView(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo Panel on top
          Container(
            padding: EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              // gradient: LinearGradient(
              //   colors: [Colors.blue, Colors.blueAccent],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: _logoPanel(context),
          ),

          // Login Form below
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              // gradient: LinearGradient(
              //   colors: [Colors.black12, Colors.blueAccent],
              //   begin: Alignment.topCenter,
              //   end: Alignment.bottomCenter,
              // ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: _loginForm(context, mLoginProvider, border, focusBorder),
          ),
        ],
      ),
    ));
  }

  Widget _logoPanel(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/voip_logo.png',
            height: 100,
            fit: BoxFit.contain,
          ),
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

  bool _obscureText = true;
  Widget _loginForm(BuildContext context, LoginProvider mLoginProvider,
      OutlineInputBorder border, OutlineInputBorder focusBorder) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Login to Your Account",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextField(
          cursorColor: Colors.blueAccent,
          controller: mLoginProvider.mEmailController,
          decoration: InputDecoration(
            floatingLabelStyle: const TextStyle(color: Colors.blueAccent),
            labelText: "Username",
            enabledBorder: border,
            focusedBorder: focusBorder,
          ),
          onSubmitted: (_) => _onSubmit(mLoginProvider),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: mLoginProvider.mPasswordController,
          obscureText: _obscureText,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          cursorColor: Colors.blueAccent,
          decoration: InputDecoration(
            floatingLabelStyle: const TextStyle(color: Colors.blueAccent),
            labelText: "Password",
            enabledBorder: border,
            focusedBorder: focusBorder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
          onSubmitted: (_) => _onSubmit(mLoginProvider),
        ),
        const SizedBox(height: 24),
        Consumer<LoginProvider>(
          builder: (context, provider, child) {
            return SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => _onSubmit(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: provider.isLoading
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
        ),
        // const SizedBox(height: 12),
        // const Text("Forgot Password?", style: TextStyle(color: Colors.blueAccent)),
      ],
    );
  }
}
