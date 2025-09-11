import 'dart:io';

import 'package:callingproject/src/pages/call_page.dart';
import 'package:callingproject/src/providers/layout_provider.dart';
import 'package:callingproject/src/widget/voicemail_widget.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/network_model.dart';

import '../event/PlaceCallEvent.dart';
import '../providers/call_logs_provider.dart';
import '../widget/loglist_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  AccountModel _account = AccountModel();
  double _windowWidth = 1150;
  var _selectedPageIndex = 0;
  EventTaxi eventBus = EventTaxiImpl.singleton();
  CallProvider _callProvider = CallProvider();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _account =
        (ModalRoute.of(context)?.settings.arguments as AccountModel?) ??
        AccountModel();

    _callProvider = Provider.of<CallProvider>(context, listen: false);
  }

  @override
  void initState() {
   

    eventBus.registerTo<PlaceCallEvent>(false).listen((event) {
      setState(() {
        _selectedPageIndex = 0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LayoutProvider>(context);
    return Scaffold(
      appBar:
          !Platform.isWindows && !Platform.isMacOS
              ? AppBar(title: Text('Aao Voip'), actions: [SizedBox(width: 10)])
              : null,
      body: getBody(provider),
      bottomNavigationBar:
          MediaQuery.sizeOf(context).width > _windowWidth
              ? null
              : BottomNavigationBar(
                currentIndex: _selectedPageIndex,
                onTap: _onTabTapped,
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
                              onPressed: () {},
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
        children: [CallPage(), LogListScreen() , VoicemailWidget()],
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
    }
  }
}
