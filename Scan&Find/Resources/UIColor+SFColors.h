//
//  UIColor+SFColors.h
//  Scan&Find
//
//  Created by Mike Quillinan on 9/19/12.
//  Copyright (c) 2012 AMTM Studios, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SFColors)

// Main Colors
+ (UIColor *)toolbarColor;

// TableViewCell colors.
+ (NSArray *)cellGradientColors;
+ (NSArray *)cellGradientPositions;
+ (NSArray *)cellSelectedGradientColors;
+ (NSArray *)cellSelectedGradientPositions;

@end
