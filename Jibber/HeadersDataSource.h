//
//  HeadersDataSource.h
//  Jibber
//
//  Created by Matthew Cheok on 6/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;

@interface HeadersDataSource : NSObject <NSOutlineViewDataSource>

@property (strong, nonatomic) NSDictionary *headers;

@end
