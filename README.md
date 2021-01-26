# DetoxIPC

DetoxIPC is an asynchronous, bi-directional inter-process remote invocation library for Apple platforms with an API similar to Apple's `NSXPCConnection`.

Once a connection is established, messages sent to remote proxies are serialized over mach ports to their remote counterparts. Block parameters are supported, and their lifetime is mirrored to their remote proxy counterparts (if a proxy block is retained and remains active for use, so is the local proxy).

**Note:** This framework is intended primarily for testing purposes, such as between a test runner process and the tested app process. The framework uses private API and is not suitable for App Store submission. On macOS, use an XPC service. On iOS and tvOS, due to the limited viability of multiple processes running at the same time, the framework is less useful there anyway.

## Usage

Include the project in your projects and link it.

Read the `DTXIPCConnection.h` header for full documentation.

First, create a common protocol, which will be used to define the interface between remote objects.

```objc
@protocol ExampleProtocol <NSObject>

- (void)performOperationWithCompletionHandler:(dispatch_block_t)block;
- (void)performOperationWithOptions:(NSDictionary*)options completionHandler:(NSDictionary* options)block;

@end
```

On the server process, create an class which implements the common protocol you have defined. Create a `DTXIPCConnection` object with a named service, set an exported interface and finally set the exported object. Optionally, you can also set the remote object interface for bi-directional communication.

```objc
@interface MyObject : NSObject <ExampleProtocol> @end
@implementation MyObject
  
- (void)performOperationWithCompletionHandler:(dispatch_block_t)block {
  NSLog(@"Called performOperationWithCompletionHandler:");
  block();
}

- (void)performOperationWithOptions:(NSDictionary*)options completionHandler:(NSDictionary* options)block {
  NSLog(@"Called performOperationWithOptions:completionHandler: with options: %@", options);
  block(options);
}

@end

//…
  
_connection = [[DTXIPCConnection alloc] initWithServiceName:@"MyService"];
_connection.exportedInterface = [DTXIPCInterface interfaceWithProtocol:@protocol(ExampleProtocol)];
_connection.exportedObject = [[MyObject alloc] init];

[_connection resume];
```

On the client process, connect to the registered named service, set the remote object interface and obtain a remote proxy object. You can now use this proxy object as if it is an instance of the remote object.

```objc
_connection = [[DTXIPCConnection alloc] initWithServiceName:@"MyService"];
_connection.remoteObjectInterface = [DTXIPCInterface interfaceWithProtocol:@protocol(ExampleProtocol)];

[_connection resume];

id<ExampleProtocol> remoteProxyObject = _connection.remoteObjectProxy;

[remoteProxyObject performOperationWithCompletionHandler:^{
  NSLog("Completion handler called");
}];

[remoteProxyObject performOperationWithOptions:@{@"Test": @"Passed"} completionHandler:^ (NSDictionary* options) {
  NSLog("Completion handler called with options: %@", options);
}];
```

The expected output on the server process should be:

```
Called performOperationWithCompletionHandler:
Called performOperationWithOptions:completionHandler: with options: {
    Test = Passed;
}
```


And the client process:

```
Completion handler called
Completion handler called with options: {
    Test = Passed;
}
```
