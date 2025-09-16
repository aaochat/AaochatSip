import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:siprix_voip_sdk/accounts_model.dart';

class ApiBoatWidget extends StatefulWidget {
  final String mURL;
  const ApiBoatWidget({super.key,required this.mURL});

  @override
  State<ApiBoatWidget> createState() => _ApiBoatWidgetState();
}

class _ApiBoatWidgetState extends State<ApiBoatWidget> {
  final GlobalKey webViewKey = GlobalKey();
  bool isLoading = true;

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;
  WebViewEnvironment? webViewEnvironment;

  setUpWebView() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final availableVersion = await WebViewEnvironment.getAvailableVersion();
      assert(availableVersion != null,
      'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.');

      webViewEnvironment = await WebViewEnvironment.create(
          settings:
          WebViewEnvironmentSettings(userDataFolder: 'YOUR_CUSTOM_PATH'));
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    }
  }

  @override
  void initState() {
    setUpWebView();
    super.initState();

    pullToRefreshController = kIsWeb ||
        ![TargetPlatform.iOS, TargetPlatform.android]
            .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          webViewController?.loadUrl(
              urlRequest:
              URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedAccountId = context
        .read<AccountsModel>()
        .selAccountId;
    final selectedAccount = context
        .read<AccountsModel>()
        .accounts
        .firstWhere(
          (element) => element.myAccId == selectedAccountId,
    );
    String mMainUrl = widget.mURL.split("/").last;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aao VOIP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            key: webViewKey,
            webViewEnvironment: webViewEnvironment,
            initialUrlRequest: URLRequest(
                url: WebUri("http://" + selectedAccount.sipServer + ":3000/call-analytics/" + mMainUrl)),
            initialSettings: settings,
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {},
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var uri = navigationAction.request.url!;

              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) async {
              pullToRefreshController?.endRefreshing();
            },
            onReceivedError: (controller, request, error) {
              pullToRefreshController?.endRefreshing();
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                pullToRefreshController?.endRefreshing();
              }
            },
            onConsoleMessage: (controller, consoleMessage) {
              if (kDebugMode) {
                print(consoleMessage);
              }
            },
          ),
        ],
      ),
    );
  }
}
