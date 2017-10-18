//
//  NSSplitView+Autosave.m
//  Jibber
//
//  Created by Matthew Cheok on 30/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

#import "NSSplitView+Autosave.h"

@implementation NSSplitView (Autosave)

- (void)restoreAutosavedPositions {
    
    // Yes, I know my Autosave Name; but I won't necessarily restore myself automatically.
    NSString *key = [NSString stringWithFormat:@"NSSplitView Subview Frames %@", self.autosaveName];
    
    NSArray *subviewFrames = [[NSUserDefaults standardUserDefaults] valueForKey:key];
    if (!subviewFrames) {
        return;
    }
    
    // the last frame is skipped because I have one less divider than I have frames
    for (NSInteger i=0; i < (subviewFrames.count - 1); i++ ) {
        
        // this is the saved frame data - it's an NSString
        NSString *frameString = subviewFrames[i];
        NSArray *components = [frameString componentsSeparatedByString:@", "];
        
        // only one component from the string is needed to set the position
        CGFloat position;
        
        // if I'm vertical the third component is the frame width
        if (self.vertical) position = [components[2] floatValue];
        
        // if I'm horizontal the fourth component is the frame height
        else position = [components[3] floatValue];
        
        [self setPosition:position ofDividerAtIndex:i];
    }
}
@end