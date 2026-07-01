import 'dart:io';

import 'package:aaochat_sip/src/models/call_model.dart';
import 'package:aaochat_sip/src/pages/domain_screen.dart';
import 'package:aaochat_sip/src/pages/login_screen.dart';
import 'package:aaochat_sip/src/pages/main_page.dart';
import 'package:aaochat_sip/src/pages/onboarding_flow.dart';
import 'package:aaochat_sip/src/pages/settings_page.dart';
import 'package:aaochat_sip/src/providers/call_provider.dart';
import 'package:aaochat_sip/src/providers/domain_provider.dart';
import 'package:aaochat_sip/src/providers/layout_provider.dart';
import 'package:aaochat_sip/src/providers/login_provider.dart';
import 'package:aaochat_sip/src/providers/theme_provider.dart';
import 'package:aaochat_sip/src/splash_screen.dart';
import 'package:aaochat_sip/src/utils/app_branding.dart';
import 'package:aaochat_sip/src/utils/app_settings.dart';
import 'package:aaochat_sip/src/utils/constants.dart';
import 'package:aaochat_sip/src/utils/shared_prefs.dart';
import 'package:aaochat_sip/src/widget/dialpad_widget.dart';
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

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    await windowManager.ensureInitialized();

    final windowOptions = WindowOptions(
      size: const Size(1200, 750),
      minimumSize: const Size(900, 600),
      center: true,
      title: AppBranding.appName,
      backgroundColor: Colors.transparent,
      titleBarStyle:
          Platform.isWindows ? TitleBarStyle.hidden : TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final logsModel = LogsModel(true);
  final cdrsModel = CdrsModel();
  final accountsModel = AccountsModel(logsModel);
  final messagesModel = MessagesModel(accountsModel, logsModel);
  final callsModel = AppCallsModel(accountsModel, logsModel, cdrsModel);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => DomainProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
        ChangeNotifierProvider(create: (_) => LayoutProvider()),
        ChangeNotifierProvider(create: (_) => accountsModel),
        ChangeNotifierProvider(create: (_) => NetworkModel(logsModel)),
        ChangeNotifierProvider(create: (_) => DevicesModel(logsModel)),
        ChangeNotifierProvider(create: (_) => messagesModel),
        ChangeNotifierProvider(create: (_) => callsModel),
        ChangeNotifierProvider(create: (_) => cdrsModel),
        ChangeNotifierProvider(create: (_) => logsModel),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static String _ringtonePath = '';

  @override
  State<MyApp> createState() => _MyAppState();

  static String getRingtonePath() => _ringtonePath;

  Future<void> writeRingtoneAsset() async {
    for (final asset in [
      AppBranding.ringtoneAsset,
      AppBranding.ringtoneAssetFallback,
    ]) {
      try {
        _ringtonePath = await writeAssetAndGetFilePath(asset);
        if (File(_ringtonePath).existsSync()) return;
      } catch (_) {}
    }
  }

  static Future<String> writeAssetAndGetFilePath(String assetsFileName) async {
    final homeFolder = await SiprixVoipSdk().homeFolder();
    final filePath = '$homeFolder${assetsFileName.split('/').last}';

    final file = File(filePath);
    if (file.existsSync()) return filePath;

    final byteData = await rootBundle.load(assetsFileName);
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return filePath;
  }

  static Future<String> getRecFilePathName(int callId) async {
    final dateTime = DateFormat('yyyyMMdd_HHmmss_').format(DateTime.now());
    final homeFolder = await SiprixVoipSdk().homeFolder();
    return '$homeFolder$dateTime$callId.mp3';
  }
}

typedef PageContentBuilder = Widget Function([Object? arguments]);

class _MyAppState extends State<MyApp> {
  final Map<String, PageContentBuilder> routes = {
    '/': ([Object? arguments]) => const Splashscreen(),
    '/domain': ([Object? arguments]) => const Domainscreen(),
    '/login': ([Object? arguments]) => const LoginScreen(),
    MainPage.routeName: ([Object? arguments]) => const MainPage(),
    OnboardingFlow.routeName: ([Object? arguments]) => const OnboardingFlow(),
    DialpadWidget.routeName: ([Object? arguments]) => const DialpadWidget(true),
    SettingsPage.routeName: ([Object? arguments]) => const SettingsPage(),
  };

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    final pageContentBuilder = routes[name];
    if (pageContentBuilder != null) {
      return MaterialPageRoute<Widget>(
        builder: (context) => pageContentBuilder(settings.arguments),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppBranding.appName,
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

  static Future<void> _initializeSiprix(LogsModel? logsModel) async {
    final iniData = InitData()
      ..brandName = AppSettings.brandName
      ..license = AppSettings.LICENSE_KEY
      ..logLevelFile = LogLevel.info
      ..logLevelIde = LogLevel.info;
    await SiprixVoipSdk().initialize(iniData, logsModel);
  }

  void _readSavedState() async {
    final accJsonStr = await SharedPrefs().getValue(Constants.ACCOUNTS) ?? '';
    final cdrsJsonStr = await SharedPrefs().getValue(Constants.CRDS) ?? '';
    if (!mounted) return;
    _loadModels(accJsonStr, cdrsJsonStr);
  }

  void _loadModels(String accJsonStr, String cdrsJsonStr) {
    final accsModel = context.read<AccountsModel>();
    accsModel.onSaveChanges = _saveAccountChanges;

    final cdrs = context.read<CdrsModel>();
    cdrs.onSaveChanges = _saveCdrsChanges;

    accsModel.loadFromJson(accJsonStr).then((_) {
      cdrs.loadFromJson(cdrsJsonStr);
    });

    context.read<DevicesModel>().load();
  }

  Future<void> _saveCdrsChanges(String cdrsJsonStr) async {
    await SharedPrefs().setValue(Constants.CRDS, cdrsJsonStr);
  }

  Future<void> _saveAccountChanges(String accountsJsonStr) async {
    await SharedPrefs().setValue(Constants.ACCOUNTS, accountsJsonStr);
  }
}
