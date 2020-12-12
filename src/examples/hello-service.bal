# Services represent collections of network-accessible entry points. 
# Resources represent one such entry point. 
# How a resource is exposed over a network protocol depends on the listener to which a service is attached.

import ballerina/http;

service hello on new http:Listener(9090) {

    resource function sayHello(http:Caller caller, http:Request request) returns error? {
        check caller->respond("Hello World!");
    }
}