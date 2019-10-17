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

- (void)aComplexSelector:(NSUInteger)a b:(NSString*)str c:(void(^)(dispatch_block_t))block1 d:(void(^)(NSArray*))test;

@end
```

On the server process, create an class which implements the common protocol you have defined. Create a `DTXIPCConnection` object with a named service, set an exported interface and finally set the exported object. Optionally, you can also set the remote object interface for bi-directional communication.

```objc
@interface MyObject : NSObject <ExampleProtocol> @end
@implementation MyObject
  
- (void)aMoreComplexSelector:(NSUInteger)a b:(NSString*)str c:(void(^)(dispatch_block_t))block1 d:(void(^)(NSArray*))test
{
	if(block1 != nil)
	{
		block1(^ {
			NSLog(@"from inner block");
		});
	}
	
	test(@[@"Hello", @123, @{@"Hi": @"There"}]);
}

@end

//…
  
_connection = [[DTXIPCConnection alloc] initWithServiceName:@"MyService"];
_connection.exportedInterface = [DTXIPCInterface interfaceWithProtocol:@protocol(ExampleProtocol)];
_connection.exportedObject = [[MyObject alloc] init];
```

On the client process, connect to the registered named service, set the remote object interface and obtain a remote proxy object. You can now use this proxy object as if it is an instance of the remote object.

```objc
_connection = [[DTXIPCConnection alloc] initWithServiceName:@"MyService"];
_connection.remoteObjectInterface = [DTXIPCInterface interfaceWithProtocol:@protocol(ExampleProtocol)];

id<ExampleProtocol> remoteProxyObject = _connection.remoteObjectProxy;
//A crazy example to demonstrate the capabilities of DTXIPC! 😂
[remoteProxyObject aMoreComplexSelector:10 b:@"Hello World!" c:^ (dispatch_block_t block) {
	NSLog(@"from first block");
	
	if(block)
	{
		block();
	}
} d:^(NSArray * arr) {
	NSLog(@"from second block: %@", arr);
}];
```

The expected output on the server process should be:

```
from inner block
```


And the client process:

```
from first block
from second block: (
    Hello,
    123,
        {
        Hi = There;
    }
)
```
