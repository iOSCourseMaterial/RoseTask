//
//  RHTaskDetailViewController.h
//  Rose-Task
//
//  Created by David Fisher on 8/11/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Task;

@interface RHTaskDetailViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic) Task * task;

@property (weak, nonatomic) IBOutlet UITextField *textTextField;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;

- (IBAction)save:(id)sender;
- (IBAction)deleteTask:(id)sender;
- (IBAction)textEditingDone:(id)sender;

@end
