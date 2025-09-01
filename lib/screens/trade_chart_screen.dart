// lib/screens/trade_chart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome
import 'package:webview_flutter/webview_flutter.dart';
// Import for AndroidWebView specific settings
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOSWebView specific settings
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class TradeChartScreen extends StatefulWidget {
  final String symbol;

  const TradeChartScreen({super.key, required this.symbol});

  @override
  State<TradeChartScreen> createState() => _TradeChartScreenState();
}

class _TradeChartScreenState extends State<TradeChartScreen> {
  late final WebViewController _controller;
  var _loadingPercentage = 0;

  @override
  void initState() {
    super.initState();

    // --- New: Configure WebView platform specifics ---
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // --- End New: Configure WebView platform specifics ---

    _controller = controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              _loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _loadingPercentage = 100;
              // --- New: Inject JavaScript to adjust TradingView chart after load ---
              _controller.runJavaScript('''
                if (window.TradingView && window.TradingView.widget) {
                    var widgetContainer = document.getElementById('tradingview_chart');
                    if (widgetContainer) {
                        widgetContainer.style.width = '100vw'; // Use viewport width
                        widgetContainer.style.height = '100vh'; // Use viewport height
                        // Attempt to resize the widget. This might require specific API calls
                        // depending on the TradingView widget version and configuration.
                        // For now, rely on autosize and CSS.
                    }
                }
              ''');
              // --- End New ---
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web resource error: ${error.description}');
          },
        ),
      )
      // Load the dynamically generated HTML string
      ..loadHtmlString(_getTradingViewHtml(widget.symbol));

    // --- New: Enable Android specific settings ---
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // --- End New ---

    // --- New: Force landscape mode when screen is initialized ---
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // --- End New ---
  }

  @override
  void dispose() {
    // --- New: Revert to portrait mode when screen is disposed ---
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        // --- New: Hide app bar for full screen landscape experience ---
        // automaticallyImplyLeading: true, // Show back button
      ),
      // --- New: Make body take full screen even under app bar ---
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Use a `SafeArea` to avoid notch/status bar on iOS/Android
          SafeArea(child: WebViewWidget(controller: _controller)),
          if (_loadingPercentage < 100)
            LinearProgressIndicator(value: _loadingPercentage / 100.0),
        ],
      ),
    );
  }

  /// Generates a full HTML document with the TradingView widget,
  /// injecting the specific stock symbol.
  String _getTradingViewHtml(String symbol) {
    // For Indian stocks, it's often necessary to prefix with the exchange, e.g., "NSE:"
    // You might need to adjust this logic based on the symbols your API provides.
    final formattedSymbol = symbol.contains(':') ? symbol : 'NSE:$symbol';

    return '''
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
          <title>TradingView Chart</title>
          <style>
              body, html {
                  margin: 0;
                  padding: 0;
                  width: 100vw; /* Force to viewport width */
                  height: 100vh; /* Force to viewport height */
                  overflow: hidden;
                  display: flex; /* Use flexbox for centering */
                  justify-content: center;
                  align-items: center;
              }
              .tradingview-widget-container {
                  width: 100%;
                  height: 100%;
                  display: flex;
                  justify-content: center;
                  align-items: center;
              }
              #tradingview_chart {
                  width: 100%;
                  height: 100%;
              }
          </style>
      </head>
      <body>
          <div class="tradingview-widget-container">
              <div id="tradingview_chart"></div>
          </div>
          <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
          <script type="text/javascript">
              document.addEventListener('DOMContentLoaded', function() {
                  new TradingView.widget({
                      "autosize": true,
                      "symbol": "$formattedSymbol",
                      "interval": "D",
                      "timezone": "Asia/Kolkata",
                      "theme": "light",
                      "style": "1",
                      "locale": "in",
                      "enable_publishing": false,
                      "allow_symbol_change": true,
                      "container_id": "tradingview_chart"
                  });
              });
          </script>
          </body>
      </html>
    ''';
  }
}
