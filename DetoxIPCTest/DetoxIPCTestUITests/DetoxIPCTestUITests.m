//
//  DetoxIPCTestUITests.m
//  DetoxIPCTestUITests
//
//  Created by Leo Natan on 1/26/21.
//

#import <XCTest/XCTest.h>
#import "../TestProtocol.h"
#import <DetoxIPC/DetoxIPC.h>

@interface DetoxIPCTestUITests : XCTestCase
{
	DTXIPCConnection* _connection;
}

@end

@implementation DetoxIPCTestUITests

- (void)setUp
{
	// Put setup code here. This method is called before the invocation of each test method in the class.
	
	// In UI tests it is usually best to stop immediately when a failure occurs.
	self.continueAfterFailure = NO;
	
	// In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)testExample
{
	__block BOOL wasInvalidated = NO;
	
	__block XCUIApplication *app;
	
	_connection = [[DTXIPCConnection alloc] initWithServiceName:@"com.wix.DetoxIPCTest"];
	_connection.remoteObjectInterface = [DTXIPCInterface interfaceWithProtocol:@protocol(TestProtocol)];
	_connection.invalidationHandler = ^{
		wasInvalidated = YES;
	};
	[_connection resume];
	
	id<TestProtocol> proxy = [_connection synchronousRemoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
		NSLog(@"ERROR:: %@", error);
	}];
	
	BOOL proxyObjectConforms = [proxy conformsToProtocol:@protocol(TestProtocol)];
	
	app = [[XCUIApplication alloc] init];
	[app launch];
	
	NSArray* arr1 = @[@1, @2, @3];
	__block NSArray* arr2 = nil;
	
	NSDictionary* dict1 = @{@"Test": @"Passed"};
	__block NSDictionary* dict2 = nil;
	
	const NSUInteger integer1 = 123;
	__block NSUInteger integer2;
	
	__block BOOL callbackWasCalled;
	
	const NSUInteger count = 3;
	__block NSUInteger callbackCount = 0;
	
	[proxy asyncVoidBlockCallback:^{
		callbackWasCalled = YES;
	}];
	
	[proxy asyncMultipleVoidBlockCallback:^{
		callbackCount += 1;
	} count:count];
	
	[proxy asyncIntegerBlockCallback:^(NSUInteger value) {
		integer2 = value;
	} value:integer1];
	
	[proxy asyncArrayBlockCallback:^(NSArray *array) {
		arr2 = array;
	} array:arr1];
	
	[proxy asyncDictionaryBlockCallback:^(NSDictionary *dictionary) {
		dict2 = dictionary;
	} dictionary:dict1];
	
	[app terminate];
	
	XCTAssertTrue(proxyObjectConforms);
	XCTAssertEqualObjects(arr1, arr2);
	XCTAssertEqualObjects(dict1, dict2);
	XCTAssertEqual(integer1, integer2);
	XCTAssertEqual(count, callbackCount);
	XCTAssertTrue(callbackWasCalled);
	XCTAssertTrue(wasInvalidated);
}

@end
