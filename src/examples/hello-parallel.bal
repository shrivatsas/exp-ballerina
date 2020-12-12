import ballerina/io;

# Worker - sequence of statements executed concurrently with all other workers in the function.
public function main() {
    @strand{thread: "any"}
    worker w1 {
        io:println("Hello world! #m");
    }

    @strand{thread: "any"}
    worker w2 {
        io:println("Hello world! #n");
    }

    @strand{thread: "any"}
    worker w3 {
        io:println("Hello world! #k");
    }

}
