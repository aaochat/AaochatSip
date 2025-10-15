import 'dart:io';

import 'package:callingproject/src/Providers/domain_provider.dart';
import 'package:callingproject/src/Providers/login_provider.dart';
import 'package:callingproject/src/Providers/theme_provider.dart';
import 'package:callingproject/src/models/call_model.dart';
import 'package:callingproject/src/pages/domain_screen.dart';
import 'package:callingproject/src/pages/login_screen.dart';
import 'package:callingproject/src/pages/main_page.dart';
import 'package:callingproject/src/providers/call_logs_provider.dart';
import 'package:callingproject/src/providers/layout_provider.dart';
import 'package:callingproject/src/providers/signup_provider.dart';
import 'package:callingproject/src/splash_screen.dart';
import 'package:callingproject/src/utils/Constants.dart';
import 'package:callingproject/src/utils/app_settings.dart';
import 'package:callingproject/src/utils/shared_prefs.dart';
import 'package:callingproject/src/widget/dialpad_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';
import 'package:siprix_voip_sdk/cdrs_model.dart';
import 'package:siprix_voip_sdk/devices_model.dart';
import 'package:siprix_voip_sdk/logs_model.dart';
import 'package:siprix_voip_sdk/messages_model.dart';
import 'package:siprix_voip_sdk/network_model.dart';
import 'package:siprix_voip_sdk/siprix_voip_sdk.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.init();

  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows|| 
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions =  WindowOptions(
      size: Size(1200, 750),
      minimumSize: Size(1200, 750),
      center: true,
      title: 'Aao VOIP',
      backgroundColor: Colors.transparent,
      titleBarStyle: Platform.isWindows? TitleBarStyle.hidden : TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  LogsModel logsModel = LogsModel(true);
  CdrsModel cdrsModel = CdrsModel();
  AccountsModel accountsModel = AccountsModel(logsModel);
  MessagesModel messagesModel = MessagesModel(accountsModel, logsModel);
  AppCallsModel callsModel = AppCallsModel(accountsModel, logsModel, cdrsModel);
  // CallsModel mCallsModel = CallsModel(accountsModel, logsModel, cdrsModel); //List of calls

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => DomainProvider()),
        ChangeNotifierProvider(create: (_) => SignupProvider()),

        ChangeNotifierProvider(create: (_) => CallProvider()),
        ChangeNotifierProvider(create: (_) => LayoutProvider()),
        ChangeNotifierProvider(create: (_) => AccountsModel()),
        ChangeNotifierProvider(
          create: (context) => AccountsModel(logsModel),
        ),
        ChangeNotifierProvider(create: (context) => NetworkModel(logsModel)),
        ChangeNotifierProvider(create: (context) => DevicesModel(logsModel)),
        ChangeNotifierProvider(create: (context) => messagesModel),
        ChangeNotifierProvider(create: (context) => callsModel),
        ChangeNotifierProvider(create: (context) => cdrsModel),
        ChangeNotifierProvider(create: (context) => logsModel),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static String _ringtonePath = "";

  @override
  State<MyApp> createState() => _MyAppState();

  /// Returns ringtone's path saved on device
  static String getRingtonePath() => _ringtonePath;

  void writeRingtoneAsset() async {
    _ringtonePath = await writeAssetAndGetFilePath("ringtone.mp3");
  }

  static Future<String> writeAssetAndGetFilePath(String assetsFileName) async {
    var homeFolder = await SiprixVoipSdk().homeFolder();
    var filePath = '$homeFolder$assetsFileName';

    var file = File(filePath);
    var exists = file.existsSync();
    debugPrint("writeAsset: '$filePath' exists:$exists");
    if (exists) return filePath;

    final byteData = await rootBundle.load('assets/$assetsFileName');
    await file.create(recursive: true);
    file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return filePath;
  }

  static Future<String> getRecFilePathName(int callId) async {
    String dateTime = DateFormat('yyyyMMdd_HHmmss_').format(DateTime.now());
    var homeFolder = await SiprixVoipSdk().homeFolder();
    var filePath = '$homeFolder$dateTime$callId.mp3';
    return filePath;
  }
}
typedef PageContentBuilder = Widget Function(
    [Object? arguments]);

class _MyAppState extends State<MyApp> {
  Map<String, PageContentBuilder> routes = {
    '/': ([ Object? arguments]) => Splashscreen(),
    '/domain': ([Object? arguments]) => Domainscreen(),
    '/login': ([Object? arguments]) => LoginScreen(),
    '/callscreen': ([Object? arguments]) => MainPage(),
    DialpadWidget.routeName: ([Object? arguments]) =>
    const DialpadWidget(true),
  };

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final PageContentBuilder? pageContentBuilder = routes[name!];
    if (pageContentBuilder != null) {
      if (settings.arguments != null) {
        final Route route = MaterialPageRoute<Widget>(
            builder: (context) =>
                pageContentBuilder(settings.arguments));
        return route;
      } else {
        final Route route = MaterialPageRoute<Widget>(
            builder: (context) => pageContentBuilder());
        return route;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aao Voip',
      home: const Splashscreen(),
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeSiprix(context.read<LogsModel>());
    widget.writeRingtoneAsset();
    _readSavedState();
  }

  static void _initializeSiprix(LogsModel? logsModel) async {
    debugPrint('_initializeSiprix');
    InitData iniData = InitData();
    iniData.brandName = "AaoVOIP";
    iniData.license = AppSettings.LICENSE_KEY;
    iniData.logLevelFile = LogLevel.info;
    iniData.logLevelIde = LogLevel.info;
    await SiprixVoipSdk().initialize(iniData, logsModel);
  }

  void _readSavedState() async {
    debugPrint('_readSavedState');
    String accJsonStr = await SharedPrefs().getValue(Constants.ACCOUNTS) ?? '';
    String cdrsJsonStr = await SharedPrefs().getValue(Constants.CRDS) ?? '';
    _loadModels(accJsonStr, cdrsJsonStr);
  }

  void _loadModels(String accJsonStr, String cdrsJsonStr) {
    //Accounts
    AccountsModel accsModel = context.read<AccountsModel>();
    accsModel.onSaveChanges = _saveAccountChanges;

    //CDRs (Call Details Records)
    CdrsModel cdrs = context.read<CdrsModel>();
    cdrs.onSaveChanges = _saveCdrsChanges;

    //Load accounts, then other models
    accsModel.loadFromJson(accJsonStr).then((val) {
      cdrs.loadFromJson(cdrsJsonStr);
    });

    //Load devices
    context.read<DevicesModel>().load();
  }

  Future<void> _saveCdrsChanges(String cdrsJsonStr) async {
    await SharedPrefs().setValue(Constants.CRDS, cdrsJsonStr);
  }

  Future<void> _saveAccountChanges(String accountsJsonStr) async {
    await SharedPrefs().setValue(Constants.ACCOUNTS, accountsJsonStr);
  }
}
