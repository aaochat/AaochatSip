import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';

import '../Databased/calllog_history.dart';
import '../models/appacount_model.dart';
import '../providers/call_logs_provider.dart';
import '../providers/layout_provider.dart';
import '../widget/action_button.dart';

class NewDesignScreen extends StatefulWidget {
  const NewDesignScreen({super.key});

  @override
  State<NewDesignScreen> createState() => _NewDesignScreenState();
}

class _NewDesignScreenState extends State<NewDesignScreen> {
  Color _backgroundColor = Colors.blue;
  Timer? _timer;
  bool isElevated = false;

  var mSipUserNAme = "";
  var mExtentionNumber = "";

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _backgroundColor =
            _backgroundColor == Colors.blue ? Colors.green : Colors.blue;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _getLoginDesign();
  }

  Widget _getLoginDesign() {
    /*New Login Design*/
    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(seconds: 2),
            curve: Curves.easeInOut,
            color: _backgroundColor,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black12, Colors.black12],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    // decoration: const BoxDecoration(
                    //   gradient: LinearGradient(
                    //     colors: [Colors.blue, Colors.blueAccent],
                    //     begin: Alignment.topLeft,
                    //     end: Alignment.bottomRight,
                    //   ),
                    //   // borderRadius: BorderRadius.horizontal(
                    //   //   left: Radius.circular(16),
                    //   // ),
                    // ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/voip_logo.png',
                          height: 120,
                          width: MediaQuery.of(context).size.height * 0.3,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Sign in to continue and manage your account.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /*Right Panel Design*/
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    // decoration: const BoxDecoration(
                    //   gradient: LinearGradient(
                    //     colors: [Colors.blue, Colors.blueAccent],
                    //     begin: Alignment.topLeft,
                    //     end: Alignment.bottomRight,
                    //   ),
                    //   // borderRadius: BorderRadius.horizontal(
                    //   //   left: Radius.circular(16),
                    //   // ),
                    // ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: SizedBox(
                        height: 400,
                        width: 500,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(32.0),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black12, Colors.blueAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(16),
                                left: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Login to Your Account",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.newline,
                                  decoration: InputDecoration(
                                    labelText: "Username",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 4),
                                        blurRadius: 5.0,
                                      ),
                                    ],
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      stops: [0.0, 1.0],
                                      colors: [
                                        Colors.amber.shade900,
                                        Colors.deepOrange.shade200,
                                      ],
                                    ),
                                    color: Colors.deepOrange.shade900,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder
                                      >(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20.0,
                                          ),
                                        ),
                                      ),
                                      minimumSize: WidgetStateProperty.all(
                                        Size(200, 45),
                                      ),
                                      backgroundColor: WidgetStateProperty.all(
                                        Colors.transparent,
                                      ),
                                      // elevation: MaterialStateProperty.all(3),
                                      shadowColor: WidgetStateProperty.all(
                                        Colors.transparent,
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                      ),
                                      child: Text(
                                        "Login Button",
                                        style: TextStyle(
                                          fontSize: 18,
                                          // fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Forgot Password?",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getScreenDesign() {
    final accounts = context.read<AppAccountsModel>();
    final mCallProvider = Provider.of<CallProvider>(context);
    final mLayoutProvider = Provider.of<LayoutProvider>(context);

    Color? textFieldColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 1);
    Color? textFieldFill =
        Theme.of(context).buttonTheme.colorScheme?.surfaceContainerLowest;

    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: new BorderRadius.circular(5.0),
                        boxShadow: [
                          // BoxShadow(color: Colors.black, spreadRadius: 5, blurRadius: 3),
                          BoxShadow(
                            color: Colors.black,
                            offset: const Offset(5.0, 5.0),
                            blurRadius: 5.0,
                            spreadRadius: 2.0,
                          ),
                          //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ),
                          //BoxShado
                        ],
                      ),
                      child: TypeAheadField<CallLogHistory>(
                        controller: mCallProvider.phoneNumbCtrl,
                        hideOnEmpty: true,
                        suggestionsCallback:
                            (search) => mLayoutProvider.getSuggestions(search),

                        itemBuilder: (context, CallLogHistory mCallLogHistory) {
                          return Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.black
                                        : Colors.grey[200]!,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    mCallLogHistory.displName ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (mCallLogHistory.remoteExt != null &&
                                    mCallLogHistory.remoteExt!.isNotEmpty)
                                  TextButton(
                                    onPressed:
                                        () => {
                                          mCallProvider.phoneNumbCtrl.text =
                                              mCallLogHistory.remoteExt ?? '',
                                        },
                                    child: Text(
                                      mCallLogHistory.remoteExt ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                SizedBox(width: 10),
                              ],
                            ),
                          );
                        },
                        onSelected: (CallLogHistory mCallLogHistory) {
                          mCallProvider.phoneNumbCtrl.text =
                              mCallLogHistory.remoteExt ?? '';
                        },
                        builder: (context, controller, focusNode) {
                          return Material(
                            type: MaterialType.transparency,
                            child: TextField(
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: textFieldColor,
                              ),
                              maxLines: 1,
                              decoration: InputDecoration(
                                filled: true,
                                hintText: "Enter/Search phone number",
                                fillColor: textFieldFill,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue.withValues(alpha: 0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue.withValues(alpha: 0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blue.withValues(alpha: 0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              controller: controller,
                              focusNode: focusNode,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.only(right: 15),
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.backspace, size: 15),
                        onPressed: onBackspacePressed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              // child: SizedBox(
              //   height: 400,
              //   width: 500,
              //   child: Card(
              //     margin: EdgeInsets.only(bottom: 50),
              //     elevation: 10,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(16),
              //     ),
              //     child: Container(
              //       padding: const EdgeInsets.all(32.0),
              //       decoration: const BoxDecoration(
              //         gradient: LinearGradient(
              //           colors: [Colors.black12, Colors.blueAccent],
              //           begin: Alignment.topLeft,
              //           end: Alignment.bottomRight,
              //         ),
              //         borderRadius: BorderRadius.horizontal(
              //           right: Radius.circular(16),
              //           left: Radius.circular(16),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              child: Column(
                children: _buildDialPad(
                  accounts,
                  mCallProvider,
                  mLayoutProvider,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNum(String number, CallProvider mCallProvider) {
    setState(() {
      mCallProvider.phoneNumbCtrl.text += number;
    });
  }

  List<Widget> _buildNumPad(CallProvider mCallProvider) {
    final labels = [
      [
        {'1': ''},
        {'2': 'abc'},
        {'3': 'def'},
      ],
      [
        {'4': 'ghi'},
        {'5': 'jkl'},
        {'6': 'mno'},
      ],
      [
        {'7': 'pqrs'},
        {'8': 'tuv'},
        {'9': 'wxyz'},
      ],
      [
        {'*': ''},
        {'0': '+'},
        {'#': ''},
      ],
    ];

    return labels
        .map(
          (row) => Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  row
                      .map(
                        (label) => ActionButton(
                          title: label.keys.first,
                          subTitle: label.values.first,
                          onPressed:
                              () => _handleNum(label.keys.first, mCallProvider),
                          number: true,
                        ),
                      )
                      .toList(),
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildDialPad(
    AccountsModel accounts,
    CallProvider mCallProvider,
    LayoutProvider mLayoutProvider,
  ) {
    Color? textFieldColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 1);
    Color? textFieldFill =
        Theme.of(context).buttonTheme.colorScheme?.surfaceContainerLowest;

    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildNumPad(mCallProvider),
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: false,
              child: ActionButton(
                icon: Icons.videocam,
                onPressed: () => mCallProvider.mInvite(context, true, accounts),
              ),
            ),

            // GestureDetector(
            //   onTapDown: (_) {
            //     setState(() {
            //       _isElevated = true;
            //     });
            //   },
            //   onTapUp: (_) {
            //     setState(() {
            //       _isElevated = false;
            //     });
            //   },
            //   onTapCancel: () {
            //     setState(() {
            //       _isElevated = false;
            //     });
            //   },
            //   child: Container(
            //     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            //     decoration: BoxDecoration(
            //       color: Color(0xFF171717),
            //       // shape: BoxShape.circle, // Makes it round
            //       borderRadius: BorderRadius.circular(12),
            //       boxShadow:
            //           _isElevated
            //               ? [
            //                 BoxShadow(
            //                   color: Colors.black.withOpacity(0.15),
            //                   offset: Offset(-2, -2),
            //                   blurRadius: 6,
            //                 ),
            //                 BoxShadow(
            //                   color: Colors.white.withOpacity(0.7),
            //                   offset: Offset(2, 2),
            //                   blurRadius: 6,
            //                 ),
            //               ]
            //               : [
            //                 BoxShadow(
            //                   color: Colors.white.withOpacity(
            //                     0.1,
            //                   ), // Top-left shadow
            //                   offset: Offset(-6, -6),
            //                   blurRadius: 16,
            //                 ),
            //                 BoxShadow(
            //                   color: Colors.black.withOpacity(0.4),
            //                   // Bottom-right shadow
            //                   offset: Offset(6.0, 6.0),
            //                   blurRadius: 16,
            //                 ),
            //               ],
            //     ),
            //     child: Text(
            //       "Click Me",
            //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //     ),
            //   ),
            // ),
            ActionButton(
              icon: Icons.dialer_sip,
              fillColor: Colors.green,
              onPressed: () {
                mCallProvider.mInvite(context, false, accounts);
                if (mCallProvider.errorText != "") {
                  mCallProvider.clearText();
                  // if (widget.popUpMode) {
                  //   Navigator.of(context).pop();
                  // }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(mCallProvider.errorText!)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    ];
  }

  void onBackspacePressed() {
    final mCallProvider = Provider.of<CallProvider>(context, listen: false);
    if (mCallProvider.phoneNumbCtrl.text.isNotEmpty) {
      mCallProvider.phoneNumbCtrl.text = mCallProvider.phoneNumbCtrl.text
          .substring(0, mCallProvider.phoneNumbCtrl.text.length - 1);
    }
  }
}
