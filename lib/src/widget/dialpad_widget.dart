import 'dart:io';

import 'package:callingproject/src/models/sip_user_model.dart';
import 'package:callingproject/src/pages/domain_screen.dart';
import 'package:callingproject/src/providers/layout_provider.dart';
import 'package:callingproject/src/repository/sip_repository.dart';
import 'package:callingproject/src/utils/extension_util.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import '../event/place_call_event.dart';
import '../models/telephone_master.dart';
import '../pages/settings_page.dart';
import '../providers/call_logs_provider.dart';
import '../utils/shared_prefs.dart';
import '../utils/snackbar_util.dart';

class DialpadWidget extends StatefulWidget {
  const DialpadWidget(this.popUpMode, {super.key});

  static const routeName = "/addCall";
  final bool popUpMode;

  @override
  State<DialpadWidget> createState() => _DialpadscreenState();
}

class _DialpadscreenState extends State<DialpadWidget> {
  List<TelephoneMaster> allTelephoneMaster = [];
  EventTaxi eventBus = EventTaxiImpl.singleton();
  var _mCallProvider = CallProvider();
  List<SIPUser> allSipUsers = [];
  
  final phoneNumberController = TextEditingController();

  @override
  void didChangeDependencies() {
    _mCallProvider = Provider.of<CallProvider>(context);
    super.didChangeDependencies();
  }

  Future<void> getAllSipUsers() async {
    final selectedAccountId = context.read<AccountsModel>().selAccountId;
    final selectedAccount = context.read<AccountsModel>().accounts.firstWhere(
      (element) => element.myAccId == selectedAccountId,
    );
    final response = await SipRepository.getAllSipUsers(selectedAccount.sipServer);
    if (response.status == 'success') {
      allSipUsers = response.data ?? [];
    }
  }

  @override
  void initState() {
    getAllSipUsers();
    super.initState();

    eventBus.registerTo<PlaceCallEvent>(false).listen((event) {
      _mCallProvider.phoneNumbCtrl.text =
          event.phoneNumber.replaceAll(new RegExp(r'[^0-9]'), '');
      if (event.placeCall) {
        _mCallProvider.mInvite(context, false, context.read<AccountsModel>());
      }
    });

    context.read<AccountsModel>().addListener(() {
      if(mounted) {
        setState(() {
        });
      }
    });
    
  }
  

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountsModel>();
    final mCallProvider = Provider.of<CallProvider>(context);
    final mLayoutProvider = Provider.of<LayoutProvider>(context);

    final theme = Theme.of(context);
    final Color addCallBase =
        theme.cardTheme.color ?? Colors.grey.shade900;
    return Scaffold(
      backgroundColor: widget.popUpMode ? addCallBase : Colors.transparent,
      appBar: widget.popUpMode
          ? AppBar(title: const Text('Add Call'))
          : null,
      body: accounts.isEmpty ? _buildEmptyBody(mCallProvider) : _buildBody(
          accounts, mCallProvider, mLayoutProvider, addCallBase),
    );
  }

  Widget _buildEmptyBody(CallProvider mCallProvider) {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Can\'t make calls. Required to add account'),
            TextButton(
                onPressed: () {
                  mLogoutSession(mCallProvider);
                },
                child: Text('Logout')),
          ],
        ));
  }

  Widget _buildBody(AccountsModel accounts,
      CallProvider mCallProvider,
      LayoutProvider mLayoutProvider,
      Color addCallBase) {
    final theme = Theme.of(context);
    final popup = widget.popUpMode;

    final headerDecoration = popup
        ? BoxDecoration(
            color: Colors.grey.shade800,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.35),
                width: 1,
              ),
            ),
          )
        : null;

    final keypadBackdrop = popup
        ? BoxDecoration(
      color: Colors.black12.withValues(alpha: 0.14),
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     theme.colorScheme.primary.withOpacity(0.14),
            //     addCallBase,
            //   ],
            // ),
          )
        : null;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
          decoration: headerDecoration,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
          child: Column(children: [
            _buildAccountsMenu(accounts, mCallProvider),
            const SizedBox(height: 15),
            const SizedBox(height: 20),
            _buildPhoneNumberField(mCallProvider),
          ])),
      Expanded(
        child: DecoratedBox(
          decoration: keypadBackdrop ?? const BoxDecoration(),
          child: Center(child: _buildKeypad(mCallProvider, accounts)),
        ),
      ),
    ]);
  }

  Widget _buildKeypad(CallProvider mCallProvider, AccountsModel accounts) {
    final theme = Theme.of(context);
    final popup = widget.popUpMode;

    const double spacing = 8;
    double buttonSize = 72;
    if (Platform.isAndroid || Platform.isIOS)
      buttonSize = 92;
    else
      buttonSize = 72;

    final TextStyle numberStyle = const TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    );
    final TextStyle letterStyle = TextStyle(
      fontSize: 8,
      color: popup ? Colors.grey.shade400 : Colors.grey,
    );

    Widget buildKeypadButton(String number, String letters, VoidCallback onPressed) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          fixedSize: Size(buttonSize, buttonSize),
          shape: const CircleBorder(),
          side: popup
              ? BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.35),
                  width: 1,
                )
              : BorderSide.none,
          backgroundColor:
              popup ? Colors.grey.shade800 : Colors.grey.withOpacity(0.1),
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(number, style: numberStyle),
            if (letters.isNotEmpty)
              Text(
                letters,
                style: letterStyle,
                maxLines: 1,
              ),
          ],
        ),
      );
    }

    double mCallbuttonSize = 62;
    if (Platform.isAndroid || Platform.isIOS)
      mCallbuttonSize = 82;
    else
      mCallbuttonSize = 62;

    Widget buildCallButton(String number, VoidCallback onPressed) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          fixedSize: Size(mCallbuttonSize, mCallbuttonSize),
          shape: const CircleBorder(),
          side: popup
              ? BorderSide(color: Colors.green.shade300, width: 1.5)
              : BorderSide.none,
          backgroundColor: Colors.green.shade700,
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(size: 30.0, Icons.dialer_sip, color: Colors.white)
          ],
        ),
      );
    }

    return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: spacing),
            Wrap(spacing: spacing, children: <Widget>[
              buildKeypadButton('1', '', () => mCallProvider.phoneNumbCtrl.text += '1'),
              buildKeypadButton('2', 'ABC', () => mCallProvider.phoneNumbCtrl.text += '2'),
              buildKeypadButton('3', 'DEF', () => mCallProvider.phoneNumbCtrl.text += '3'),
            ]),
            const SizedBox(height: spacing),
            Wrap(spacing: spacing, children: <Widget>[
              buildKeypadButton('4', 'GHI', () => mCallProvider.phoneNumbCtrl.text += '4'),
              buildKeypadButton('5', 'JKL', () => mCallProvider.phoneNumbCtrl.text += '5'),
              buildKeypadButton('6', 'MNO', () => mCallProvider.phoneNumbCtrl.text += '6'),
            ]),
            const SizedBox(height: spacing),
            Wrap(spacing: spacing, children: <Widget>[
              buildKeypadButton('7', 'PQRS', () => mCallProvider.phoneNumbCtrl.text += '7'),
              buildKeypadButton('8', 'TUV', () => mCallProvider.phoneNumbCtrl.text += '8'),
              buildKeypadButton('9', 'WXYZ', () => mCallProvider.phoneNumbCtrl.text += '9'),
            ]),
            const SizedBox(height: spacing),
            Wrap(spacing: spacing, children: <Widget>[
              buildKeypadButton('*', '', () => mCallProvider.phoneNumbCtrl.text += '*'),
              buildKeypadButton('0', '+', () => mCallProvider.phoneNumbCtrl.text += '0'),
              buildKeypadButton('#', '', () => mCallProvider.phoneNumbCtrl.text += '#'),
            ]),
            const SizedBox(height: spacing * 2),

            buildCallButton('Call', () {
              mCallProvider.mInvite(context, false, accounts);
              if (mCallProvider.errorText == null || mCallProvider.errorText == "") {
                mCallProvider.clearText();
                if (widget.popUpMode) {
                  Navigator.of(context).pop();
                }
              } else {
                showAppSnackBar(context, message: mCallProvider.errorText!);
              }
            }),
            // ActionButton(
            //   icon: Icons.dialer_sip,
            //   fillColor: Colors.green,
            //   onPressed: () {
            //     mCallProvider.mInvite(context, false, accounts);
            //     if (mCallProvider.errorText == null || mCallProvider.errorText == "") {
            //       mCallProvider.clearText();
            //       if (widget.popUpMode) {
            //         Navigator.of(context).pop();
            //       }
            //     } else {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text(mCallProvider.errorText!)),
            //       );
            //     }
            //   },
            // ),
            // IconButton.filledTonal(
            //   onPressed: () => mCallProvider.phoneNumbCtrl.text = '',
            //   icon: const Icon(Icons.cancel),
            // ),
          ],
        ));
  }

  Widget _buildAccountsMenu(AccountsModel accounts, CallProvider mCallProvider,) {
    final popup = widget.popUpMode;
    final dropdownChild = Row(children: [
          Expanded(
              child: ButtonTheme(
                  child: DropdownButtonFormField<int>(
                    dropdownColor:
                        popup ? Colors.grey.shade800 : null,
                    style: popup
                        ? const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          )
                        : null,
                    iconEnabledColor:
                        popup ? Colors.white70 : null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      filled: popup,
                      fillColor:
                          popup ? Colors.grey.shade800.withOpacity(0.65) : null,
                    ),
                    value: accounts.selAccountId,
                    onChanged: (int? accId) {
                      accounts.setSelectedAccountById(accId!);
                    },
                    items: List.generate(
                        accounts.length, (index) => accMenuItem(accounts[index], index)),
                  ))),
          const SizedBox(width: 10),
          IconButton(
              tooltip: 'Logout',
              onPressed: () => { showLogoutDialog(context, _mCallProvider)},
              icon: Icon(Icons.logout,
                  color: popup ? Colors.white70 : null)),
          IconButton(
              tooltip: 'Settings',
              onPressed: _onShowSettings,
              icon: Icon(Icons.settings,
                  color: popup ? Colors.white70 : null))
        ]);
    if (!popup) {
      return Container(child: dropdownChild);
    }
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.grey.shade800,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      child: Container(child: dropdownChild),
    );
  }

  Widget _buildPhoneNumberField(CallProvider mCallProvider) {
    final popup = widget.popUpMode;
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
        color: popup ? Colors.grey.shade900.withOpacity(0.85) : Colors.transparent,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          // BoxShadow(
          //   color: Colors.black.withOpacity(0.4), // softer shadow
          //   offset: const Offset(2, 2),
          //   blurRadius: 4,
          //   spreadRadius: 1,
          // ),

          /*Optional */
          // BoxShadow(
          //   color: Colors.black,
          //   offset: const Offset(5.0, 5.0),
          //   blurRadius: 5.0,
          //   spreadRadius: 2.0,
          // ), //BoxShadow
          // BoxShadow(
          //   color: Colors.white,
          //   offset: const Offset(0.0, 0.0),
          //   blurRadius: 0.0,
          //   spreadRadius: 0.0,
          // ), //BoxShado
        ],
      ),
      child: TypeAheadField<SIPUser>(
        controller: mCallProvider.phoneNumbCtrl,
        hideOnEmpty: true,
        debounceDuration: const Duration(milliseconds: 100), // live update
        suggestionsCallback: (search) {
          return allSipUsers.where((element) => element.name.contains(search) || element.extension.contains(search)).take(5).toList();
        },

        itemBuilder: (context, SIPUser mSIPUser) {
          return Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    mSIPUser.name ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (mSIPUser.extension != null &&
                    mSIPUser.extension!.isNotEmpty)
                  TextButton(
                    onPressed:
                        () =>
                    {
                      mCallProvider.phoneNumbCtrl.text =
                          mSIPUser.extension ?? '',
                    },
                    child: Text(
                      mSIPUser.extension ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                SizedBox(width: 10),
              ],
            ),
          );
        },
        onSelected: (SIPUser mSIPUser) {
          mCallProvider.phoneNumbCtrl.text = mSIPUser.extension ?? '';
        },

        // /*Decor SuggestionBox if I clicked on Text field*/
        // decorationBuilder: (context, child) {
        //   return Material(
        //     elevation: 4,
        //     borderRadius: BorderRadius.circular(8),
        //     child: ConstrainedBox(
        //       constraints: BoxConstraints(
        //         maxHeight: 250,
        //       ),
        //       child: Scrollbar(
        //         thumbVisibility: true,
        //         child: SingleChildScrollView(
        //           child: child,
        //         ),
        //       ),
        //     ),
        //   );
        // },

        builder: (context, controller, focusNode) {
          return Material(
            color: popup ? Colors.grey.shade900.withOpacity(0.92) : null,
            borderRadius: BorderRadius.circular(8),
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              cursorColor: Colors.deepOrangeAccent,
              style: popup
                  ? const TextStyle(color: Colors.white, fontSize: 18)
                  : null,
              // textAlign: TextAlign.st,
              // style: TextStyle(fontSize: 18, color: textFieldColor),
              decoration: InputDecoration(
                labelText: "Enter /Search phone number",
                labelStyle: const TextStyle(color: Colors.white70),
                floatingLabelStyle: const TextStyle(color: Colors.deepOrangeAccent),
                filled: false,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // default line
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrangeAccent, width: 2),
                ),

                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 5, bottom: 5),
                  child: Material(
                    color: const Color(0xFF1C1B1F), // dark background
                    shape: const CircleBorder(),
                    elevation: 4, // gives the shadow
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        mCallProvider.phoneNumbCtrl.clear();
                        controller.clear();
                      },
                      child: const SizedBox(
                        width: 25,
                        height: 25,
                        child: Center(
                          child: Icon(
                            Icons.clear_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // border: UnderlineInputBorder(
                //   borderSide: BorderSide(color: Colors.grey), // bottom line color
                // ),
                // enabledBorder: UnderlineInputBorder(
                //   borderSide: BorderSide(color: Colors.grey), // bottom line when not focused
                // ),
                // focusedBorder: UnderlineInputBorder(
                //   borderSide: BorderSide(color: Colors.blue, width: 2), // line when focused
                // ),

                // border: OutlineInputBorder(
                //   borderSide: BorderSide(
                //     color: Colors.blue.withValues(alpha: 0.5),
                //   ),
                //   borderRadius: BorderRadius.circular(5),
                // ),
                // enabledBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //     color: Colors.blue.withValues(alpha: 0.5),
                //   ),
                //   borderRadius: BorderRadius.circular(5),
                // ),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(
                //     color: Colors.blue.withValues(alpha: 0.5),
                //   ),
                //   borderRadius: BorderRadius.circular(5),
                // ),
              ),
            ),
          );
        },
      ),
    );
  }

  DropdownMenuItem<int> accMenuItem(AccountModel acc, int index) {
    return DropdownMenuItem<int>(
        value: acc.myAccId,
        child: Row(
          children: [
            Icon(
              acc.regState == RegState.success||acc.regState == RegState.inProgress
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              color:
              acc.regState == RegState.success||acc.regState == RegState.inProgress ? Colors.green : Colors.red,
            ),
            SizedBox(width: 10),
            Text(acc.sipExtension),
          ],
        ));
  }

  void _onShowSettings() {
    setState(() {
      // Navigator.of(context).push(SettingsPage());
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SettingsPage(),
        ),
      );
    });
  }

  Future<void> showLogoutDialog(BuildContext context, CallProvider mCallProvider) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap a button
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Icons.logout, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  "Confirm Logout",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: Text(
              "Are you sure you want to logout?",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12,),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  mLogoutSession(mCallProvider);
                },
                child: Text("Logout"),
              ),
            ],
          ),
    );
  }

  Future<void> mLogoutSession(CallProvider mCallProvider) async {
      await mCallProvider.logout();
      await ExtensionUtil.deleteAllAccounts(context);
      await SharedPrefs().clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Domainscreen(),
        ),
        ModalRoute.withName("/Login"),
      );
    }
  
}
