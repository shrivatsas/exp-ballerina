import ballerina/io;
import ballerina/log;
import ballerina/nats;

const string ESCAPE = "!q";

public function main() {
    string message = "";
    string subject = io:readln("Subject : ");

    nats:Connection conn = new;

    nats:StreamingProducer publisher = new (conn);

    while (message != ESCAPE) {
        message = io:readln("Message : ");
        if (message != ESCAPE) {

            var result = publisher->publish(subject, <@untainted>message);
            if (result is nats:Error) {
                error e = result;
                log:printError("Error occurred while closing the connection", e);
            } else {
                log:printInfo("GUID " + result
                                        + " received for the produced message.");
            }
        }
    }

    var result = conn.close();
    if (result is error) {
        error e = result;
        log:printError("Error occurred while closing the connection", e);
    }
}