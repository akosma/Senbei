//
//  WebBrowserController.m
//  Senbei
//
//  Created by Adrian on 2/3/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "WebBrowserController.h"

@implementation WebBrowserController

@synthesize url = _url;

#pragma mark -
#pragma mark Init and dealloc

- (void)dealloc 
{
    [_url release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [self reload:nil];
    _navigationBar.topItem.title = [_url absoluteString];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)close:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)openInSafari:(id)sender
{
    [[UIApplication sharedApplication] openURL:_url];
}

- (IBAction)reload:(id)sender
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_url];
    [_webView loadRequest:request];
    [request release];
}

#pragma mark -
#pragma mark UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

@end
