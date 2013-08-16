//
//  RHTaskListDetailViewController.h
//  Rose-Task
//
//  Created by David Fisher on 8/12/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TaskUser;
@class TaskList;

@interface RHTaskListDetailViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic) TaskUser * taskUser;
@property (nonatomic) TaskList * taskList;

- (IBAction)save:(id)sender;
- (IBAction)editTaskListTaskUsers:(id)sender;
- (IBAction)deleteTaskList:(id)sender;
- (IBAction)textEditingDone:(id)sender;

@end
