//
//  WebBrowserController.m
//  Saccharin
//
//  Created by Adrian on 2/3/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "WebBrowserController.h"

@implementation WebBrowserController

@synthesize url = _url;

- (void)dealloc 
{
    [_url release];
    [super dealloc];
}

- (void)viewDidLoad 
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_url];
    [_webView loadRequest:request];
    [request release];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

@end
