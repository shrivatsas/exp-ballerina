import ballerina/http;
import ballerina/log;

final string NAME = "NAME";
final string AGE = "AGE";

@http:ServiceConfig{
    basePath: "/chat"
}

service chatAppUpgrder on new http:Listener(9090) {

    @http:ResourceConfig {
        webSocketUpgrade: {
            upgradePath: "/{name}",
            upgradeService: chatApp
        }
    }
    resource function upgrader(http:Caller caller, http:Request request, string name) {
        map<string[]> params = request.getQueryParams();
        if(!params.hasKey("age")) {
            var err = caller->cancelWebSocketUpgrade(400, "Age is required!");
            if(err is http:WebSocketError) {
                log:printError("Error cancelling handshake", err);
            }
        }

        map<string> headers = {};
        http:WebSocketCaller|http:WebSocketError wsEp = caller->acceptWebSocketUpgrade(headers);
        if(wsEp is http:WebSocketCaller) {
            wsEp.setAttribute(NAME, name);
            string? ageValue = request.getQueryParamValue(AGE);
            string age = ageValue is string? ageValue : "";
            wsEp.setAttribute(AGE, age);
            string hello = string `Hello {name}! Welcome to the Ballerina chat`;
            var err = wsEp->pushText(hello);
            if(err is http:WebSocketError) {
                log:printError("Error sending message", err);
            }
        } else {
            log:printError("Error during Web Socket upgrade", wsEp);
        }

    }
}

map<http:WebSocketCaller> connectionsMap = {};

function broadcast(string text) {
    foreach var conn in connectionsMap {
        var err = conn->pushText(text);
        if(err is http:WebSocketError) {
            log:printError("Error sending message", err);
        }
    }
}

function getAttribute(http:WebSocketCaller caller, string key) returns string {
    var val = caller.getAttribute(key);
    return val.toString();
} 

service chatApp = @http:WebSocketServiceConfig {} service {
    resource function onOpen(http:WebSocketCaller caller) {
        string msg = getAttribute(caller, NAME) + " with age " +
        getAttribute(caller, AGE) + " connected to Chat";
        broadcast(msg);
        connectionsMap[caller.getConnectionId()] = <@untainted>caller;
    }

    resource function onText(http:WebSocketCaller caller, string text) {
        string msg = getAttribute(caller, NAME) + ": " + text;
        log:printInfo(msg);
        broadcast(msg);
    }

    resource function onClose(http:WebSocketCaller caller, int statusCode, string reason) {
        _ = connectionsMap.remove(caller.getConnectionId());
        string msg = getAttribute(caller, NAME) + " left the chat";
        broadcast(msg);
    }
};

# First open http://localhost:9090/chat in a firefox tab, then
# In dev console
# var ws = new WebSocket("ws://localhost:9090/chat/bruce?age=30");
# ws.onmessage = function(frame) {console.log(frame.data)};
# ws.onclose = function(frame) {console.log(frame)};
# 
# Send messages.
# ws.send("hello world");
