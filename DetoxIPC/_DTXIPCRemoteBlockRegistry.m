//
//  _DTXIPCRemoteBlockRegistry.m
//  DetoxIPC
//
//  Created by Leo Natan (Wix) on 9/25/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

/***
*    ██╗    ██╗ █████╗ ██████╗ ███╗   ██╗██╗███╗   ██╗ ██████╗
*    ██║    ██║██╔══██╗██╔══██╗████╗  ██║██║████╗  ██║██╔════╝
*    ██║ █╗ ██║███████║██████╔╝██╔██╗ ██║██║██╔██╗ ██║██║  ███╗
*    ██║███╗██║██╔══██║██╔══██╗██║╚██╗██║██║██║╚██╗██║██║   ██║
*    ╚███╔███╔╝██║  ██║██║  ██║██║ ╚████║██║██║ ╚████║╚██████╔╝
*     ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═══╝ ╚═════╝
*
*
* WARNING: This file compiles with ARC disabled! Take extra care when modifying or adding functionality.
*/

#import "_DTXIPCRemoteBlockRegistry.h"
@import ObjectiveC;

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
	
	@autoreleasepool
	{
		id copied = _Block_copy(block);
		_registry[identifier] = [copied autorelease];
	}
	
	return identifier;
}

+ (id)remoteBlockForIdentifier:(NSString*)identifier
{
	return _registry[identifier];
}

+ (oneway void)cleanupRemoteBlock:(NSString*)identifier
{
	@autoreleasepool
	{
		[_registry removeObjectForKey:identifier];
	}
}

@end
