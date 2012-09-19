//
//  WebViewController.h
//  Scan&Find
//
//  Created by Mike Quillinan on 1/22/10.
//  Copyright 2010 AMTM Studios, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WebViewControllerDelegate;

@interface WebViewController : UIViewController

@property (unsafe_unretained) id<WebViewControllerDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil titleText:(NSString *)title initialURL:(NSString *)urlString showDoneButton:(BOOL)showDone;
 // title text for the webview
 // urlstring the url to open
 // showDoneButton button. YES: show on bottom toolbar. NO: show on navigation bar. Default is YES;

@end

@protocol WebViewControllerDelegate <NSObject>;

- (void)webViewController:(WebViewController *)controller didPressDoneButton:(id)sender;

@end

