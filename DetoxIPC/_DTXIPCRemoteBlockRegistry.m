//
//  _DTXIPCRemoteBlockRegistry.m
//  DetoxIPC
//
//  Created by Leo Natan (Wix) on 9/25/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import "_DTXIPCRemoteBlockRegistry.h"

static NSMutableDictionary* _registry;

@implementation _DTXIPCRemoteBlockRegistry

+ (void)load
{
	@autoreleasepool
	{
		_registry = [NSMutableDictionary new];
	}
}

+ (NSString*)registerRemoteBlock:(id)block
{
	NSString* identifier = [NSUUID UUID].UUIDString;
	_registry[identifier] = block;
	return identifier;
}

+ (id)remoteBlockForIdentifier:(NSString*)identifier
{
	return _registry[identifier];
}

+ (oneway void)cleanupRemoteBlock:(NSString*)identifier
{
	[_registry removeObjectForKey:identifier];
}

@end
