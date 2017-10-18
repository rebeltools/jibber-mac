//
//  Device.m
//  Jibber
//
//  Created by Matthew Cheok on 21/1/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

#import "Device.h"

@implementation Device

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
			   @"systemName": @"system_name",
			   @"systemVersion": @"system_version",
			   @"bundleName": @"bundle_name",
			   @"bundleIdentifier": @"bundle_identifier",
			   @"frameworkVersion": @"framework_version",
               @"name": @"name",
               @"uuid": @"uuid",
               @"model": @"model",
               @"hardware": @"hardware"
	};
}

- (BOOL)isEqual:(id)other {
	if (other == self) {
		return YES;
	}
	else if (![super isEqual:other]) {
		return NO;
	}
	else {
		return [self.uuid isEqualToString:[(Device *)other uuid]];
	}
}

- (NSUInteger)hash {
	return self.uuid.hash;
}

@end
