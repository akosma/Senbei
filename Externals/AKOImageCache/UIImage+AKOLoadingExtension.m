//
//  UIImage+AKOLoadingExtension.m
//  AKOLibrary
//
//  Created by Adrian on 1/28/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "UIImage+AKOLoadingExtension.h"

@implementation UIImage (AKOLoadingExtension)

+ (UIImage *)newImageFromResource:(NSString *)filename
{
    NSString *imageFile = [[NSString alloc] initWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imageFile];
    [imageFile release];
    return image;
}

@end
