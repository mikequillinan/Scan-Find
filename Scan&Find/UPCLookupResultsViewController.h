//
//  UPCLookupResultsViewController.h
//  Scan&Find
//
//  Created by Mike Quillinan on 2/3/12.
//  Copyright (c) 2012 AMTM Studios, LLC. All rights reserved.
//

#import "LookupViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface UPCLookupResultsViewController : LookupViewController <CLLocationManagerDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andUPCString:(NSString *)upcString;

@end
