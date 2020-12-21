import ballerina/http;
import ballerina/log;
import ballerina/runtime;

listener http:Listener backendEP = new (8080);

http:FailoverClient foBackendEP = new ({
    timeoutInMillis: 5000,
    failoverCodes: [501, 502, 503],
    intervalInMillis: 5000,

    targets: [
        {url: "http://nonexistentEP/mock1"},
        {url: "http://localhost:8080/mock"},
        {url: "http://localhost:8080/echo"}
    ]
});

@http:ServiceConfig{
    basePath: "/fo"
}
service failoverDemoService on new http:Listener(9090) {

    @http:ResourceConfig{
        methods: ["GET", "POST"],
        path: "/"
    }
    resource function incokeEndpoint(http:Caller caller, http:Request request) {
        var backendResponse = foBackendEP->get("/", <@untainted>request);
        if(backendResponse is http:Response) {
            var responseToCaller = caller->respond(backendResponse);
            if (responseToCaller is error) {
                log:printError("Error sending response", responseToCaller);
            }
        } else {
            http:Response response = new;
            response.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
            response.setPayload(<string>backendResponse.detail()?.message);
            var responseToCaller = caller->respond(response);
            if (responseToCaller is error) {
                log:printError("Error sending response", responseToCaller);
            }
        }
    }
}


@http:ServiceConfig{
    basePath: "/echo"
}
service echo on backendEP {
    @http:ResourceConfig{
        methods: ["POST", "PUT", "GET"],
        path: "/"
    }
    resource function echoResource(http:Caller caller, http:Request request) {
        runtime:sleep(30000);
        var result = caller->respond("echo Resource is invoked");
        if(result is error) {
            log:printError("Error sending response from mock service", result);
        }
    }
}

@http:ServiceConfig{
    basePath: "mock"
}
service mock on backendEP {
    @http:ResourceConfig{
        methods: ["POST", "PUT", "GET"],
        path: "/"
    }
    resource function mockResource(http:Caller caller, http:Request request) {
        var result = caller->respond("Mock Resource is Invoked.");
        if(result is error) {
            log:printError("Error sending response from mock service", result);
        }
    }
}

// curl -v http://localhost:9090/fo