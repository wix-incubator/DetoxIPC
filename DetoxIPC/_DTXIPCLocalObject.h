//
//  _DTXIPCLocalObject.h
//  DetoxIPC
//
//  Created by Leo Natan (Wix) on 9/25/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DTXIPCConnection;
@class DTXIPCInterface;

NS_ASSUME_NONNULL_BEGIN

@interface _DTXIPCLocalObject : NSObject

+ (instancetype)_localObjectWithObject:(id)object connection:(DTXIPCConnection*)connection localInterface:(DTXIPCInterface*)interface;

- (oneway void)invokeWithSerializedInvocation:(NSDictionary*)serializedInvocation;

@end

NS_ASSUME_NONNULL_END
