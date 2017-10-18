//
//  Response.m
//  Jibber
//
//  Created by Matthew Cheok on 21/1/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

#import "Response.h"
#import <Mantle/MTLValueTransformer.h>

@implementation Response

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			   @"uuid": @"uuid",
               @"body": @"body",
               @"statusCode": @"status_code",
               @"duration": @"duration",
               @"headers": @"headers",
               @"date": @"date",
			   @"errorMessage": @"error_message"
	};
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock:^id(NSNumber *epoch) {
        return [NSDate dateWithTimeIntervalSince1970:[epoch doubleValue]];
    }];
}

@end
