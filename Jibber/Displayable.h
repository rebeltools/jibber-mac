//
//  Displayable.h
//  Jibber
//
//  Created by Matthew Cheok on 5/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Displayable <NSObject>

@property (nonatomic, copy) NSString *body;
@property (nonatomic, strong) NSDictionary *headers;

@end
