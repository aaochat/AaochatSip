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
  OutlineInputBorder border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
  );

  OutlineInputBorder focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
  );

  @override
  Widget build(BuildContext context) {
    final mDomainProvider = Provider.of<DomainProvider>(context);

    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: _buildMobileLayout(context, mDomainProvider),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, DomainProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey.shade900),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/voip_logo.png',
            height: 100,
            width: MediaQuery.of(context).size.height * 0.3,
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
          const SizedBox(height: 20),

          Container(
            constraints: BoxConstraints(maxWidth: 350),
            child: TextField(
              controller: provider.domainController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              cursorColor: Colors.deepOrangeAccent,
              decoration: InputDecoration(
                labelText: "Domain Name",
                enabledBorder: border,
                focusedBorder: focusBorder,
              ),
              style: TextStyle(color: Colors.white),
              onSubmitted: (_) => _onSubmit(provider),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            constraints: BoxConstraints(maxWidth: 350),
            child: Consumer<DomainProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 45,
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
                            : const Text("Submit"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit(DomainProvider provider) async {
    if (!provider.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.ValidatorDomainMsg)));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
