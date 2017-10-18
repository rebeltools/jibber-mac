//
//  Request.m
//  Jibber
//
//  Created by Matthew Cheok on 21/1/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

#import "Request.h"
#import <Mantle/MTLValueTransformer.h>

@implementation Request

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"path": @"path",
             @"body": @"body",
             @"uuid": @"uuid",
             @"method": @"method",
             @"headers": @"headers",
             @"date": @"date"
         };
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock:^id(NSNumber *epoch) {
        return [NSDate dateWithTimeIntervalSince1970:[epoch doubleValue]];
    }];
}

- (NSDictionary *)headers {
    if (_headers) {
        return _headers;
    }
    else {
        return @{};
    }
}

@end
