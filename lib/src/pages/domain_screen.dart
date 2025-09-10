import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/domain_provider.dart';
import 'login_screen.dart';

class Domainscreen extends StatefulWidget {
  const Domainscreen({super.key});

  @override
  State<Domainscreen> createState() => _DomainscreenState();
}

class _DomainscreenState extends State<Domainscreen> {
  @override
  Widget build(BuildContext context) {
    final mDomainProvider = Provider.of<DomainProvider>(context);
    OutlineInputBorder border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white38, width: 3.0),
      borderRadius: BorderRadius.circular(15),
    );

    OutlineInputBorder focusBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.blueAccent, width: 3.0),
      borderRadius: BorderRadius.circular(15),
    );
    // return Scaffold(
    //   body: Center(
    //     child: SizedBox(
    //       height: 500,
    //       width: 800,
    //       child: Card(
    //         elevation: 8,
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(16),
    //         ),
    //         child: Row(
    //           children: [
    //             // Left Panel (Design)
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
    //                       "Welcome to Domain Portal",
    //                       style: TextStyle(
    //                         fontSize: 22,
    //                         fontWeight: FontWeight.bold,
    //                       ),
    //                     ),
    //                     const SizedBox(height: 24),
    //                     TextField(
    //                       controller: mDomainProvider.domainController,
    //                       keyboardType: TextInputType.text,
    //                       textInputAction: TextInputAction.done,
    //                       decoration: InputDecoration(
    //                         labelText: "Domain Name",
    //                         enabledBorder: border,
    //                         focusedBorder: focusBorder,
    //                         border: OutlineInputBorder(
    //                           borderRadius: BorderRadius.circular(8),
    //                         ),
    //                       ),
    //
    //                       onSubmitted: (_) => _onSubmit(mDomainProvider),
    //                     ),
    //                     // const SizedBox(height: 16),
    //                     // TextField(
    //                     //   controller: mDomainProvider.domainController,
    //                     //   keyboardType: TextInputType.text,
    //                     //   textInputAction: TextInputAction.newline,
    //                     //   decoration: InputDecoration(
    //                     //     hintText: "Domain Name",
    //                     //     enabledBorder: border,
    //                     //     focusedBorder: focusBorder,
    //                     //     border: OutlineInputBorder(
    //                     //       borderRadius: BorderRadius.circular(8),
    //                     //     ),
    //                     //   ),
    //                     // ),
    //                     SizedBox(height: 20),
    //                     Consumer<DomainProvider>(
    //                       builder: (context, provider, child) {
    //                         return SizedBox(
    //                           width: double.infinity,
    //                           height: 45,
    //                           child: ElevatedButton(
    //                             onPressed: () async {
    //                               _onSubmit(mDomainProvider);
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
    //                                       width: 20,
    //                                       height: 20,
    //                                       child: CircularProgressIndicator(
    //                                         color: Colors.white,
    //                                         strokeWidth: 2,
    //                                       ),
    //                                     )
    //                                     : const Text('Submit'),
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
            bool isMobile = constraints.maxWidth < 600;

            return Container(
              height: isMobile ? null : 500,
              width: isMobile ? null : 800,
              constraints: const BoxConstraints(maxWidth: 800),
              child: isMobile
                  ? _buildMobileLayout(context, mDomainProvider, border, focusBorder)
                  : _buildDesktopLayout(context, mDomainProvider, border, focusBorder),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, DomainProvider provider,
      OutlineInputBorder border, OutlineInputBorder focusBorder) {
    return Row(
      children: [
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
            child: _logoContent(context),
          ),
        ),

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
            child: _rightPanel(context, provider, border, focusBorder),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, DomainProvider provider,
      OutlineInputBorder border, OutlineInputBorder focusBorder) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.2),
                // gradient: LinearGradient(
                //   colors: [Colors.blueAccent,Colors.black12],
                //   begin: Alignment.topCenter,
                //   end: Alignment.bottomCenter,
                // ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: _logoContent(context),
            ),

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
              child: _rightPanel(context, provider, border, focusBorder),
            ),
          ],
        ));
  }

  Widget _logoContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/voip_logo.png',
            height: 120,
            width: MediaQuery
                .of(context)
                .size
                .height * 0.3,
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
            padding: EdgeInsets.all(20.0),
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

  Widget _rightPanel(BuildContext context, DomainProvider provider,
      OutlineInputBorder border, OutlineInputBorder focusBorder) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Welcome to Domain Portal",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: provider.domainController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          cursorColor: Colors.blueAccent,
          decoration: InputDecoration(
            labelText: "Domain Name",
            floatingLabelStyle: const TextStyle(color: Colors.blueAccent),
            enabledBorder: border,
            focusedBorder: focusBorder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onSubmitted: (_) => _onSubmit(provider),
        ),
        const SizedBox(height: 20),
        Consumer<DomainProvider>(
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
                    : const Text("Submit"),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _onSubmit(DomainProvider provider) async {
    if (!provider.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.ValidatorDomainMsg),
        ),
      );
      return;
    }
    try {
      final success =
          await provider.DomainApiCalling(
            context, provider.domainController.text.toString(),
      );
      if (success) {
        provider.clearMyText();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoginScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              '' ?? 'Unknown error',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
