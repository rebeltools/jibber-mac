//
//  OutlineDataSource.h
//  Jibber
//
//  Created by Matthew Cheok on 7/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;

@interface OutlineDataSource : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (strong, nonatomic) id jsonObject;

@end
