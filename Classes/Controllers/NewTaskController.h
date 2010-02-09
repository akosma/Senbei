//
//  NewTaskController.h
//  Senbei
//
//  Created by Adrian on 1/30/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewTaskController : UITableViewController <UITextFieldDelegate,
                                                      UIPickerViewDataSource,
                                                      UIPickerViewDelegate>
{
@private
    UINavigationController *_navigationController;
    UITextField *_nameField;
    UITextField *_bucketField;
    UITextField *_categoryField;
    
    NSString *_selectedBucket;
    UIPickerView *_bucketPicker;
    NSArray *_buckets;

    NSString *_selectedCategory;
    UIPickerView *_categoryPicker;
    NSArray *_categories;
    
    NSDate *_selectedDate;
    UIDatePicker *_datePicker;
}

@property (nonatomic, readonly) UINavigationController *navigationController;

@end
