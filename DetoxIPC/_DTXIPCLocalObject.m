//
//  _DTXIPCLocalObject.m
//  DetoxIPC
//
//  Created by Leo Natan (Wix) on 9/25/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import "_DTXIPCLocalObject.h"
#import "NSInvocation+DTXRemoteSerialization.h"

@implementation _DTXIPCLocalObject
{
	id _target;
	DTXIPCConnection* _connection;
	DTXIPCInterface* _interface;
}

+ (instancetype)_localObjectWithObject:(id)object connection:(DTXIPCConnection*)connection localInterface:(DTXIPCInterface*)interface
{
	_DTXIPCLocalObject* local = [_DTXIPCLocalObject new];
	if(self)
	{
		local->_connection = connection;
		local->_interface = interface;
		local->_target = object;
	}
	return local;
}

- (oneway void)invokeWithSerializedInvocation:(NSDictionary*)serializedInvocation
{
	NSInvocation* invocation = [NSInvocation _dtx_invocationWithSerializedDictionary:serializedInvocation remoteConnection:_connection];
	if([invocation isKindOfClass:NSClassFromString(@"NSBlockInvocation")] == NO)
	{
		invocation.target = _target;
	}
	
	[invocation invoke];
}

@end
