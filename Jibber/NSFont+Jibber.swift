//
//  NSFont+Jibber.swift
//  Jibber
//
//  Created by Matthew Cheok on 26/3/15.
//  Copyright (c) 2015 Matthew Cheok. All rights reserved.
//

import AppKit

extension NSFont {
    class func jibber_standardFontOfSize(_ size: CGFloat) -> NSFont {
        return NSFont(name: "HelveticaNeue", size: size)!
    }

    class func jibber_mediumFontOfSize(_ size: CGFloat) -> NSFont {
        return NSFont(name: "HelveticaNeue-Medium", size: size)!
    }

    class func jibber_lightFontOfSize(_ size: CGFloat) -> NSFont {
        return NSFont(name: "HelveticaNeue-Light", size: size)!
    }
}
