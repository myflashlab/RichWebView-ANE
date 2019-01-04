RichWebViewII Adobe AIR Native Extension

*Jan 4, 2019 - V8.0.0*
* Rebuilt the whole thing from scratch. We are now using the latest APIs for WebView on Android and WKWebView on iOS
* Unlike before, the Android and iOS AS3 sides are NOT similar to each other anymore. This is a good move for this ANE because the native APIs are working very differently and making them look similar on the AIR side was preventing us from being able to bring all native features to the AIR side. With the new API structure however, we are able to keep the ANE updated with the latest changes on the native sides whenever they happen.
* You cannot use the older version of our webview ANE with this new one in a same project.