//
//  AKOEditorrific.h
//  AKOLibrary
//
//  Created by Adrian on 2/27/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKOEditorrificDelegate.h"

@interface AKOEditorrific : UIView <UITextViewDelegate>
{
@private
    UITextView *_editorTextView;
    UIToolbar *_toolbar;

    NSString *_text;
    CGFloat _oldTextHeight;
    CGAffineTransform _hidingTransformation;
    
    IBOutlet id<AKOEditorrificDelegate> _delegate;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) id<AKOEditorrificDelegate> delegate;

- (void)show;
- (void)dismissEditor;

@end
