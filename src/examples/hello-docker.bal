import ballerina/log;
import ballerina/http;
import ballerina/docker;

@docker:Expose{}
listener http:Listener helloWorldEP = new(9090);

@docker:Config{
    name: "helloworld",
    tag: "v1.0"
}

@http:ServiceConfig {
    basePath: "/helloWorld"
}

service helloWorld on helloWorldEP {
    resource function sayHello(http:Caller caller, http:Request request) {
        http:Response response = new;
        response.setTextPayload("Hello World from Docker! \n");
        var responseRes = caller->respond(response);
        if(responseRes is error) {
            error err = responseRes;
            log:printError("Error sending response", err);
        }
    }
}