//
//  RHTaskListDetailViewController.h
//  Rose-Task
//
//  Created by David Fisher on 8/12/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RHTaskListDetailViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObject * taskUser;
@property (nonatomic, strong) NSManagedObject * taskList;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

- (IBAction)save:(id)sender;
- (IBAction)addTaskUser:(id)sender;
- (IBAction)removeTaskUser:(id)sender;
- (IBAction)deleteTaskList:(id)sender;
- (IBAction)textEditingDone:(id)sender;

@end
