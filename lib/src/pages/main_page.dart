import 'dart:io';

import 'package:callingproject/src/event/refresh_call_log_event.dart';
import 'package:callingproject/src/event/refresh_voice_mail_event.dart';
import 'package:callingproject/src/models/call_model.dart';
import 'package:callingproject/src/pages/call_page.dart';
import 'package:callingproject/src/providers/layout_provider.dart';
import 'package:callingproject/src/utils/layout_util.dart';
import 'package:callingproject/src/widget/voicemail_widget.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/network_model.dart';
import 'package:window_manager/window_manager.dart';

import '../event/place_call_event.dart';
import '../widget/loglist_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double _windowWidth = 1150;
  var _selectedPageIndex = 0;
  EventTaxi eventBus = EventTaxiImpl.singleton();

  @override
  void initState() {
    context.read<AppCallsModel>().onNewIncomingCall = () {
      if (Platform.isWindows) {
        WindowManager.instance.setAlwaysOnTop(true);
        WindowManager.instance.focus();
        Future.delayed(Duration(seconds: 2), () {
          WindowManager.instance.setAlwaysOnTop(false);
        });


      } else if (Platform.isMacOS) {
        // MacOs specific code here
        bringWindowToFront();
      } else if(LayoutUtil.isMobile()){

        setState(() {
          _selectedPageIndex = 0;
        });
      }

    };

    final selectedAccountId = context
        .read<AccountsModel>()
        .selAccountId;
    final selectedAccount = context
        .read<AccountsModel>()
        .accounts
        .firstWhere(
          (element) => element.myAccId == selectedAccountId,
    );

    context.read<LayoutProvider>().connectToSocket(selectedAccount.sipServer);

    eventBus.registerTo<PlaceCallEvent>(false).listen((event) {
      setState(() {
        _selectedPageIndex = 0;
      });
    });
    super.initState();
  }

  Future<void> bringWindowToFront() async {
    await windowManager.show(); // In case the window is hidden
    await windowManager.focus(); // Bring it to the front
    await windowManager.setAlwaysOnTop(true); // Temporarily set on top
    await Future.delayed(Duration(milliseconds: 100)); // Small delay
    await windowManager.setAlwaysOnTop(false); // Remove always on top
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LayoutProvider>(context);
    return Scaffold(
      appBar:
          !Platform.isWindows && !Platform.isMacOS
              ? AppBar(
              leading: Padding(padding: EdgeInsets.all(10),child: Image.asset('assets/voip_logo.png',)),
              title: Text('Aao VOIP', style: TextStyle(fontSize: 20),), actions: [SizedBox(width: 10)])
              : null,
      body: getBody(provider),
      bottomNavigationBar:
          MediaQuery.sizeOf(context).width > _windowWidth
              ? null
              : BottomNavigationBar(
                currentIndex: _selectedPageIndex,
                onTap: _onTabTapped,
                selectedItemColor: Colors.orange,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dialpad_outlined),
                    label: 'Phone',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.call),
                    label: 'Call Logs',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.voice_chat),
                    label: 'Voice Mails',
                  ),
                ],
              ),
      bottomSheet: _networkLostIndicator(),
    );
  }


  getBody(LayoutProvider provider) {
    if (MediaQuery.of(context).size.width > _windowWidth) {
      return SizeChangedLayoutNotifier(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Row(
            children: [
              Container(
                // color: Colors.grey.withOpacity(0.1),
                padding: const EdgeInsets.all(10),
                constraints: BoxConstraints(maxWidth: 400),
                child: CallPage(),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: Border(
                      left: BorderSide(
                        color: Colors.black.withOpacity(1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        color: Colors.grey.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade900,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      provider.goToCallLogs();
                                    },
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color:
                                            provider.sideScreen == 'call-logs'
                                                ? Colors.blueGrey
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Call Logs',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                provider.sideScreen ==
                                                        'call-logs'
                                                    ? Colors.white
                                                    : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      provider.goToVoiceMails();
                                    },
                                    child: Container(
                                      height: 35,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            provider.sideScreen == 'voice-mails'
                                                ? Colors.blueGrey
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Voice Mails',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                provider.sideScreen ==
                                                        'voice-mails'
                                                    ? Colors.white
                                                    : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),

                            IconButton(
                              onPressed: () {
                                if(provider.sideScreen == 'voice-mails'){
                                  eventBus.fire(RefreshVoiceMailEvent());
                                } else if(provider.sideScreen == 'call-logs'){
                                  eventBus.fire(RefreshCallLogEvent(isUpdate: true));
                                }
                              },
                              icon: Icon(Icons.refresh),
                            ),
                          ],
                        ),
                      ),

                      if (provider.sideScreen == 'voice-mails')
                        Expanded(child: VoicemailWidget()),

                      if (provider.sideScreen == 'call-logs')
                        Expanded(child: LogListScreen()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return IndexedStack(
        index: _selectedPageIndex,
        children: [CallPage(),
          Column(children: [
            Align(alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Call Logs",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )),
            Expanded(child: LogListScreen()),
          ]),
          Column(children: [
            Align(alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Voice Mails",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )),
            Expanded(child: VoicemailWidget()),
          ],
          )
        ],
      );
    }
  }

  Widget? _networkLostIndicator() {
    if (context.watch<NetworkModel>().networkLost) {
      return Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        color: Colors.red,
        child: const Text(
          "Internet connection lost",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }
    return null;
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });

    final provider = Provider.of<LayoutProvider>(context, listen: false);
    if (index == 0) {
      provider.goToCallLogs();
    } else if (index == 2) {
      provider.getVoiceMailList(context);
    }
  }
}
