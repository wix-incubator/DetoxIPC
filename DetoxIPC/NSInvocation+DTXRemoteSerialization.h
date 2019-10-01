//
//  NSInvocation+DTXRemoteSerialization.h
//  DetoxIPC
//
//  Created by Leo Natan (Wix) on 9/25/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DTXIPCConnection;

NS_ASSUME_NONNULL_BEGIN

extern void* _DTXRemoteBlockIdentifierKey;

@interface NSInvocation (DTXRemoteSerialization)

- (NSDictionary*)_dtx_serializedDictionary;

+ (instancetype)_dtx_invocationWithSerializedDictionary:(NSDictionary*)serialized remoteConnection:(DTXIPCConnection*)connection;

@end

NS_ASSUME_NONNULL_END
