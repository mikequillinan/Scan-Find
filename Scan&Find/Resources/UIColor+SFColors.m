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
    return [UIColor colorWithRed:0.078 green:0.282 blue:0.063 alpha:1];
}

#pragma mark - TableViewCell Colors
+ (NSArray *)cellGradientColors {
    return [NSArray arrayWithObjects:
            (id)[[UIColor colorWithRed:0.258 green:0.462 blue:0.243 alpha:1] CGColor],
            (id)[[UIColor colorWithRed:0.058 green:0.262 blue:0.043 alpha:1] CGColor],
            (id)[[UIColor colorWithRed:0.058 green:0.262 blue:0.043 alpha:1] CGColor],
            (id)[[UIColor colorWithRed:0.000 green:0.062 blue:0.000 alpha:1] CGColor],
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
            (id)[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0] CGColor],
            (id)[[UIColor colorWithRed:0.0f green:0.162f blue:0.0f alpha:1] CGColor],
            (id)[[UIColor colorWithRed:0.0f green:0.162f blue:0.0f alpha:1] CGColor],
            (id)[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0] CGColor],
            nil];
}

@end
