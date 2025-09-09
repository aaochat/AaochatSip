import 'dart:async';
import 'dart:io';

import 'package:callingproject/src/pages/call_page.dart';
import 'package:callingproject/src/providers/layout_provider.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/network_model.dart';

import '../event/PlaceCallEvent.dart';
import '../providers/call_logs_provider.dart';
import '../widget/loglist_widget.dart';
import 'incomming_call_screen.dart';

class CallScreenWidget extends StatefulWidget {
  const CallScreenWidget({super.key});

  @override
  State<CallScreenWidget> createState() => _CallScreenWidgetState();
}

class _CallScreenWidgetState extends State<CallScreenWidget> {
  AccountModel _account = AccountModel();
  double _windowWidth = 1150;
  var _selectedPageIndex = 0;
  EventTaxi eventBus = EventTaxiImpl.singleton();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _account =
        (ModalRoute.of(context)?.settings.arguments as AccountModel?) ??
        AccountModel();
  }

  @override
  void initState() {
    Future.microtask(() {
      final provider = Provider.of<CallProvider>(context, listen: false);
      provider.AddData(context, _account);
      try {
        if (provider.errorText != null)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(provider.errorText!)));
      } on Exception catch (e) {
        print(e.toString());
      }
    });

    eventBus.registerTo<PlaceCallEvent>(false).listen((event) {
      setState(() {
        _selectedPageIndex = 0;
      });
    });
    super.initState();
    // windowManager.addListener(this);



    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   var callProvider = Provider.of<CallProvider>(context, listen: false);
    //   callProvider.AddData(context, _account);
    //
    //   try {
    //     if (callProvider.errorText != null) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text(callProvider.errorText!)),
    //       );
    //     }
    //   } on Exception catch (e) {
    //     print(e.toString());
    //   }
    // });
  }

  /*TODO This is Working Build Method*/
  // @override
  // Widget build(BuildContext context) {
  //   final calls = context.watch<AppCallsModel>();
  //   final provider = Provider.of<LayoutProvider>(context, listen: false);
  //   if (!calls.isEmpty) {
  //     try {
  //       provider.goToCallScreen();
  //     } catch (e) {
  //       print('Error in callStateChanged: $e');
  //     }
  //   } else {
  //     provider.goToDialPad();
  //   }
  //
  //   return NotificationListener<SizeChangedLayoutNotification>(
  //     onNotification: (notification) {
  //       return true;
  //     },
  //     child: SizeChangedLayoutNotifier(
  //       child: Scaffold(
  //         body: Container(
  //           width: MediaQuery.of(context).size.width,
  //           height: MediaQuery.of(context).size.height,
  //           child: Row(
  //             children: [
  //               Consumer<LayoutProvider>(
  //                 builder: (context, provider, child) {
  //                   return Container(
  //                     constraints: BoxConstraints(maxWidth: 400),
  //                     child: IndexedStack(
  //                       index: provider.currentScreen == 'dialpad' ? 0 : 1,
  //                       children: [
  //                         DialpadWidget(calls.isEmpty),
  //                         !calls.isEmpty && provider.currentScreen != 'dialpad'
  //                             ? IncommingCallScreen()
  //                             : SizedBox(),
  //                         // : SizedBox(),
  //                       ],
  //                     ),
  //                   );
  //                 },
  //               ),
  //               Expanded(
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     color: Theme.of(context).colorScheme.surface,
  //                     border: Border(
  //                       left: BorderSide(
  //                         color: Colors.grey.withOpacity(0.5),
  //                         width: 1,
  //                       ),
  //                     ),
  //                   ),
  //                   child: LogListScreen(),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LayoutProvider>(context, listen: false);
    return Scaffold(
      appBar: !Platform.isWindows && !Platform.isMacOS
          ? AppBar(
        title: Text('Aao Voip'),
        actions: [
          SizedBox(width: 10),
        ],
      )
          : null,
      body: getBody(),
      bottomNavigationBar: MediaQuery
          .sizeOf(context)
          .width > _windowWidth
          ? null
          : BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.dialpad_outlined), label: 'Phone'),
          BottomNavigationBarItem(
              icon: Icon(Icons.call), label: 'Call Logs'),
        ],
      ),
      bottomSheet: _networkLostIndicator(),
    );
  }

  // getBody(LayoutProvider provider) {
  //   // final calls = context.watch<AppCallsModel>();
  //   // if (calls.isEmpty){
  //   //   return;
  //   // }else{
  //   //   try {
  //   //     provider.goToCallScreen();
  //   //   } catch (e) {
  //   //     print('Error in callStateChanged: $e');
  //   //   }
  //   // }
  //   // if (!calls.isEmpty) {
  //   //   try {
  //   //     provider.goToCallScreen();
  //   //   } catch (e) {
  //   //     print('Error in callStateChanged: $e');
  //   //   }
  //   // } else {
  //   //   provider.goToDialPad();
  //   // }
  //   if (MediaQuery
  //       .of(context)
  //       .size
  //       .width > _windowWidth) {
  //     return NotificationListener<SizeChangedLayoutNotification>(
  //       onNotification: (notification) {
  //         return true;
  //       },
  //       child: SizeChangedLayoutNotifier(
  //         child: Scaffold(
  //           body: Container(
  //             width: MediaQuery
  //                 .of(context)
  //                 .size
  //                 .width,
  //             height: MediaQuery
  //                 .of(context)
  //                 .size
  //                 .height,
  //             child: Row(
  //               children: [
  //                 Consumer<LayoutProvider>(
  //                   builder: (context, provider, child) {
  //                     return Container(
  //                       constraints: BoxConstraints(maxWidth: 400),
  //                         child: IncommingCallScreen()
  //                       /*IndexedStack(
  //                         index: provider.currentScreen == 'dialpad' ? 0 : 1,
  //                         children: [
  //                           DialpadWidget(calls.isEmpty),
  //                           !calls.isEmpty && provider.currentScreen != 'dialpad'
  //                               ? IncommingCallScreen()
  //                               : SizedBox(),
  //                           // : SizedBox(),
  //                         ],
  //                       ),*/
  //                     );
  //                   },
  //                 ),
  //                 Expanded(
  //                   child: Container(
  //                     decoration: BoxDecoration(
  //                       color: Theme
  //                           .of(context)
  //                           .colorScheme
  //                           .surface,
  //                       border: Border(
  //                         left: BorderSide(
  //                           color: Colors.grey.withOpacity(0.5),
  //                           width: 1,
  //                         ),
  //                       ),
  //                     ),
  //                     child: LogListScreen(),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

  getBody() {
    if (MediaQuery
        .of(context)
        .size
        .width > _windowWidth) {
      return SizeChangedLayoutNotifier(
          child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              child: Row(children: [
                Container(
                    // color: Colors.grey.withOpacity(0.1),
                    padding: const EdgeInsets.all(10),
                    constraints: BoxConstraints(maxWidth: 400),
                    child: CallPage()),
                Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .surface,
                          border: Border(
                              left: BorderSide(
                                  color: Colors.black.withOpacity(1),
                                  width: 1)),
                        ),
                        child: LogListScreen()))
              ])));
    } else {
      return IndexedStack(
        index: _selectedPageIndex,
        children: [CallPage(), LogListScreen()],
      );
    }
  }

  Widget? _networkLostIndicator() {
    if (context
        .watch<NetworkModel>()
        .networkLost) {
      return Container(
          padding: EdgeInsets.all(20),
          width: double.infinity,
          color: Colors.red,
          child: const Text("Internet connection lost",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center));
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
