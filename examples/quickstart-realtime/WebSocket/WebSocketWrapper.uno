using Uno;
using Uno.Collections;
using Uno.UX;

using Fuse;
using Fuse.Scripting;
using Fuse.Reactive;

using Uno.Compiler.ExportTargetInterop;

public delegate void WebSocketEventHandler(string type, string data);

[UXGlobalModule]
public class WebSocketWrapper : NativeModule
{
	private static readonly WebSocketWrapper _instance;
	private static Dictionary<string, WebSocketImpl> _webSockets = new Dictionary<string, WebSocketImpl>();
	private static int _webSocketIdCount = 0;

	public WebSocketWrapper()
	{
		if(_instance != null) return;

		_instance = this;
		Resource.SetGlobalKey(_instance, "WebSocketWrapper");

		AddMember(new NativeFunction("newWebSocket", (NativeCallback)NewWebSocket));
		AddMember(new NativeFunction("sendString", (NativeCallback)SendString));

		this.Reset += this.OnReset;
	}

	public void OnReset(object o, EventArgs e) {
		debug_log("WebSocketWrapper.OnReset");
		foreach(WebSocketImpl ws in _webSockets.Values) {
			ws.Destroy();
		}
		_webSockets.Clear();
	}

	public object NewWebSocket(Context c, object[] args)
	{
		var url = args[0] as string;
		var eventHandler = args[1] as Function;
		var id = "ws-" + _webSocketIdCount++;
		
		var webSocket = new WebSocketImpl(url, eventHandler);
		_webSockets[id] = webSocket;
		
		return id;
	}

	public object SendString(Context c, object[] args)
	{
		var id = args[0] as string;
		var data = args[1] as string;

		var webSocket = _webSockets[id];
		webSocket.SendString(data);

		return null;
	}
}

[Require("Xcode.FrameworkDirectory", "@('ios':Path)")]
[Require("Xcode.EmbeddedFramework", "@('ios/Jetfire.framework':Path)")]
[Require("Xcode.Framework", "Security.framework")]
[Require("Xcode.Framework", "CFNetwork.framework")]
[ForeignInclude(Language.ObjC, "WebSocket/ios/WebSocketObjc.h")]
public extern(iOS) class WebSocketImpl
{
	private ObjC.Object _webSocket;
	private Function _eventHandler;

	public WebSocketImpl(string url, Function eventHandler)
	{
		_eventHandler = eventHandler;
		_webSocket = Create(url);
	}

	[Foreign(Language.ObjC)]
	public ObjC.Object Create(string url)
	@{
		return [[WebSocketObjc alloc] 
						initWithUrl:url 
						eventHandler:^(NSString* type, NSString *data) {
							@{WebSocketImpl:Of(_this).HandleEvent(string, string):Call(type, data)};
						}];
	@}

	[Foreign(Language.ObjC)]
	public void SendString(string data)
	@{
		WebSocketObjc *webSocket = @{WebSocketImpl:Of(_this)._webSocket:Get()};
		[webSocket sendString:data];
	@}

	private void HandleEvent(string type, string data) {
		if(_eventHandler != null) {
			_eventHandler.Call(new object[] { type, data });
		}
	}

	public void Destroy()
	{
		_webSocket = null;
		_eventHandler = null;
	}
}

[ForeignInclude(Language.Java, "com.foreign.WebSocketJava")]
public extern(Android) class WebSocketImpl
{
	private Java.Object _webSocket;
	private Function _eventHandler;

	public WebSocketImpl(string url, Function eventHandler)
	{
		_eventHandler = eventHandler;
		_webSocket = Create(url, this.HandleEvent);
	}

	[Foreign(Language.Java)]
	public Java.Object Create(string url, Action<string, string> eventHandler)
	@{
		return new WebSocketJava(url, eventHandler);
	@}

	[Foreign(Language.Java)]
	public void SendString(string data)
	@{
		WebSocketJava webSocket = (WebSocketJava) @{WebSocketImpl:Of(_this)._webSocket:Get()};
		webSocket.sendString(data);
	@}

	private void HandleEvent(string type, string data) {
		if(_eventHandler != null) {
			_eventHandler.Call(new object[] { type, data });
		}
	}

	public void Destroy()
	{
		_webSocket = null;
		_eventHandler = null;
	}
}

public extern(!iOS && !Android) class WebSocketImpl
{
	public WebSocketImpl(string url, Function eventHandler)
	{
		debug_log("WebSockets not supported");
	}

	public void SendString(string data)
	{
		debug_log("WebSockets not supported");
	}

	public void Destroy() { }
}
