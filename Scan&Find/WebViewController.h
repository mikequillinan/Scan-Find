//
//  WebViewController.h
//  Scan&Find
//
//  Created by Mike Quillinan on 1/22/10.
//  Copyright 2010 AMTM Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@protocol WebViewControllerDelegate;

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (weak) id<WebViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil titleText:(NSString *)title andInitialURL:(NSString *)urlString;

@end

@protocol WebViewControllerDelegate <NSObject>;

- (void)webViewController:(WebViewController *)controller didPressDoneButton:(id)sender;

@end

