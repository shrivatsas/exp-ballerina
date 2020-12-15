import ballerina/http;
import ballerina/log;

@http:ServiceConfig{
    basePath: "/cbr"
}
service contentBasedRouting on new http:Listener(9090) {

    @http:ResourceConfig{
        methods: ["POST"],
        path: "/route"
    }
    resource function cbrResource(http:Caller caller, http:Request request) {
        http:Client locationEP = new ("http://www.mocky.io");
        var jsonMsg = request.getJsonPayload();

        if(jsonMsg is json) {
            json|error name = jsonMsg.name;
            http:Response|error clientResponse;
            if(name is json) {
                if(name.toString() == "bangalore") {
                    clientResponse =
                            locationEP->post("/v2/594e018c1100002811d6d39a", ());
                } else {
                    clientResponse =
                            locationEP->post("/v2/594e026c1100004011d6d39c", ());
                }

                if(clientResponse is http:Response) {
                    var result = caller->respond(clientResponse);
                    if(result is error) {
                        log:printError("Error sending response", result);
                    }
                } else {
                    http:Response res = new;
                    res.statusCode = 500;
                    res.setPayload(<string>clientResponse.detail()?.message);
                    var result = caller->respond(res);
                    if(result is error) {
                        log:printError("Error sending response", result);
                    }
                }
            } else {
                http:Response res = new;
                res.statusCode = 500;
                res.setPayload(<@untainted string>name.detail()?.message);
                var result = caller->respond(res);
                if(result is error) {
                    log:printError("Error sending response", result);
                }
            }
        } else {
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload(<@untainted string>jsonMsg.detail()?.message);
            var result = caller->respond(res);
            if(result is error) {
                log:printError("Error sending response", result);
            }
        }
    }
}