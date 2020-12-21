import ballerina/io;
import ballerina/websub;
import ballerina/runtime;

websub:PublisherClient websubHubClientEP =
                    new ("http://localhost:9191/websub/publish");

public function main() {
    var registrationResponse =
            websubHubClientEP->registerTopic("http://websubpubtopic.com");
    if (registrationResponse is error) {
        io:println("Error occurred registering topic: " +
                            <string>registrationResponse.detail()?.message);
    } else {
        io:println("Topic registration successful!");
    }

    runtime:sleep(5000);
    io:println("Publishing update to remote Hub");
    var publishResponse =
        websubHubClientEP->publishUpdate("http://websubpubtopic.com",
                                {"action": "publish", "mode": "remote-hub"});
    if (publishResponse is error) {
        io:println("Error notifying hub: " +
                                    <string>publishResponse.detail()?.message);
    } else {
        io:println("Update notification successful!");
    }

}