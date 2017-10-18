//
//  HeadersDataSource.m
//  Jibber
//
//  Created by Matthew Cheok on 6/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

#import "HeadersDataSource.h"

@interface HeadersDataSource ()

@property (nonatomic, strong) NSArray *headerKeys;

@end

@implementation HeadersDataSource

- (void)setHeaders:(NSDictionary *)headers {
    _headers = headers;
    self.headerKeys = [headers.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return self.headerKeys.count;
    }
    else {
        return 0;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return self.headerKeys[index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([tableColumn.identifier isEqualToString:@"header"]) {
        return item;
    }
    else if ([tableColumn.identifier isEqualToString:@"value"]) {
        return self.headers[item];
    }
    return nil;
}

@end
