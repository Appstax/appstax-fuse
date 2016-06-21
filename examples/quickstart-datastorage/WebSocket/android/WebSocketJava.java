package com.foreign;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import com.foreign.Uno.*;
import com.neovisionaries.ws.client.*;

public class WebSocketJava extends WebSocketAdapter {

    private WebSocket webSocket;
    private Action_String_String eventHandler;

    public WebSocketJava(String url, Action_String_String eventHandler) {
        this.eventHandler = eventHandler;
        connect(url);
    }

    private void connect(String url) {
        try {
            webSocket = new WebSocketFactory().createSocket(url);
            webSocket.addListener(this);
            webSocket.connectAsynchronously();
        } catch(IOException e) {}
    }

    public void onError(WebSocket websocket, WebSocketException cause) {
        eventHandler.run("error", cause.getMessage());
    }

    public void onConnectError(WebSocket websocket, WebSocketException cause) throws Exception {
        eventHandler.run("error", cause.getMessage());
        eventHandler.run("close", cause.getMessage());
    }

    public void onConnected(WebSocket websocket, Map<String, List<String>> headers) {
        eventHandler.run("open", null);
    }

    public void onDisconnected(WebSocket websocket, WebSocketFrame serverCloseFrame, WebSocketFrame clientCloseFrame, boolean closedByServer) {
        eventHandler.run("close", null);
    }

    public void sendString(String data) {
        webSocket.sendText(data);
    }

    public void onTextMessage(WebSocket websocket, String message) {
        eventHandler.run("message", message);
    }
}

