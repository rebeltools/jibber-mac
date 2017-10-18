//
//  Request.h
//  Jibber
//
//  Created by Matthew Cheok on 21/1/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

#import "MCModel.h"
#import "Displayable.h"

@interface Request : MCModel <Displayable>

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) NSDate *date;

@end
