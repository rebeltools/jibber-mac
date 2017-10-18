//
//  Device.h
//  Jibber
//
//  Created by Matthew Cheok on 21/1/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

#import "MCModel.h"

@interface Device : MCModel

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *model;
@property (nonatomic, copy) NSString *hardware;
@property (nonatomic, copy) NSString *systemName;
@property (nonatomic, copy) NSString *systemVersion;
@property (nonatomic, copy) NSString *bundleName;
@property (nonatomic, copy) NSString *bundleIdentifier;
@property (nonatomic, copy) NSString *frameworkVersion;

@end
