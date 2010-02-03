//
//  WebBrowserController.h
//  Saccharin
//
//  Created by Adrian on 2/3/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebBrowserController : UIViewController 
{
@private
    IBOutlet UIWebView *_webView;
    NSURL *_url;
}

@property (nonatomic, retain) NSURL *url;

@end
