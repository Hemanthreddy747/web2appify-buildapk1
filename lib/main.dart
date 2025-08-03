import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'config.dart';

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
    return MaterialApp(
      title: config.appName,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WebViewScreen(config: config),
      debugShowCheckedModeBanner: false,
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
  late final WebViewController controller;
  bool isLoading = true;
  bool isAppLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setOrientation();
  }

  void _setOrientation() {
    // Listen to orientation changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOrientation();
    });
  }

  void _updateOrientation() {
    final orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.landscape) {
      // Hide system UI for fullscreen in landscape
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      // Normal screen in portrait - show status bar and navigation bar
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
    }
  }

  Future<void> _initializeApp() async {
    // Simulate app initialization
    await Future.delayed(const Duration(seconds: 2));

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.config.webviewUrl));

    setState(() {
      isAppLoading = false;
    });
  }

  Future<void> _refreshPage() async {
    setState(() {
      isLoading = true;
    });
    await controller.reload();
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  SystemNavigator.pop();
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    // Restore system UI when disposing
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _updateOrientation(); // Update orientation on each build

    if (isAppLoading) {
      return const Scaffold(body: Center(child: ThreeDotLoader()));
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: MediaQuery.of(context).orientation == Orientation.portrait
            ? AppBar(
                toolbarHeight: 0,
                backgroundColor: Colors.transparent,
                elevation: 0,
              )
            : null,
        body: RefreshIndicator(
          onRefresh: _refreshPage,
          child: Stack(
            children: [
              WebViewWidget(controller: controller),
              if (isLoading) const Center(child: ThreeDotLoader()),
            ],
          ),
        ),
      ),
    );
  }
}
