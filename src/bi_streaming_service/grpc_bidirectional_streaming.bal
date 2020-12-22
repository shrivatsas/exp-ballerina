import ballerina/grpc;
import ballerina/log;

map<grpc:Caller> consMap = {};

@grpc:ServiceConfig {
    name: "Chat",
    clientStreaming: true,
    serverStreaming: true
}
service Chat on new grpc:Listener(9090) {

    resource function onOpen(grpc:Caller caller) {
        log:printInfo(string `${caller.getId()} connected to chat`);
        consMap[caller.getId().toString()] = <@untainted>caller;
    }

    resource function onMessage(grpc:Caller caller, ChatMessage chatMsg) {
        grpc:Caller ep;
        string msg = string `${chatMsg.name}: ${chatMsg.message}`;
        log:printInfo("Server received message: " + msg);
        foreach var [callerId, connection] in consMap.entries() {
            ep = connection;
            grpc:Error? err = ep->send(msg);
            if (err is grpc:Error) {
                log:printError("Error from Connector: " + err.reason() + " - "
                            + <string>err.detail()["message"]);
            } else {
                log:printInfo("Server message to caller " + callerId
                                                      + " sent successfully.");
            }
        }
    }

    resource function onError(grpc:Caller caller, error err) {
        log:printError("Error from Connector: " + err.reason() + " - "
                + <string>err.detail()["message"]);
    }

    resource function onComplete(grpc:Caller caller) {
        grpc:Caller ep;
        string msg = string `${caller.getId()} left the chat`;
        log:printInfo(msg);
        var v = consMap.remove(caller.getId().toString());
        foreach var [callerId, connection] in consMap.entries() {
            ep = connection;
            grpc:Error? err = ep->send(msg);
            if (err is grpc:Error) {
                log:printError("Error from Connector: " + err.reason() + " - "
                        + <string>err.detail()["message"]);
            } else {
                log:printInfo("Server message to caller " + callerId
                                                      + " sent successfully.");
            }
        }
    }
}