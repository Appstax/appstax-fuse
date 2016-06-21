
var ws = require("WebSocketWrapper");

function WebSocket(url) {
	var id = ws.newWebSocket(url, handleEvent);
	var listeners = [];
	var readyState = 0;

	return Object.defineProperties({}, {
		onopen:    createEventProperty("open"),
		onclose:   createEventProperty("close"),
		onerror:   createEventProperty("error"),
		onmessage: createEventProperty("message"),
		readyState: { get: function() { return readyState; } },
		send: { value: send },
		addEventListener: { value: addEventListener },
	});

	function handleEvent(type, data) {
		switch(type) {
			case "open":  readyState = 1; break;
			case "close": readyState = 3; break;
		}

		listeners
			.filter(function(listener) {
				return listener.type == type;
			})
			.forEach(function(listener) {
				listener.handler({
					type: type,
					data: data
				});
			});
	}

	function send(data) {
		ws.sendString(id, data.toString());
	}

	function addEventListener(type, handler) {
		listeners.push({
			type: type,
			handler: handler
		});
	}

	function removeEventListener(type, handler) {
		var removeIndex = -1;
		for(var i = 0; i < listeners.length; i++) {
			var listener = listeners[i];
			if(listener.type == type && listener.handler == handler) {
				removeIndex = i;
				break;
			}
		}
		if(removeIndex >= 0) {
			listeners.splice(removeIndex, 1);
		}
	}

	function createEventProperty(type) {
		var listener;
		return {
			set: function(x) { 
				removeEventListener(type, listener);
				listener = x;
				addEventListener(type, listener);
			},
			get: function() {
				return listener;
			}
		}
	}
}

if(!window.WebSocket) {
	window.WebSocket = WebSocket;
}

module.exports = WebSocket;
