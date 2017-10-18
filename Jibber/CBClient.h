//
//  CBClient.h
//  CBServer
//
//  Created by Matthew Cheok on 8/8/15.
//  Copyright © 2015 Matthew Cheok. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBClient;
@protocol CBClientDelegate <NSObject>

- (void)client:(CBClient *)client didReceiveData:(NSData *)data;

@end

@interface CBClient : NSObject

@property (nonatomic, copy, readonly) NSString *uuid;
@property (nonatomic, weak) id <CBClientDelegate> delegate;

- (instancetype)initWithUUID:(NSString *)uuid;

@end
