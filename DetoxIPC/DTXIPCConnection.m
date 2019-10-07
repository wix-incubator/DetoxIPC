//
//  DTXIPCConnection.m
//  DetoxIPC
//
//  Created by Leo Natan (Wix) on 9/24/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import "DTXIPCConnection-Private.h"
#import "NSConnection.h"
#import "ObjCRuntime.h"
#import "_DTXIPCDistantObject.h"
#import "_DTXIPCLocalObject.h"
#import "_DTXIPCRemoteBlockRegistry.h"
@import ObjectiveC;

@interface DTXIPCInterface ()

@property (nonatomic, readwrite) Protocol* protocol;
@property (nonatomic, strong) NSDictionary<NSString*, NSMethodSignature*>* selectoToSignature;
@property (nonatomic, strong, readwrite) NSArray<NSMethodSignature*>* methodSignatures;

@end

@implementation DTXIPCInterface
{
	struct objc_method_description* _methodList;
	unsigned int _methodListCount;
}

static void _DTXAddSignatures(Protocol* protocol, NSMutableArray* signatures, NSMutableDictionary* map)
{
	unsigned int count = 0;
	{
		objc_property_t* unsupported = protocol_copyPropertyList2(protocol, &count, YES, YES);
		dtx_defer {
			free_if_needed(unsupported);
		};
		if(count > 0)
		{
			[NSException raise:NSInvalidArgumentException format:@"Properties are not suppoerted."];
		}
	}
	{
		objc_property_t* unsupported = protocol_copyPropertyList2(protocol, &count, NO, YES);
		dtx_defer {
			free_if_needed(unsupported);
		};
		if(count > 0)
		{
			[NSException raise:NSInvalidArgumentException format:@"Properties are not suppoerted."];
		}
	}
	{
		objc_property_t* unsupported = protocol_copyPropertyList2(protocol, &count, YES, NO);
		dtx_defer {
			free_if_needed(unsupported);
		};
		if(count > 0)
		{
			[NSException raise:NSInvalidArgumentException format:@"Properties are not suppoerted."];
		}
	}
	{
		objc_property_t* unsupported = protocol_copyPropertyList2(protocol, &count, NO, NO);
		dtx_defer {
			free_if_needed(unsupported);
		};
		if(count > 0)
		{
			[NSException raise:NSInvalidArgumentException format:@"Properties are not suppoerted."];
		}
	}
	
	{
		struct objc_method_description * unsupported = protocol_copyMethodDescriptionList(protocol, YES, NO, &count);
		dtx_defer {
			free_if_needed(unsupported);
		};
		if(count > 0)
		{
			[NSException raise:NSInvalidArgumentException format:@"Class methods are not supported."];
		}
	}
	
	{
		struct objc_method_description * unsupported = protocol_copyMethodDescriptionList(protocol, NO, NO, &count);
		dtx_defer {
			free_if_needed(unsupported);
		};
		if(count > 0)
		{
			[NSException raise:NSInvalidArgumentException format:@"Class methods are not supported."];
		}
	}
	{
		struct objc_method_description * unsupported = protocol_copyMethodDescriptionList(protocol, NO, YES, &count);
		dtx_defer {
			free_if_needed(unsupported);
		};
		if(count > 0)
		{
			[NSException raise:NSInvalidArgumentException format:@"Optional methods are not supported."];
		}
	}
	{
		struct objc_method_description * supported = protocol_copyMethodDescriptionList(protocol, YES, YES, &count);
		dtx_defer {
			free_if_needed(supported);
		};
		
		for(unsigned int idx = 0; idx < count; idx++)
		{
			const char* types = _protocol_getMethodTypeEncoding(protocol, supported[idx].name, YES, YES);
			
			NSMethodSignature* methodSignature = [NSMethodSignature signatureWithObjCTypes:types];
			
			if(strncmp(methodSignature.methodReturnType, "v", 2))
			{
				[NSException raise:NSInvalidArgumentException format:@"Methods must have 'void' return type."];
			}
			
			map[NSStringFromSelector(supported[idx].name)] = methodSignature;
			[signatures addObject:methodSignature];
		}
	}
}

static void _DTXIterateProtocols(Protocol* protocol, NSMutableArray* signatures, NSMutableDictionary* map)
{
	if(protocol_isEqual(protocol, @protocol(NSObject)))
	{
		return;
	}
	
	unsigned int adoptedCount = 0;
	Protocol* __unsafe_unretained * adoptedProtocols = protocol_copyProtocolList(protocol, &adoptedCount);
	dtx_defer {
		free_if_needed(adoptedProtocols);
	};
	
	for(unsigned int idx = 0; idx < adoptedCount; idx++)
	{
		_DTXIterateProtocols(adoptedProtocols[idx], signatures, map);
	}
	
	_DTXAddSignatures(protocol, signatures, map);
}

+ (instancetype)interfaceWithProtocol:(Protocol *)protocol
{
	DTXIPCInterface* rv = [DTXIPCInterface new];
	rv.protocol = protocol;

	NSMutableArray<NSMethodSignature*>* signatures = [NSMutableArray new];
	NSMutableDictionary<NSString*, NSMethodSignature*>* map = [NSMutableDictionary new];
	
	_DTXIterateProtocols(rv.protocol, signatures, map);
	
	rv.selectoToSignature = map;
	rv.methodSignatures = signatures;

	return rv;
}

- (NSUInteger)numberOfMethods
{
	return _methodListCount;
}

- (NSMethodSignature *)protocolMethodSignatureForSelector:(SEL)aSelector
{
	return _selectoToSignature[NSStringFromSelector(aSelector)];
}

@end

static dispatch_queue_t _connectionQueue;

@implementation DTXIPCConnection
{
	NSRunLoop* _runLoop;
}

- (void)_runThread
{
	NSThread.currentThread.name = [NSString stringWithFormat:@"com.wix.DTXIPCConnection:%@", _serviceName];
	
	_runLoop = NSRunLoop.currentRunLoop;
	
	[_connection run];
}

- (void)_commonInit
{
	NSPort* port = NSPort.port;
	
	_connection = [NSConnection connectionWithReceivePort:port sendPort:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_mainConnectionDidDie:) name:NSConnectionDidDieNotification object:_connection];
	_connection.rootObject = self;
	[_connection registerName:_serviceName];
	
	[NSThread detachNewThreadSelector:@selector(_runThread) toTarget:self withObject:nil];
//	[_connection runInNewThread];
}

- (instancetype)initWithServiceName:(NSString *)serviceName
{
	self = [super init];
	if(self)
	{
		_serviceName = serviceName;
		_slave = NO;
		
		[self _commonInit];
	}
	return self;
}

- (instancetype)initWithRegisteredServiceName:(NSString *)serviceName
{
	self = [super init];
	if(self)
	{
		_serviceName = [NSString stringWithFormat:@"%@.slave", serviceName];
		_slave = YES;
		
		[self _commonInit];
		
		_otherConnection = [NSConnection connectionWithRegisteredName:serviceName host:nil];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_otherConnectionDidDie:) name:NSConnectionDidDieNotification object:_otherConnection];
		[(id)_otherConnection.rootProxy _slaveDidConnectWithName:_serviceName];
	}
	return self;
}

- (void)_mainConnectionDidDie:(NSNotification*)note
{
	[_otherConnection invalidate];
	
	dispatch_block_t block = _invalidationHandler;
	_invalidationHandler = nil;
	
	[_runLoop performBlock:^{
		if(block)
		{
			block();
		}
		[NSThread exit];
	}];
}

- (void)_otherConnectionDidDie:(NSNotification*)note
{
	if(_connection.isValid)
	{
		[_connection invalidate];
	}
}

- (void)invalidate
{
	[_connection invalidate];
	[_otherConnection invalidate];
}

- (BOOL)isValid
{
	return _connection.isValid && _otherConnection.isValid;
}

- (id)remoteObjectProxy
{
	return [_DTXIPCDistantObject _distantObjectWithConnection:self remoteInterface:self.remoteObjectInterface synchronous:NO errorBlock:nil];
}

- (id)remoteObjectProxyWithErrorHandler:(void (^)(NSError * _Nonnull))handler
{
	return [_DTXIPCDistantObject _distantObjectWithConnection:self remoteInterface:self.remoteObjectInterface synchronous:NO errorBlock:handler];
}

- (id)synchronousRemoteObjectProxyWithErrorHandler:(void (^)(NSError * _Nonnull))handler
{
	return [_DTXIPCDistantObject _distantObjectWithConnection:self remoteInterface:self.remoteObjectInterface synchronous:YES errorBlock:handler];
}

- (void)setExportedObject:(id)exportedObject
{
	NSParameterAssert(self.exportedInterface != nil);
	_exportedObject = exportedObject;
}

#pragma mark _DTXIPCImpl

- (oneway void)_slaveDidConnectWithName:(NSString*)slaveServiceName
{
	_otherConnection = [NSConnection connectionWithRegisteredName:slaveServiceName host:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_otherConnectionDidDie:) name:NSConnectionDidDieNotification object:_otherConnection];
}

- (oneway void)_invokeFromRemote:(NSDictionary*)serializedInvocation
{
	_DTXIPCLocalObject* localObj = [_DTXIPCLocalObject _localObjectWithObject:self.exportedObject connection:self localInterface:self.exportedInterface];
	[localObj invokeWithSerializedInvocation:serializedInvocation];
}

- (oneway void)_invokeRemoteBlock:(NSDictionary*)serializedBlock
{
	id localBlock = [_DTXIPCRemoteBlockRegistry remoteBlockForIdentifier:serializedBlock[@"remoteBlockIdentifier"]];
	_DTXIPCLocalObject* localObj = [_DTXIPCLocalObject _localObjectWithObject:localBlock connection:self localInterface:self.exportedInterface];
	[localObj invokeWithSerializedInvocation:serializedBlock];
}

- (oneway void)_cleanupRemoteBlock:(NSString*)identifier
{
	[_DTXIPCRemoteBlockRegistry cleanupRemoteBlock:identifier];
}

@end
