//
//  DTXIPCConnection-Private.h
//  DetoxIPC
//
//  Created by Leo Natan (Wix) on 9/25/19.
//  Copyright © 2019 LeoNatan. All rights reserved.
//

#import "DTXIPCConnection.h"

@protocol _DTXIPCImpl <NSObject>

- (oneway void)_slaveDidConnectWithName:(NSString*)slaveServiceName;
- (oneway void)_remoteDidInvalidate;
- (oneway void)_invokeFromRemote:(NSDictionary*)serializedInvocation;
- (oneway void)_invokeRemoteBlock:(NSDictionary*)serializedBlock;
- (oneway void)_cleanupRemoteBlock:(NSString*)identifier;

@end

@interface DTXIPCConnection ()

@property (nonatomic) BOOL slave;

@property (nonatomic, strong) NSConnection* connection;
@property (nonatomic, strong) NSConnection* otherConnection;

@end
