// mywebsite file name

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_cookie_manager/flutter_cookie_manager.dart';

class MyWebsite extends StatefulWidget {
  const MyWebsite({Key? key}) : super(key: key);

  @override
  State<MyWebsite> createState() => _MyWebsiteState();
}

class _MyWebsiteState extends State<MyWebsite> {
  double _progress = 0;
  late InAppWebViewController _webViewController;
  final CookieManager _cookieManager = CookieManager();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirm Exit'),
              content: Text(
                  'Are you sure you want to exit the app? All cookies and cache will be cleared.'),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('Confirm'),
                  onPressed: () async {
                    await _webViewController.clearCache();
                    await _cookieManager.deleteCookies(
                        url: WebUri.uri(Uri.parse("https://cloudaiorg.com")));
                    Navigator.pop(context);
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                ),
              ],
            );
          },
        );
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.white, // Set status bar color to transparent
          statusBarIconBrightness:
              Brightness.dark, // Set status bar icons to dark
        ),
        child: SafeArea(
          child: Scaffold(
            body: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri.uri(Uri.parse("https://cloudaiorg.com")),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                    _webViewController = controller;
                    _setupJavaScriptHandler(controller);
                  },
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      _progress = progress / 100;
                    });
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;
                    if (uri.scheme == 'whatsapp' ||
                        uri.host == 'wa.me' ||
                        uri.host == 'api.whatsapp.com') {
                      await _launchWhatsApp();
                      return NavigationActionPolicy.CANCEL;
                    }
                    // Detect Google login URL and launch in system browser
                    if (uri.host == 'accounts.google.com') {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                        return NavigationActionPolicy
                            .CANCEL; // Prevent InAppWebView from loading
                      } else {
                        // Handle error if URL cannot be launched
                        //print('Could not launch Google login URL: $uri');
                        return NavigationActionPolicy
                            .ALLOW; // Allow InAppWebView to try loading (optional)
                      }
                    }
                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    await _injectJavaScript(controller);
                  },
                  /*
                  initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(
                      javaScriptEnabled: true,
                      javaScriptCanOpenWindowsAutomatically: true,
                      mediaPlaybackRequiresUserGesture: false,
                    ),
                  ),*/
                ),
                _progress < 1.0
                    ? LinearProgressIndicator(value: _progress)
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp() async {
    final link = WhatsAppUnilink(
      phoneNumber: '+918341254558',
      text: "Hey! I'm inquiring about the IT information",
    );

    try {
      await launch('$link');
    } catch (e) {
      print('Error launching WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't open WhatsApp: $e")),
      );
    }
  }

  void _setupJavaScriptHandler(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'handleWhatsAppLink',
      callback: (args) async {
        await _launchWhatsApp();
      },
    );
  }

  Future<void> _injectJavaScript(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: """
      const whatsappLink = document.querySelector('a.whatsapp-link');
      if (whatsappLink) {
        whatsappLink.addEventListener('click', (e) => {
          e.preventDefault();
          console.log('WhatsApp link clicked');
          window.flutter_inappwebview.callHandler('handleWhatsAppLink');
        });
        console.log('WhatsApp link event listener added');
      } else {
        console.log('WhatsApp link not found');
      }
    """);
  }
}
