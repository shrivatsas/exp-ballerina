import ballerina/io;
import ballerina/lang.'int;

# A function pointer is a Ballerina type that allows using functions as variables, arguments to functions, and function return values. 
# The name of a function serves as a pointer to that function when called from other functions or operations. 
# The definition of the function name provides the type of the pointer in terms of a function signature.
function test(string s, int... x) returns float {
    int|error y = 'int:fromString(s);
    float f = 0.0;

    if(y is int) {
        foreach var item in x {
            f += item * 1.0 * y;
        }
    } else {
        panic y;
    }
    return f;
}

function foo(int x, function(string, int...) returns float bar) returns float {
    return x * bar("2",2,3,4,5);
}

function funcPtr() returns (function(string, int...) returns float) {
    return test;
}

public function main() {
    io:println("Answer: ", foo(10, test));
    io:println("Answer: ", foo(10, funcPtr()));

    function (string, int...) returns float f = funcPtr();
    io:println("Answer: ", foo(10, f));
}