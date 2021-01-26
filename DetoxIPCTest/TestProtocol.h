//
//  TestProtocol.h
//  DetoxIPCTest
//
//  Created by Leo Natan on 1/26/21.
//

#import <Foundation/Foundation.h>

@protocol TestProtocol <NSObject>

- (void)asyncVoidBlockCallback:(dispatch_block_t)block;
- (void)asyncMultipleVoidBlockCallback:(dispatch_block_t)block count:(NSUInteger)count;
- (void)asyncIntegerBlockCallback:(void(^)(NSUInteger value))block value:(NSUInteger)value;
- (void)asyncDictionaryBlockCallback:(void(^)(NSDictionary* dictionary))block dictionary:(NSDictionary*)dictionary;
- (void)asyncArrayBlockCallback:(void(^)(NSArray* array))block array:(NSArray*)array;

@end

