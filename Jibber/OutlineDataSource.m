//
//  OutlineDataSource.m
//  Jibber
//
//  Created by Matthew Cheok on 7/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

#import "OutlineDataSource.h"

static NSString* const kNodeKeyName = @"key";
static NSString* const kNodeValueName = @"value";
static NSString* const kNodeChildrenName = @"children";

@interface OutlineDataSource ()

@property (nonatomic, strong) NSArray *tree;

@end

@implementation OutlineDataSource

- (void)setJsonObject:(id)jsonObject {
	_jsonObject = jsonObject;

	self.tree = [[self subtreeForObject:jsonObject withKey:@"@self"] valueForKey:@"children"];
}

- (NSDictionary *)subtreeForObject:(id)object withKey:(NSString *)key {
	if ([object isKindOfClass:[NSDictionary class]]) {
		NSArray *subKeys = [[object allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		NSMutableArray *children = [NSMutableArray array];

		for (NSString *childKey in subKeys) {
			NSString *keyPath = [key isEqualToString:@"@self"] ? childKey : [key stringByAppendingFormat:@".%@", childKey];
			[children addObject:[self subtreeForObject:object[childKey] withKey:keyPath]];
		}

		return @{
				   kNodeKeyName: key,
                   kNodeValueName: object,
				   kNodeChildrenName: [children copy]
		};
	}
	else if ([object isKindOfClass:[NSArray class]]) {
		NSMutableArray *children = [NSMutableArray array];

		for (NSInteger i = 0; i < [object count]; i++) {
			NSString *keyPath = [key stringByAppendingFormat:@"[%lu]", (unsigned long)i];
			[children addObject:[self subtreeForObject:object[i] withKey:keyPath]];
		}

		return @{
				   kNodeKeyName: key,
                   kNodeValueName: object,
				   kNodeChildrenName: [children copy]
		};
	}
	else {
		return @{
				   kNodeKeyName: key,
                   kNodeValueName: object ?: [NSNull null],
		};
	}
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	if (item == nil) {
		return self.tree.count;
	}
	else {
        return [item[kNodeChildrenName] count];
        
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [item[kNodeChildrenName] count] > 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	if (item == nil) {
        return self.tree[index];
	}
	else {
		return item[kNodeChildrenName][index];
	}
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	if ([tableColumn.identifier isEqualToString:@"key"]) {
        NSString *keyPath = item[kNodeKeyName];
        if ([keyPath hasSuffix:@"]"]) {
            NSString *text = [[keyPath componentsSeparatedByString:@"["] lastObject];
            return [@"Item " stringByAppendingString:[text substringToIndex:text.length-1]];
        }
        else {
            return [[keyPath componentsSeparatedByString:@"."] lastObject];
        }
        
	}
	else if ([tableColumn.identifier isEqualToString:@"value"]) {
        id value = item[kNodeValueName];
        if ([value isKindOfClass:[NSArray class]]) {
            return [NSString stringWithFormat:@"%lu item%@", (unsigned long)[value count], [value count] == 1 ? @"" : @"s"];
        }
        else if ([value isKindOfClass:[NSString class]]) {
            return value;
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            return [value stringValue];
        }
        else if ([value isKindOfClass:[NSNull class]]) {
            return @"null";
        }
        
		return @"";
	}
    else if ([tableColumn.identifier isEqualToString:@"type"]) {
        id value = item[kNodeValueName];
        if ([value isKindOfClass:[NSArray class]]) {
            return @"Array";
        }
        else if ([value isKindOfClass:[NSString class]]) {
            return @"String";
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            return @"Number";
        }
        else if ([value isKindOfClass:[NSDictionary class]]) {
            return @"Object";
        }
        
        return @"";
    }
	return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([cell isKindOfClass:[NSTextFieldCell class]]) {
        if ([tableColumn.identifier isEqualToString:@"type"]) {
            if ([cell isHighlighted]) {
                [cell setTextColor: [NSColor whiteColor]];
            } else {
                [cell setTextColor: [NSColor secondaryLabelColor]];
            }
        }
    }
}

@end
