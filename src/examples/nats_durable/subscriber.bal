import ballerina/lang.'string as strings;
import ballerina/log;
import ballerina/nats;

nats:Connection conn = new;

listener nats:StreamingListener lis = new (conn, clientId = "c0");

@nats:StreamingSubscriptionConfig {
    subject: "demo",
    durableName: "sample-name"
}
service demoService on lis {
    resource function onMessage(nats:StreamingMessage message) {

       string|error messageData = strings:fromBytes(message.getData());
       if (messageData is string) {
            log:printInfo("Message Received: " + messageData);
       } else {
            log:printError("Error occurred while obtaining message data");
       }
    }

    resource function onError(nats:StreamingMessage message, nats:Error errorVal) {
        error e = errorVal;
        log:printError("Error occurred: ", e);
    }
}