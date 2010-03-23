//
//  AKOEditorrific.m
//  AKOLibrary
//
//  Created by Adrian on 2/27/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import "AKOEditorrific.h"

@implementation AKOEditorrific

@synthesize text = _text;
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super initWithFrame:CGRectMake(0.0, 149.0, 320.0, 116.0)])
    {
        _editorTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 5.0, 320.0, 67.0)];
        _editorTextView.font = [UIFont fontWithName:@"Helvetica" size:17.000];
        _editorTextView.text = @"";
        _editorTextView.delegate = self;
        
        _hidingTransformation = CGAffineTransformMakeTranslation(0.0, 350.0);    
        self.transform = _hidingTransformation;
        _oldTextHeight = 0.0;        

        NSString *cancel = NSLocalizedString(@"CANCEL", @"The 'Cancel' word");
        NSString *clear = NSLocalizedString(@"CLEAR", @"The 'Clear' word");

        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:cancel
                                                                   style:UIBarButtonItemStyleBordered 
                                                                  target:self 
                                                                  action:@selector(cancel:)];
        
        UIBarButtonItem *space1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                target:nil 
                                                                                action:nil];
        
        UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:clear
                                                                        style:UIBarButtonItemStyleBordered 
                                                                       target:self 
                                                                       action:@selector(clear:)];
        
        UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                target:nil 
                                                                                action:nil];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                target:self 
                                                                                action:@selector(done:)];

        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 70.0, 320.0, 44.0)];
        _toolbar.items = [NSArray arrayWithObjects:cancelButton, space1, clearButton, space2, doneButton, nil];
        [cancelButton release];
        [space1 release];
        [clearButton release];
        [space2 release];
        [doneButton release];

        UIImageView *topImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ako-editorrific-bar.png"]];
        topImage.frame = CGRectMake(0.0, 0.0, 320.0, 5.0);

        [self addSubview:_editorTextView];
        [self addSubview:_toolbar];
        [self addSubview:topImage];
        [topImage release];
    }
    return self;
}

- (void)dealloc
{
    [_editorTextView release];
    [_text release];
    [_toolbar release];
    [super dealloc];
}

#pragma mark -
#pragma mark Public methods

- (void)show
{
    [_editorTextView becomeFirstResponder];
    _editorTextView.text = _text;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Button handler methods

- (void)cancel:(id)sender
{
    if ([_delegate respondsToSelector:@selector(editorrificDidCancel:)])
    {
        [_delegate editorrificDidCancel:self];
    }
    [self dismissEditor];
}

- (void)done:(id)sender
{
    if ([_delegate respondsToSelector:@selector(editorrific:didEnterText:)])
    {
        [_delegate editorrific:self didEnterText:_editorTextView.text];
    }
    [self dismissEditor];
    _editorTextView.text = @"";
}

- (void)clear:(id)sender
{
    _editorTextView.text = @"";
}

#pragma mark -
#pragma mark UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView
{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:17.0];
    struct CGSize size = [_editorTextView.text sizeWithFont:font
                          constrainedToSize:CGSizeMake(280.0, 4000) 
                          lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = (size.height == 0.0) ? 21.0 : size.height;
    
    // This fix comes from Jack's comment #4 here
    // http://kosmaczewski.net/2009/02/28/that-twitterriffic-editor/
    if(height > 105.0)
    {
        height = 105.0;
    }
    
    if (height != _oldTextHeight)
    {
        _hidingTransformation = CGAffineTransformMakeTranslation(0.0, 350.0 + height);

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.frame = CGRectMake(0.0, 169.0 - height, 320.0, 95.0 + height);
        _editorTextView.frame = CGRectMake(0.0, 5.0, 320.0, 67.0 + height);
        _toolbar.frame = CGRectMake(0.0, 51.0 + height, 320.0, 44.0);
        [UIView commitAnimations];        

        _oldTextHeight = height;
    }
}

#pragma mark -
#pragma mark Private methods

- (void)dismissEditor
{
    [_editorTextView resignFirstResponder];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    self.transform = _hidingTransformation;
	[UIView commitAnimations];        
}

@end
