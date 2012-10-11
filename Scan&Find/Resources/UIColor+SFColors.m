//
//  UIColor+SFColors.m
//  Scan&Find
//
//  Created by Mike Quillinan on 9/19/12.
//  Copyright (c) 2012 AMTM Studios, LLC. All rights reserved.
//

#import "UIColor+SFColors.h"

@implementation UIColor (SFColors)

#pragma mark - Main Colors
+ (UIColor *)toolbarColor {
    return [UIColor colorWithRed:0.647 green:0.647 blue:0.427 alpha:1];
}

#pragma mark - TableViewCell Colors
+ (NSArray *)cellGradientColors {
    return [NSArray arrayWithObjects:
            (id)[[UIColor colorWithRed:1.0 green:1.0 blue:0.827 alpha:1] CGColor],
            (id)[[UIColor colorWithRed:0.847 green:0.847 blue:0.627 alpha:1] CGColor],
            (id)[[UIColor colorWithRed:0.847 green:0.847 blue:0.627 alpha:1] CGColor],
            (id)[[UIColor colorWithRed:0.647 green:0.647 blue:0.427 alpha:1] CGColor],
            nil];
}

+ (NSArray *)cellGradientPositions {
    return [NSArray arrayWithObjects:
            [NSNumber numberWithFloat: 0],
            [NSNumber numberWithFloat: 0.01],
            [NSNumber numberWithFloat: 0.98],
            [NSNumber numberWithFloat: 1],
            nil];
}

+ (NSArray *)cellSelectedGradientColors {
    return [NSArray arrayWithObjects:
            [NSNumber numberWithFloat: 0],
            [NSNumber numberWithFloat: 0.03],
            [NSNumber numberWithFloat: 0.097],
            [NSNumber numberWithFloat: 1],
            nil];
}

+ (NSArray *)cellSelectedGradientPositions {
    return [NSArray arrayWithObjects:
            (id)[[UIColor colorWithRed:0.447 green:0.447 blue:0.227 alpha:1] CGColor],
            (id)[[UIColor colorWithRed:0.647 green:0.647 blue:0.427 alpha:1] CGColor],
            (id)[[UIColor colorWithRed:0.647 green:0.647 blue:0.427 alpha:1] CGColor],
            (id)[[UIColor colorWithRed:0.447 green:0.447 blue:0.227 alpha:1] CGColor],
            nil];
}

@end
