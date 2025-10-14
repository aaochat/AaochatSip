import 'package:callingproject/src/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/domain_provider.dart';
import '../utils/layout_util.dart';
import '../utils/snackbar_util.dart';
import 'login_screen.dart';

class Domainscreen extends StatefulWidget {
  const Domainscreen({super.key});

  @override
  State<Domainscreen> createState() => _DomainscreenState();
}

class _DomainscreenState extends State<Domainscreen> {
  OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: BorderSide(color: Colors.grey),
  );

  OutlineInputBorder focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
    borderSide: BorderSide(color: Colors.grey),
  );

  @override
  Widget build(BuildContext context) {
    final mDomainProvider = Provider.of<DomainProvider>(context);

    return Scaffold(
      appBar: ThemeAppBar(),
      body: Center(
        child:  Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _buildMobileLayout(context, mDomainProvider),
        ),
      ),
    );
  }

  // Widget _buildMobileLayout(BuildContext context, DomainProvider provider) {
  //   return Container(
  //     width: double.infinity,
  //     // decoration: BoxDecoration(color: Colors.white60),
  //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       // mainAxisSize: MainAxisSize.min,
  //       children: [
  //
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Image.asset(
  //               'assets/voip_logo.png',
  //               height: 50,
  //               width: 50,
  //               fit: BoxFit.contain,
  //             ),
  //             const Padding(
  //               padding: EdgeInsets.all(20.0),
  //               child: Text(
  //                 'Sign in to VOIP.',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(color: Colors.black),
  //               ),
  //             ),
  //           ],),
  //
  //         const SizedBox(height: 10),
  //
  //         Container(
  //           constraints: BoxConstraints(maxWidth: 350),
  //           child: TextField(
  //             controller: provider.domainController,
  //             autofocus: true,
  //             keyboardType: TextInputType.text,
  //             textInputAction: TextInputAction.done,
  //             cursorColor: Theme.of(context).primaryColorLight,
  //             decoration: InputDecoration(
  //               labelText: "Domain Name",
  //               enabledBorder: border,
  //               focusedBorder: focusBorder,
  //             ),
  //             onSubmitted: (_) => _onSubmit(provider),
  //           ),
  //         ),
  //         const SizedBox(height: 20),
  //         Container(
  //           constraints: BoxConstraints(maxWidth: 350),
  //           child: Consumer<DomainProvider>(
  //             builder: (context, provider, child) {
  //               return SizedBox(
  //                 width: double.infinity,
  //                 child: ElevatedButton(
  //                   onPressed: () => _onSubmit(provider),
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Theme.of(context).primaryColorLight,
  //                     foregroundColor: Colors.white,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                   ),
  //                   child:
  //                       provider.isLoading
  //                           ? const SizedBox(
  //                             width: 20,
  //                             height: 20,
  //                             child: CircularProgressIndicator(
  //                               color: Colors.white,
  //                               strokeWidth: 2,
  //                             ),
  //                           )
  //                           : const Text("Proceed"),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMobileLayout(BuildContext context, DomainProvider provider) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo & Title
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
                      'Domain',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Enter your VOIP domain to continue",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 350),
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
                        controller: provider.domainController,
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: "Domain Name",
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          prefixIcon: const Icon(Icons.domain, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: (_) => _onSubmit(provider),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 350),
                      child: Consumer<DomainProvider>(
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
                                  child: provider.isLoading
                                      ? const SizedBox(
                                    width: 22,
                                    height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ): const Text(
                                    "Proceed",
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
                  ]
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit(DomainProvider provider) async {
    if (!provider.validate()) {
      showAppSnackBar(context, message: provider.ValidatorDomainMsg);
      return;
    }
    try {
      final String? error = await provider.validateDomain();
      if (error == null) {
        provider.clearMyText();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        showAppSnackBar(context, message: error);
      }
    } catch (e) {
      showAppSnackBar(context, message: e.toString());
    }
  }
}
