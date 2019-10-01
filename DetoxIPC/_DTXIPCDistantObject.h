//
//  _DTXIPCDistantObject.h
//  DetoxIPC
//
//  Created by Leo Natan (Wix) on 9/24/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DTXIPCConnection;
@class DTXIPCInterface;

NS_ASSUME_NONNULL_BEGIN

@interface _DTXIPCDistantObject : NSObject

+ (instancetype)_distantObjectWithConnection:(DTXIPCConnection*)connection remoteInterface:(DTXIPCInterface*)interface synchronous:(BOOL)synchronous errorBlock:(void(^ __nullable)(NSError*))errorBlock;

@end

NS_ASSUME_NONNULL_END
