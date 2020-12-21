import ballerina/http;
import ballerina/io;
import ballerina/runtime;
import ballerina/websub;

public function main() {
    io:println("Starting up Ballerina WebSub Hub");

    websub:Hub websubhub;
    // https://ballerina.io/learn/api-docs/ballerina/websub/functions.html#startHub
    var result = websub:startHub(new http:Listener(9191), "/websub", "/hub",
        hubConfiguration = {
            remotePublish: {
                enabled: true
            }
        }
    );

    if(result is websub:Hub) {
        websubhub = result;
    } else if (result is websub:HubStartedUpError) {
        websubhub = result.startedUpHub;
    } else {
        io:println("Hub start error:" + <string>result.detail()?.message);
        return;
    }

    runtime:sleep(60000);
}

