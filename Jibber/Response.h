//
//  Response.h
//  Jibber
//
//  Created by Matthew Cheok on 21/1/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

#import "MCModel.h"
#import "Displayable.h"

@interface Response : MCModel <Displayable>

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) NSDate *date;

@end
