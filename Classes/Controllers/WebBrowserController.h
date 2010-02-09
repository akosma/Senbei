//
//  WebBrowserController.h
//  Senbei
//
//  Created by Adrian on 2/3/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebBrowserController : UIViewController <UIWebViewDelegate>
{
@private
    IBOutlet UINavigationBar *_navigationBar;
    IBOutlet UIWebView *_webView;
    NSURL *_url;
}

@property (nonatomic, retain) NSURL *url;

- (IBAction)close:(id)sender;
- (IBAction)openInSafari:(id)sender;
- (IBAction)reload:(id)sender;

@end
