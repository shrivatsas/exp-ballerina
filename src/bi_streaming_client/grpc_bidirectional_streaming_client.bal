import ballerina/grpc;
import ballerina/io;
import ballerina/runtime;

int total = 0;
public function main() {

    ChatClient chatEp = new ("http://localhost:9090");

    grpc:StreamingClient ep;

    var res = chatEp->chat(ChatMessageListener);

    if (res is grpc:Error) {
        io:println("Error from Connector: " + res.reason() + " - "
                                  + <string>res.detail()["message"]);
        return;
    } else {
        io:println("Initialized connection sucessfully.");
        ep = res;
    }

    ChatMessage mes = {name: "Sam", message: "Hi "};
    grpc:Error? connErr = ep->send(mes);

    if (connErr is grpc:Error) {
        io:println("Error from Connector: " + connErr.reason() + " - "
                               + <string>connErr.detail()["message"]);
    }
    runtime:sleep(6000);

    grpc:Error? result = ep->complete();
    if (result is grpc:Error) {
        io:println("Error in sending complete message", result);
    }
}

service ChatMessageListener = service {

    resource function onMessage(string message) {
        io:println("Response received from server: " + message);
    }

    resource function onError(error err) {
        io:println("Error reported from server: " + err.reason() + " - "
                                  + <string>err.detail()["message"]);
    }

    resource function onComplete() {
        io:println("Server Complete Sending Responses.");
    }
};