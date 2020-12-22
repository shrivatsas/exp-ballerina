ballerina grpc --input grpc_bidirectional_streaming.proto  --output stubs

ballerina add bi_streaming_client
ballerina build bi_streaming_client

ballerina add bi_streaming_service
ballerina build bi_streaming_service