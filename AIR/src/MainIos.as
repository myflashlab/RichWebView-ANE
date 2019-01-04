package
{
import com.myflashlab.air.extensions.richWebView.*;
import com.myflashlab.air.extensions.richWebView.ios.*;

import com.myflashlab.air.extensions.dependency.OverrideAir;
import com.myflashlab.air.extensions.nativePermissions.PermissionCheck;
import com.doitflash.consts.Direction;
import com.doitflash.consts.Orientation;
import com.doitflash.mobileProject.commonCpuSrc.DeviceInfo;
import com.doitflash.starling.utils.list.List;
import com.doitflash.text.modules.MySprite;
import com.doitflash.tools.sizeControl.FileSizeConvertor;
import com.doitflash.tools.DynamicFunc;
import com.luaye.console.C;

import flash.desktop.NativeApplication;
import flash.desktop.SystemIdleMode;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.utils.setTimeout;

/**
 *
 * @author Hadi Tavakoli - 1/2/2019 6:00 PM
 */
public class MainIos extends Sprite
{
	private const BTN_WIDTH:Number = 150;
	private const BTN_HEIGHT:Number = 60;
	private const BTN_SPACE:Number = 2;
	private var _txt:TextField;
	private var _body:Sprite;
	private var _list:List;
	private var _numRows:int = 1;
	
	private var _webviewData:WebView;
	private var _webviewFile:WebView;
	
	[Embed(source="sound01.mp3")]
	private var MySound:Class;
	
	public function MainIos():void
	{
		Multitouch.inputMode = MultitouchInputMode.GESTURE;
		NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, handleActivate);
		NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, handleDeactivate);
		NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onInvoke);
		NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeys);
		
		stage.addEventListener(Event.RESIZE, onResize);
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		C.startOnStage(this, "`");
		C.commandLine = false;
		C.commandLineAllowed = false;
		C.x = 100;
		C.width = 500;
		C.height = 250;
		C.strongRef = true;
		C.visible = true;
		C.scaleX = C.scaleY = DeviceInfo.dpiScaleMultiplier;
		
		_txt = new TextField();
		_txt.autoSize = TextFieldAutoSize.LEFT;
		_txt.antiAliasType = AntiAliasType.ADVANCED;
		_txt.multiline = true;
		_txt.wordWrap = true;
		_txt.embedFonts = false;
		_txt.htmlText = "<font face='Arimo' color='#333333' size='20'><b>RichWebView V" + RichWebView.VERSION + " for adobe air</b></font>";
		_txt.scaleX = _txt.scaleY = DeviceInfo.dpiScaleMultiplier;
		this.addChild(_txt);
		
		_body = new Sprite();
		this.addChild(_body);
		
		_list = new List();
		_list.holder = _body;
		_list.itemsHolder = new Sprite();
		_list.orientation = Orientation.VERTICAL;
		_list.hDirection = Direction.LEFT_TO_RIGHT;
		_list.vDirection = Direction.TOP_TO_BOTTOM;
		_list.space = BTN_SPACE;
		
		C.log("iOS is crazy with understanding stageWidth and stageHeight, you already now that :)");
		C.log("So, we should wait a couple of seconds before initializing RichWebview to make sure the stage dimention is stable before passing it through the ANE.");
		setTimeout(checkPermissions, 2500);
	}
	
	private function onInvoke(e:InvokeEvent):void
	{
		NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvoke);
	}
	
	private function handleActivate(e:Event):void
	{
		NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
	}
	
	private function handleDeactivate(e:Event):void
	{
		NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
	}
	
	private function handleKeys(e:KeyboardEvent):void
	{
		if(e.keyCode == Keyboard.BACK)
		{
			e.preventDefault();
			
			NativeApplication.nativeApplication.exit();
		}
	}
	
	private function onResize(e:* = null):void
	{
		if(_txt)
		{
			_txt.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
			
			C.x = 0;
			C.y = _txt.y + _txt.height + 0;
			C.width = stage.stageWidth * (1 / DeviceInfo.dpiScaleMultiplier);
			C.height = 300 * (1 / DeviceInfo.dpiScaleMultiplier);
		}
		
		if(_list)
		{
			_numRows = Math.floor(stage.stageWidth / (BTN_WIDTH * DeviceInfo.dpiScaleMultiplier + BTN_SPACE));
			_list.row = _numRows;
			_list.itemArrange();
		}
		
		if(_body)
		{
			_body.y = stage.stageHeight - _body.height;
		}
	}
	
	private function checkPermissions():void
	{
		// make sure you have access to the Location service if you are using location in your html
		PermissionCheck.init();
		
		var permissionState:int = PermissionCheck.check(PermissionCheck.SOURCE_LOCATION_WHEN_IN_USE);
		
		if(permissionState == PermissionCheck.PERMISSION_UNKNOWN || permissionState == PermissionCheck.PERMISSION_DENIED)
		{
			PermissionCheck.request(PermissionCheck.SOURCE_LOCATION_WHEN_IN_USE, onRequestResult);
		} else
		{
			init();
		}
		
		function onRequestResult($obj:Object):void
		{
			C.log("permission for " + $obj.source + ": " + prettify($obj.state));
			if($obj.state != PermissionCheck.PERMISSION_GRANTED)
			{
				C.log("You did not allow the app the required permissions!");
			} else
			{
				init();
			}
		}
	}
	
	private function init():void
	{
		// Remove OverrideAir debugger in production builds
		OverrideAir.enableDebugger(function ($ane:String, $class:String, $msg:String):void {
			trace($ane + " (" + $class + ") " + $msg);
		});
		
		// running on iOS or Android?
		if(OverrideAir.os == OverrideAir.ANDROID) trace("You are running on an Android device");
		else if(OverrideAir.os == OverrideAir.IOS) trace("You are running on an iOS device");
		else trace("you are not running on a real device!");
		
		// To make sure local files run correctly, you must copy them to File.applicationStorageDirectory
		var src:File = File.applicationDirectory.resolvePath("demoHtml");
		var dis:File = File.applicationStorageDirectory.resolvePath("demoHtml");
		if(dis.exists) dis.deleteDirectory(true);
		if(!dis.exists) src.copyTo(dis, true);
		
		RichWebView.init(stage);
		
		// ---------------------------------------------------------------------------------------------------------------------
		
		var btn1:MySprite = createBtn("open HTML Data", 0xDFE4FF);
		btn1.addEventListener(MouseEvent.CLICK, openHtmlData);
		_list.add(btn1);
		
		function openHtmlData(e:MouseEvent):void
		{
			if(_webviewData)
			{
				C.log("_webviewData is already open");
				return;
			}
			
			// create a new WebView instance
			_webviewData = RichWebView.ios.getInstance(0, 0, stage.stageWidth, stage.stageHeight * 0.5);
			
			// set ios configuration BEFORE [addView] method. Nothing will happen if you set them or modify them after [addView] is called
			_webviewData.settings.setDataStore(WebsiteDataStore.DEFAULT);
			_webviewData.settings.preferences.javaScriptEnabled = true;
			_webviewData.settings.addJavascriptInterface();
			_webviewData.settings.mediaTypesRequiringUserActionForPlayback = AudiovisualMediaTypes.ALL;
			_webviewData.settings.dataDetectorTypes = DataDetectorType.ALL;
			_webviewData.settings.allowsAirPlayForMediaPlayback = true;
			_webviewData.settings.allowsInlineMediaPlayback = true;
			_webviewData.settings.allowsPictureInPictureMediaPlayback = true;
			
			// Add the Native window on top of your AIR app (NOTICE: ALL Native windows will always stay on TOP of AIR content. This is a general rule with any ANE)
			_webviewData.addView(onWebViewDateAddedToStage);
		}
		
		function onWebViewDateAddedToStage():void
		{
			// properties
			_webviewData.setBackgroundColor("#fff7fd"); // color format is: AARRGGBB or RRGGBB
			
			// Scroller properties
			_webviewData.scrollView.keyboardDismissMode(ScrollViewKeyboardDismissMode.INTERACTIVE);
			
			var dataSettings:HtmlDataSettings = new HtmlDataSettings();
			dataSettings.baseUrl = null;
			dataSettings.encoding = "UTF-8";
			dataSettings.mimeType = "text/html";
			dataSettings.data = "<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\"><title>RichWebView ANE</title></head><body><p>This is a String which is shown on the RichWebView ANE as an HTML content.<br><br>Enjoy Building AIR apps<br><a href=\"http://www.myflashlabs.com/\">myflashlabs Team</a></p></body></html>";
			
			// load content
			_webviewData.loadData(dataSettings);
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn2:MySprite = createBtn("close HTML Data", 0xDFE4FF);
		btn2.addEventListener(MouseEvent.CLICK, closeHtmlData);
		_list.add(btn2);
		
		function closeHtmlData(e:MouseEvent):void
		{
			if(!_webviewData)
			{
				C.log("_webviewData is not open!");
				return;
			}
			
			_webviewData.close();
			_webviewData = null;
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn3:MySprite = createBtn("open local file", 0xffdffa);
		btn3.addEventListener(MouseEvent.CLICK, openLocal);
		_list.add(btn3);
		
		function openLocal(e:MouseEvent):void
		{
			if(_webviewFile)
			{
				C.log("_webviewFile is already open");
				return;
			}
			
			// shared settings between all webview instances:
			RichWebView.ios.cookieManager.cookieAcceptPolicy = NSHTTPCookieAcceptPolicy.ALWAYS;
			
			// create a new WebView instance
			_webviewFile = RichWebView.ios.getInstance(0, stage.stageHeight * 0.5, stage.stageWidth, stage.stageHeight * 0.5);
			
			// set ios configuration BEFORE [addView] method. Nothing will happen if you set them or modify them after [addView] is called
			_webviewFile.settings.setDataStore(WebsiteDataStore.DEFAULT);
			_webviewFile.settings.preferences.javaScriptEnabled = true;
			_webviewFile.settings.addJavascriptInterface();
			_webviewFile.settings.mediaTypesRequiringUserActionForPlayback = AudiovisualMediaTypes.NONE;
			_webviewFile.settings.dataDetectorTypes = DataDetectorType.ALL;
			_webviewFile.settings.allowsAirPlayForMediaPlayback = true;
			_webviewFile.settings.allowsInlineMediaPlayback = true;
			_webviewFile.settings.allowsPictureInPictureMediaPlayback = true;
			
			// add listeners
			_webviewFile.addEventListener(WebViewEvents.PAGE_STARTING, onWebviewFile_PageStarting);
			_webviewFile.addEventListener(WebViewEvents.PAGE_STARTED, onWebviewFile_PageStarted);
			_webviewFile.addEventListener(WebViewEvents.PAGE_FINISHED, onWebviewFile_PageFinished);
			_webviewFile.addEventListener(WebViewEvents.PAGE_PROGRESS, onWebviewFile_PageProgress);
			_webviewFile.addEventListener(WebViewEvents.RECEIVED_MESSAGE_FROM_JS, onWebviewFile_ReceivedMessage);
			_webviewFile.addEventListener(WebViewEvents.SCREENSHOT, onWebviewFile_Screenshot);
			_webviewFile.addEventListener(WebViewEvents.TOUCH, onWebviewFile_Touch);
			
			// Add the Native window on top of your AIR app (NOTICE: ALL Native windows will always stay on TOP of AIR content. This is a general rule with any ANE)
			_webviewFile.addView(onWebViewAddedToStage);
		}
		
		function onWebViewAddedToStage():void
		{
			// properties
			_webviewFile.setBackgroundColor("#f8f7ff"); // color format is: AARRGGBB or RRGGBB
			
			// Scroller properties
			_webviewFile.scrollView.keyboardDismissMode(ScrollViewKeyboardDismissMode.INTERACTIVE);
			
			// load content
			_webviewFile.loadFile(File.applicationStorageDirectory.resolvePath("demoHtml/index.html"), File.applicationStorageDirectory);
			//_webviewFile.loadUrl("https://www.google.com/");
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn4:MySprite = createBtn("close local file", 0xffdffa);
		btn4.addEventListener(MouseEvent.CLICK, closeLocalFile);
		_list.add(btn4);
		
		function closeLocalFile(e:MouseEvent):void
		{
			if(!_webviewFile)
			{
				C.log("_webviewFile is not open!");
				return;
			}
			
			_webviewFile.close();
			_webviewFile = null;
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		var btn5:MySprite = createBtn("open Embedded Browser", 0xedffdf);
		btn5.addEventListener(MouseEvent.CLICK, openEmbeddedBrowser);
		_list.add(btn5);
		
		function openEmbeddedBrowser(e:MouseEvent):void
		{
			var settings:EmbeddedBrowserSettings = new EmbeddedBrowserSettings();
			settings.barColor = "#CCCCCC";
			settings.controlColor = "#AAAAAA";
			settings.entersReaderIfAvailable = true;
			
			// Add listeners for the embedded browser
			if(!RichWebView.ios.embeddedBrowser.hasEventListener(WebViewEvents.EMBEDDED_BROWSER_ACTION))
			{
				RichWebView.ios.embeddedBrowser.addEventListener(WebViewEvents.EMBEDDED_BROWSER_ACTION, onEmbeddedBrowserAction);
				RichWebView.ios.embeddedBrowser.addEventListener(WebViewEvents.EMBEDDED_BROWSER_NAVIGATION_EVENT, onEmbeddedBrowserNavigationEvent);
			}
			
			RichWebView.ios.embeddedBrowser.open("https://www.google.com/", settings);
		}
		
		// ---------------------------------------------------------------------------------------------------------
		
		
		onResize();
	}
	
	// ------------------------------------------------------------------------------------------------------------
	
	private function onWebviewFile_PageStarting(e:WebViewEvents):void
	{
		C.log("onWebviewFile_PageStarting url = " + e.url);
		trace("onWebviewFile_PageStarting url = " + e.url);
		
		if(e.url.indexOf("mailto:") == 0)
		{
			// prevent webview from loading the url itself
			e.decision(false);
			
			_webviewFile.callJS("diplayAlert('You have decided to let Air handle this type of links! > mailto:*****')");
		} else if(e.url.indexOf("tel:") == 0)
		{
			// prevent webview from loading the url itself
			e.decision(false);
			
			_webviewFile.callJS("diplayAlert('You have decided to let Air handle this type of links! > tel:*****')");
		} else
		{
			// Let webview load the url normally
			e.decision(true);
		}
	}
	
	private function onWebviewFile_PageStarted(e:WebViewEvents):void
	{
		C.log("onWebviewFile_PageStarted = " + e.url);
		trace("onWebviewFile_PageStarted = " + e.url);
	}
	
	private function onWebviewFile_PageFinished(e:WebViewEvents):void
	{
		C.log("onWebviewFile_PageFinished = " + e.url);
		trace("onWebviewFile_PageFinished = " + e.url);
	}
	
	private function onWebviewFile_PageProgress(e:WebViewEvents):void
	{
		C.log("onWebviewFile_PageProgress progress: ", e.progress);
		trace("onWebviewFile_PageProgress progress: ", e.progress);
	}
	
	private function onWebviewFile_ReceivedMessage(e:WebViewEvents):void
	{
		C.log("onWebviewFile_ReceivedMessage: ", e.msg);
		trace("onWebviewFile_ReceivedMessage: ", e.msg);
		
		DynamicFunc.run(this, e.msg);
	}
	
	private function onWebviewFile_Screenshot(e:WebViewEvents):void
	{
		C.log("onWebviewFile_Screenshot dimension: " + e.width + "x" + e.height);
		C.log("onWebviewFile_Screenshot file: (" + FileSizeConvertor.size(e.file.size) + ") " + e.file.nativePath);
		
		trace("onWebviewFile_Screenshot dimension: " + e.width + "x" + e.height);
		trace("onWebviewFile_Screenshot file: (" + FileSizeConvertor.size(e.file.size) + ") " + e.file.nativePath);
	}
	
	private function onWebviewFile_Touch(e:WebViewEvents):void
	{
		trace("onWebviewFile_Touch > " + "x = " + e.x + " y = " + e.y);
	}
	
	// -------------------------------------------- methods to be called from JS
	public function closeWebView():void
	{
		_webviewFile.close();
		_webviewFile = null;
	}
	
	public function toOpenJSAlert():void
	{
		_webviewFile.callJS("diplayAlert('This is a message from Flash!')");
	}
	
	public function toPlaySound():void
	{
		var voice:Sound = (new MySound) as Sound;
		voice.play();
	}
	
	public function changePosition($marginLeft:Number, $marginTop:Number, $marginRight:Number, $marginBottom:Number):void
	{
		_webviewFile.setViewPort(new Rectangle($marginLeft, $marginTop, (stage.stageWidth - $marginRight), (stage.stageHeight - $marginBottom)));
	}
	
	public function toTakeScreenshot():void
	{
		_webviewFile.takeScreenshot();
	}
	
	public function parseJson($str:String):void
	{
		trace(decodeURIComponent($str));
	}
	
	private function onEmbeddedBrowserNavigationEvent(e:WebViewEvents):void
	{
		switch(e.state)
		{
			case EmbeddedBrowser.NAVIGATION_FINISHED:
				
				trace("EmbeddedBrowser NAVIGATION_FINISHED");
				
				break;
			case EmbeddedBrowser.CLOSED:
				
				trace("EmbeddedBrowser CLOSED");
				
				break;
			default:
		}
	}
	
	private function onEmbeddedBrowserAction(e:WebViewEvents):void
	{
		trace("onEmbeddedBrowserAction (" + e.item + ") URL: " + e.url);
		C.log("onEmbeddedBrowserAction (" + e.item + ") URL: " + e.url);
	}
	
	
	private function prettify($state:int):String
	{
		var str:String;
		
		switch($state)
		{
			case PermissionCheck.PERMISSION_UNKNOWN:
				
				str = "UNKNOWN";
				
				break;
			case PermissionCheck.PERMISSION_DENIED:
				
				str = "DENIED";
				
				break;
			case PermissionCheck.PERMISSION_GRANTED:
				
				str = "GRANTED";
				
				break;
			case PermissionCheck.PERMISSION_OS_ERR:
				
				str = "Not available on this OS!";
				
				break;
		}
		
		return str;
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	private function createBtn($str:String, $color:uint = 0xDFE4FF):MySprite
	{
		var sp:MySprite = new MySprite();
		sp.addEventListener(MouseEvent.MOUSE_OVER, onOver);
		sp.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		sp.addEventListener(MouseEvent.CLICK, onOut);
		sp.bgAlpha = 1;
		sp.bgColor = $color;
		sp.drawBg();
		sp.width = BTN_WIDTH * DeviceInfo.dpiScaleMultiplier;
		sp.height = BTN_HEIGHT * DeviceInfo.dpiScaleMultiplier;
		
		function onOver(e:MouseEvent):void
		{
			sp.bgAlpha = 1;
			sp.bgColor = 0xFFDB48;
			sp.drawBg();
		}
		
		function onOut(e:MouseEvent):void
		{
			sp.bgAlpha = 1;
			sp.bgColor = $color;
			sp.drawBg();
		}
		
		var format:TextFormat = new TextFormat("Arimo", 16, 0x666666, null, null, null, null, null, TextFormatAlign.CENTER);
		
		var txt:TextField = new TextField();
		txt.autoSize = TextFieldAutoSize.LEFT;
		txt.antiAliasType = AntiAliasType.ADVANCED;
		txt.mouseEnabled = false;
		txt.multiline = true;
		txt.wordWrap = true;
		txt.scaleX = txt.scaleY = DeviceInfo.dpiScaleMultiplier;
		txt.width = sp.width * (1 / DeviceInfo.dpiScaleMultiplier);
		txt.defaultTextFormat = format;
		txt.text = $str;
		
		txt.y = sp.height - txt.height >> 1;
		sp.addChild(txt);
		
		return sp;
	}
}

}