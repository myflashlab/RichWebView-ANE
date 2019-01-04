# RichWebView II ANE (Android+iOS)
RichWebView II ANE gives you access to the native webview APIs in Android and iOS. Everything that a Native programmer can do with the native webview, you can also do in your AdobeAIR projects. 

**Main Features:**
* Use multiple Webview instances
* Call JS funcs from AIR and vice versa
* Control the Scroll position and style
* Change the view port size and position at runtime
* Play video files inside the webview including embedded iFrame videos
* Take full screenshots from your webview object
* Get GPS location information in to your JS
* Enable file picker dialog on your HTML input fields
* Control background color with AARRGGBB format. (supports transparent)
* TouchEvent to know when the WebView is touched
* Optionally prevent URL loads and let AIR handle them
* Load HTML Strings directly into the WebView instance
* Support Android custom-tabs
* Supports iOS SafariViewController
* Supports iOS WKWebView API

find the latest **asdoc** for this ANE [here](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/richWebView/package-detail.html). [Android package](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/richWebView/android/package-detail.html), [iOS package](http://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/richWebView/ios/package-detail.html)

# Air Usage
For detailed AS3 code usage, see the [Android](https://github.com/myflashlab/RichWebView-ANE/blob/master/AIR/src/MainAndroid.as) and [iOS](https://github.com/myflashlab/RichWebView-ANE/blob/master/AIR/src/MainIos.as) demo projects. below is a basic example showing how to open html string in webview.

**Android Side**
```actionscript
import com.myflashlab.air.extensions.richWebView.*;
import com.myflashlab.air.extensions.richWebView.android.*;
import com.myflashlab.air.extensions.dependency.OverrideAir;

// initialize the ANE when the flash.display.Stage is available
RichWebView.init(stage);

// create a new WebView instance
var webview = RichWebView.android.getInstance(0, 0, stage.stageWidth, stage.stageHeight);
			
// Add the Native window on top of your AIR app (NOTICE: ALL Native windows will always stay on TOP of AIR content. This is a general rule with any ANE)
webview.addView();
			
// properties
webview.setBackgroundColor("#fff7fd"); // color format is: AARRGGBB or RRGGBB
			
var dataSettings:HtmlDataSettings = new HtmlDataSettings();
dataSettings.baseUrl = null;
dataSettings.encoding = "UTF-8";
dataSettings.mimeType = "text/html";
dataSettings.data = "<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\"><title>RichWebView ANE</title></head><body><p>This is a String which is shown on the RichWebView ANE as an HTML content.<br><br>Enjoy Building AIR apps<br><a href=\"https://www.myflashlabs.com/\">myflashlabs Team</a></p></body></html>";
			
// load content
webview.loadData(dataSettings);
```

**iOS Side**
```actionscript
import com.myflashlab.air.extensions.richWebView.*;
import com.myflashlab.air.extensions.richWebView.ios.*;
import com.myflashlab.air.extensions.dependency.OverrideAir;

// initialize the ANE when the flash.display.Stage is available
RichWebView.init(stage);

// create a new WebView instance
webview = RichWebView.ios.getInstance(0, 0, stage.stageWidth, stage.stageHeight);
			
// set ios configuration BEFORE [addView] method. Nothing will happen if you set them or modify them after [addView] is called
webview.settings.allowsAirPlayForMediaPlayback = true;
			
// Add the Native window on top of your AIR app (NOTICE: ALL Native windows will always stay on TOP of AIR content. This is a general rule with any ANE)
webview.addView(onWebViewDateAddedToStage);

function onWebViewDateAddedToStage():void
{
	// properties
	webview.setBackgroundColor("#fff7fd"); // color format is: AARRGGBB or RRGGBB
			
	// Scroller properties
	webview.scrollView.keyboardDismissMode(ScrollViewKeyboardDismissMode.INTERACTIVE);
			
	var dataSettings:HtmlDataSettings = new HtmlDataSettings();
	dataSettings.baseUrl = null;
	dataSettings.encoding = "UTF-8";
	dataSettings.mimeType = "text/html";
	dataSettings.data = "<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\"><title>RichWebView ANE</title></head><body><p>This is a String which is shown on the RichWebView ANE as an HTML content.<br><br>Enjoy Building AIR apps<br><a href=\"https://www.myflashlabs.com/\">myflashlabs Team</a></p></body></html>";
			
	// load content
	webview.loadData(dataSettings);
}
```

# AIR .xml manifest
```xml
<!--
FOR ANDROID:
-->
<manifest android:installLocation="auto">

    <uses-permission android:name="android.permission.INTERNET"/>
	<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-sdk android:targetSdkVersion="26"/>

    <application android:allowBackup="true">
                    
        <!-- required for html file select buttons -->
        <activity android:name="com.myflashlabs.richwebview.Pick" android:theme="@style/Theme.Transparent" />

        <!-- required for customtabs support on Android -->
        <receiver android:name="com.myflashlabs.richwebview.ChromeTabActionBroadcastReceiver" />

    </application>

</manifest>






<!--
FOR iOS:
-->
<key>MinimumOSVersion</key>
<string>9.0</string>

<!-- Not recommanded but add this in case you want to open nonsecure http urls -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key><true/>
</dict>

<!--required for webview GPS access-->
<key>NSLocationWhenInUseUsageDescription</key>
<string>I need location when in use</string>





<!--
Embedding the ANE:
-->
<extensions>

        <extensionID>com.myflashlab.air.extensions.richWebView</extensionID>
        <extensionID>com.myflashlab.air.extensions.permissionCheck</extensionID>

        <extensionID>com.myflashlab.air.extensions.dependency.overrideAir</extensionID>
        <extensionID>com.myflashlab.air.extensions.dependency.androidSupport.core</extensionID>
        <extensionID>com.myflashlab.air.extensions.dependency.androidSupport.v4</extensionID>
        <extensionID>com.myflashlab.air.extensions.dependency.androidSupport.customtabs</extensionID>
        
    </extensions>
```

# Setup Javascript:
Before being able to communicate with JavaScript, you must first make sure JS is enabled for your webview instance and also the AirBridge JS code is injected into your html content.

**IMPORTANT:** AIR/JS communication will be possible only AFTER your content is fully loaded. When ```WebViewEvents.PAGE_FINISHED``` happens.

**On Android:**
```actionscript
// first initialize a new instance of webview
var _webview:WebView = RichWebView.android.getInstance(0, 0, 500, 500);

// add listeners and other settings... but make sure you have added:
_webview.settings.javaScriptEnabled = true;

// then you should add the webview to the stage:
_webview.addView();

// after adding it to the stage, you must inject the AirBridge script:
_webview.addJavascriptInterface();
```

**On iOS:**
```actionscript
// first initialize a new instance of webview
var _webview:WebView = RichWebView.ios.getInstance(0, 0, 500, 500);

// add listeners and other settings... but make sure you have added:
_webview.settings.addJavascriptInterface(); // will inject AirBridge

// then you should add the webview to the stage:
_webview.addView(onWebViewAddedToStage);

function onWebViewAddedToStage():void
{

}
```

So, when yoursetup is ready, You are able to easily call JS functions from AIR like this:
```actionscript
_webview.callJS("diplayAlert('This is a message from AdobeAir!')");
```

and on JS side, you can send String messages to AIR like this:
```javascript
AirBridge.evoke("toVibrate");
```

# Requirements
* Android SDK 19+
* iOS 9.0+
* AIR 31+

# Permissions
Below are the list of Permissions this ANE might require. Check out the demo project available at this repository to see how we have used the [PermissionCheck ANE](http://www.myflashlabs.com/product/native-access-permission-check-settings-menu-air-native-extension/) to ask for the permissions.

Necessary | Optional
--------------------------- | ---------------------------
. | [SOURCE_LOCATION (Android)](https://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/nativePermissions/PermissionCheck.html#SOURCE_LOCATION)  
. | [SOURCE_STORAGE (Android)](https://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/nativePermissions/PermissionCheck.html#SOURCE_STORAGE)  
. | [SOURCE_LOCATION_WHEN_IN_USE (iOS)](https://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/nativePermissions/PermissionCheck.html#SOURCE_LOCATION_WHEN_IN_USE)  
. | [SOURCE_LOCATION_ALWAYS (iOS)](https://myflashlab.github.io/asdoc/com/myflashlab/air/extensions/nativePermissions/PermissionCheck.html#SOURCE_LOCATION_ALWAYS) 

# Commercial Version
https://www.myflashlabs.com/product/richwebview-2-ane-adobe-air-native-extension/

[![WebView ANE](https://www.myflashlabs.com/wp-content/uploads/2019/01/product_adobe-air-ane-extension-richwebview-2.jpg)](https://www.myflashlabs.com/product/richwebview-2-ane-adobe-air-native-extension/)

# Tutorials
[How to embed ANEs into **FlashBuilder**, **FlashCC** and **FlashDevelop**](https://www.youtube.com/watch?v=Oubsb_3F3ec&list=PL_mmSjScdnxnSDTMYb1iDX4LemhIJrt1O)  

# Premium Support #
[![Premium Support package](https://www.myflashlabs.com/wp-content/uploads/2016/06/professional-support.jpg)](https://www.myflashlabs.com/product/myflashlabs-support/)
If you are an [active MyFlashLabs club member](https://www.myflashlabs.com/product/myflashlabs-club-membership/), you will have access to our private and secure support ticket system for all our ANEs. Even if you are not a member, you can still receive premium help if you purchase the [premium support package](https://www.myflashlabs.com/product/myflashlabs-support/).