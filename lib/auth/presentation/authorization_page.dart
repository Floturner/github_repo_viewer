import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:github_repo_viewer/auth/infrastructure/github_authenticator.dart';

class AuthorizationPage extends StatefulWidget {
  final Uri authorizationUrl;
  final void Function(Uri redirectUrl) onAuthorizationCodeRedirectAttempt;

  const AuthorizationPage({
    super.key,
    required this.authorizationUrl,
    required this.onAuthorizationCodeRedirectAttempt,
  });

  @override
  State<AuthorizationPage> createState() => _AuthorizationPageState();
}

class _AuthorizationPageState extends State<AuthorizationPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final controller = WebViewController.fromPlatformCreationParams(
      const PlatformWebViewControllerCreationParams(),
    );

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _controller.clearCache();
            _controller.clearLocalStorage();
            WebViewCookieManager().clearCookies();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url
                .startsWith(GithubAuthenticator.redirectUrl.toString())) {
              widget.onAuthorizationCodeRedirectAttempt(Uri.parse(request.url));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(widget.authorizationUrl);

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
