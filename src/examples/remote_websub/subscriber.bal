import ballerina/http;
import ballerina/log;
import ballerina/websub;

listener websub:Listener websubEP = new (8181);

@websub:SubscriberServiceConfig {
    path: "/websub",
    subscribeOnStartUp: true,
    target: ["http://localhost:9191/websub/hub", "http://websubpubtopic.com"],
    leaseSeconds: 36000,
    secret: "Kslk30SNF2AChs2"
}
service websubSubscriber on websubEP {

    resource function onIntentVerification(websub:Caller caller,
                                   websub:IntentVerificationRequest request) {
        http:Response response = request.
            buildSubscriptionVerificationResponse("http://websubpubtopic.com");

        if (response.statusCode == 202) {
            log:printInfo("Intent verified for subscription request");
        } else {
            log:printWarn("Intent verification denied for subscription request");
        }
        var result = caller->respond(<@untainted>response);

        if (result is error) {
            log:printError("Error responding to intent verification request", result);
        }
    }

    resource function onNotification(websub:Notification notification) {
        var payload = notification.getTextPayload();
        if (payload is string) {
            log:printInfo("WebSub Notification Received: " + payload);
        } else {
            log:printError("Error retrieving payload as string", payload);
        }
    }
}