//
//  _DTXIPCDistantObject.m
//  DetoxIPC
//
//  Created by Leo Natan (Wix) on 9/24/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import "_DTXIPCDistantObject.h"
#import "DTXIPCConnection.h"
#import "DTXIPCConnection-Private.h"
#import "NSConnection.h"
#import "NSInvocation+DTXRemoteSerialization.h"
@import ObjectiveC;

@implementation _DTXIPCDistantObject
{
	DTXIPCConnection* _connection;
	DTXIPCInterface* _interface;
	BOOL _synchronous;
	void (^_errorBlock)(NSError*);
}

+ (instancetype)_distantObjectWithConnection:(DTXIPCConnection*)connection remoteInterface:(DTXIPCInterface*)interface synchronous:(BOOL)synchronous errorBlock:(void(^)(NSError*))errorBlock
{
	_DTXIPCDistantObject* rv = [_DTXIPCDistantObject new];
	rv->_connection = connection;
	rv->_interface = interface;
	rv->_synchronous = synchronous;
	rv->_errorBlock = errorBlock;
	
	return rv;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	NSMethodSignature* s = [super methodSignatureForSelector:aSelector];
	if(s) { return s; }
	
	return [_interface protocolMethodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
	NSDictionary* serialized = [invocation _dtx_serializedDictionary];
	
	[_connection.otherConnection.rootProxy _invokeFromRemote:serialized];
}

@end
