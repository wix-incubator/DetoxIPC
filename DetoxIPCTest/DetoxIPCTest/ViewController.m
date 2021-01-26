//
//  ViewController.m
//  DetoxIPCTest
//
//  Created by Leo Natan on 1/26/21.
//

#import "ViewController.h"
#import <DetoxIPC/DetoxIPC.h>
#import "TestProtocol.h"

@interface ViewController () <TestProtocol>
{
	DTXIPCConnection* _connection;
}

@end

@implementation ViewController

- (void)asyncVoidBlockCallback:(dispatch_block_t)block
{
	block();
}

- (void)asyncMultipleVoidBlockCallback:(dispatch_block_t)block count:(NSUInteger)count
{
	for(NSUInteger idx = 0; idx < count; idx++)
	{
		block();
	}
}

- (void)asyncArrayBlockCallback:(void (^)(NSArray *))block array:(NSArray*)array
{
	block(array);
}

- (void)asyncIntegerBlockCallback:(void (^)(NSUInteger))block value:(NSUInteger)value
{
	block(value);
}

- (void)asyncDictionaryBlockCallback:(void (^)(NSDictionary *))block dictionary:(NSDictionary*)dictionary
{
	block(dictionary);
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_connection = [[DTXIPCConnection alloc] initWithServiceName:@"com.wix.DetoxIPCTest"];
	_connection.exportedInterface = [DTXIPCInterface interfaceWithProtocol:@protocol(TestProtocol)];
	_connection.exportedObject = self;
	
	[_connection resume];
}


@end
