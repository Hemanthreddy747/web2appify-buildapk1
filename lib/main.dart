import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'config.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await AppConfig.loadConfig();
  runApp(MyApp(config: config));
}

class MyApp extends StatelessWidget {
  final AppConfig config;

  const MyApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    // Apply status bar and navigation bar colors
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: _parseColor(config.statusBarColor),
        statusBarIconBrightness: _getBrightness(config.statusBarColor),
        systemNavigationBarColor: _parseColor(config.navigationBarColor),
        systemNavigationBarIconBrightness: _getBrightness(
          config.navigationBarColor,
        ),
      ),
    );

    // Set preferred orientation
    if (config.orientation == 'landscape') {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else if (config.orientation == 'portrait') {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return MaterialApp(
      title: config.appName,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(config: config),
      debugShowCheckedModeBanner: false,
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.white;
    }
  }

  Brightness _getBrightness(String colorString) {
    final color = _parseColor(colorString);
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Brightness.dark : Brightness.light;
  }
}

class SplashScreen extends StatefulWidget {
  final AppConfig config;

  const SplashScreen({super.key, required this.config});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWebView();
  }

  void _navigateToWebView() async {
    await Future.delayed(
      Duration(milliseconds: widget.config.splashScreenDelay),
    );
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(config: widget.config),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.web, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              widget.config.appName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            const ThreeDotLoader(),
          ],
        ),
      ),
    );
  }
}

class ThreeDotLoader extends StatefulWidget {
  const ThreeDotLoader({super.key});

  @override
  State<ThreeDotLoader> createState() => _ThreeDotLoaderState();
}

class _ThreeDotLoaderState extends State<ThreeDotLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final opacity = ((_animation.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = opacity > 0.5 ? 2 - opacity * 2 : opacity * 2;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final AppConfig config;

  const WebViewScreen({super.key, required this.config});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: false,
      mediaPlaybackRequiresUserGesture: false,
      useOnDownloadStart: true,
      javaScriptEnabled: true,
      javaScriptCanOpenWindowsAutomatically: true,
      supportZoom: false,
      cacheEnabled: true,
      clearCache: false,
      transparentBackground: true,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
      mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      safeBrowsingEnabled: true,
      supportMultipleWindows: true,
      builtInZoomControls: false,
      geolocationEnabled: true,
      allowContentAccess: true,
      allowFileAccess: true,
      overScrollMode: AndroidOverScrollMode.OVER_SCROLL_NEVER,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
      allowsBackForwardNavigationGestures: true,
      allowsLinkPreview: true,
    ),
  );

  bool isLoading = true;
  bool isWebViewReady = false;
  bool hasInternet = true;
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;
  double progress = 0;
  String? initialUrl;

  @override
  void initState() {
    super.initState();
    _initializeResources();
    _setupConnectivityListener();
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();
    super.dispose();
  }

  void _setupConnectivityListener() {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      final bool connected = !result.contains(ConnectivityResult.none);
      if (mounted && hasInternet != connected) {
        setState(() {
          hasInternet = connected;
        });
        // Only reload if we regain connection and webview exists
        if (connected && webViewController != null && !isLoading) {
          webViewController!.reload();
        }
      }
    });
  }

  Future<void> _initializeResources() async {
    try {
      await _checkConnectivity();
      final lastUrl = await getLastVisitedUrl();
      if (mounted) {
        setState(() {
          initialUrl = lastUrl ?? widget.config.webviewUrl;
        });
      }
    } catch (e) {
      print("Error initializing resources: $e");
      if (mounted) {
        setState(() {
          initialUrl = widget.config.webviewUrl;
        });
      }
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final bool connected = !connectivityResult.contains(
      ConnectivityResult.none,
    );

    if (mounted) {
      setState(() {
        hasInternet = connected;
      });
    }
  }

  Future<void> saveLastVisitedUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_url', url);
  }

  Future<String?> getLastVisitedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_url');
  }

  bool _isNetworkError(WebResourceError error) {
    // Check error description for network-related keywords
    final networkKeywords = [
      'network',
      'connection',
      'timeout',
      'host',
      'dns',
      'internet',
      'offline',
      'unreachable',
      'failed to connect',
      'no internet',
      'connection refused',
      'server not found',
    ];

    final description = error.description.toLowerCase();

    // Check if any network-related keyword is found in the error description
    return networkKeywords.any((keyword) => description.contains(keyword));
  }

  Future<bool> _onWillPop() async {
    if (webViewController != null) {
      if (await webViewController!.canGoBack()) {
        webViewController!.goBack();
        return false;
      } else {
        if (widget.config.exitDialogEnabled) {
          return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(widget.config.exitDialogTitle),
                  content: Text(widget.config.exitDialogMessage),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Exit'),
                    ),
                  ],
                ),
              ) ??
              false;
        }
        return true;
      }
    }
    return true;
  }

  void _showNoInternetDialog() {
    // Don't show dialog if webview has loaded successfully
    if (isWebViewReady && !isLoading) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: Text(widget.config.offlineMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkConnectivity();
                if (hasInternet && webViewController != null) {
                  webViewController!.reload();
                }
              },
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              if (!hasInternet)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      Text(
                        widget.config.offlineMessage,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _checkConnectivity();
                          if (hasInternet && webViewController != null) {
                            webViewController!.reload();
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (initialUrl == null)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.web, size: 80, color: Colors.blue),
                      const SizedBox(height: 16),
                      Text(
                        widget.config.loadingMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ThreeDotLoader(),
                    ],
                  ),
                )
              else
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: WebUri(initialUrl!)),
                  initialOptions: options,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    setState(() {
                      isWebViewReady = true;
                    });
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      isLoading = true;
                    });
                    if (url != null) {
                      saveLastVisitedUrl(url.toString());
                    }
                  },
                  onLoadStop: (controller, url) {
                    setState(() {
                      isLoading = false;
                    });
                    if (url != null) {
                      saveLastVisitedUrl(url.toString());
                    }
                  },
                  onProgressChanged: (controller, progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    if (url != null) {
                      saveLastVisitedUrl(url.toString());
                    }
                  },
                  onReceivedError: (controller, request, error) {
                    print("WebView Error: ${error.description}");
                    if (mounted) {
                      // Only show internet dialog for network-related errors
                      // and only if the page hasn't loaded successfully yet
                      if (_isNetworkError(error) && isLoading) {
                        _checkConnectivity();
                        if (!hasInternet) {
                          _showNoInternetDialog();
                        }
                      }
                    }
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                        var uri = navigationAction.request.url;
                        if (uri != null) {
                          return NavigationActionPolicy.ALLOW;
                        }
                        return NavigationActionPolicy.CANCEL;
                      },
                  onConsoleMessage: (controller, consoleMessage) {
                    print("Console Message: ${consoleMessage.message}");
                  },
                  onReceivedServerTrustAuthRequest:
                      (controller, challenge) async {
                        return ServerTrustAuthResponse(
                          action: ServerTrustAuthResponseAction.PROCEED,
                        );
                      },
                ),
              if (isLoading &&
                  isWebViewReady &&
                  initialUrl != null &&
                  hasInternet)
                Container(
                  color: Colors.white.withOpacity(0.8),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}%",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.config.loadingMessage,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
