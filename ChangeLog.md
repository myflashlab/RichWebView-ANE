# RichWebViewII Adobe AIR Native Extension

*Jul 30, 2020 - v9.6.0*
- Upgrade dependencies to the latest versions.
- Fixed some minor issues and refactor native codes.

*Apr 05, 2020 - V9.0.2*
- Added androidx dependencies instead of android support libraries

*Aug 4, 2019 - V8.0.91*
* Added Android 64-bit support
* Supports iOS 10+

*Feb 21, 2019 - V8.0.8*
* Added method `setFocus()` to the WebView class on the iOS side. Call this method when the webview window loses focus and won't respond to user's touches. This problem happens when your app is in landscape and your user tries to pick a file with the file picker option in HTML.

*Feb 5, 2019 - V8.0.7*
* Added property `_webviewInstance.backForwardList` to both Android and iOS sides. it returns an Array of objects containing the history list of urls that the user has navigated in the current session of the webview instance window.
* Added listener `WebViewEvents.SCROLLING` to both Android and iOS sides to know the scrolling x/y position of the webview window.
```actionscript
_webviewInstance.addEventListener(WebViewEvents.SCROLLING, onWebviewFile_Scrolling);

function onWebviewFile_Scrolling(e:WebViewEvents):void
{
    trace("onWebviewFile_Scrolling > " + "x = " + e.x + " y = " + e.y);
}
```

*Jan 15, 2019 - V8.0.3*
* Added listener `WebViewEvents.KEYBOARD_VISIBILITY` to know if Android SoftKeyboard is open or not. use like below:

```actionscript
RichWebView.android.addEventListener(WebViewEvents.KEYBOARD_VISIBILITY, function (event:WebViewEvents):void
{
    trace("is Keyboard open? " + event.isOpen);
});
```

* Moved `showSoftKeyboard(true);` method from webview instances to the general `RichWebView.android` package because force showing the softkeyboard is only needed when you have a webview window open and you want the keyboard open on your AIR TextField object. If you want to open the softkeyboard on your AIR TextField object when a webview instance is open, doing it this:

```actionscript
var txtField:TextField = new TextField();
txtField.addEventListener(FocusEvent.FOCUS_IN, onTxtFieldFocusIn);
txtField.border = true;
txtField.type = TextFieldType.INPUT;
txtField.text = "AS3 TextField";
addChild(txtField);

function onTxtFieldFocusIn(e:FocusEvent):void
{
    // remove the request from the webview instance first
    if(_webviewInstance) _webviewInstance.requestFocus(Focus.UP);

    // if the keyboard is not already open, force it to open!
    if(!_isKeyboardOpen) RichWebView.android.showSoftKeyboard(true);
}
```

*Jan 4, 2019 - V8.0.0*
* Rebuilt the whole thing from scratch. We are now using the latest APIs for WebView on Android and WKWebView on iOS
* Unlike before, the Android and iOS AS3 sides are NOT similar to each other anymore. This is a good move for this ANE because the native APIs are working very differently and making them look similar on the AIR side was preventing us from being able to bring all native features to the AIR side. With the new API structure however, we are able to keep the ANE updated with the latest changes on the native sides whenever they happen.
* You cannot use the older version of our webview ANE with this new one in a same project.
