import ballerina/io;
import ballerina/http;

# Clients can be used to connect to and interact with HTTP endpoints.
public function main() returns @tainted error? {
    http:Client clientEP = new ("http://www.mocky.io");
    http:Response resp = check clientEP->get("/v2/5ae082123200006b00510c3d/");
    string payload = check resp.getTextPayload();
    io:println(payload);
}