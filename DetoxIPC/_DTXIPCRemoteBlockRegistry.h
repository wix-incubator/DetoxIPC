//
//  _DTXIPCRemoteBlockRegistry.h
//  DetoxIPC
//
//  Created by Leo Natan (Wix) on 9/25/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface _DTXIPCRemoteBlockRegistry : NSObject

+ (NSString*)registerRemoteBlock:(id)block;
+ (id)remoteBlockForIdentifier:(NSString*)identifier;
+ (oneway void)cleanupRemoteBlock:(NSString*)identifier;

@end

NS_ASSUME_NONNULL_END
