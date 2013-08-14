//
//  RHTaskListDetailViewController.h
//  Rose-Task
//
//  Created by David Fisher on 8/12/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RHTaskListDetailTableViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic, strong) NSManagedObject * taskUser;
@property (nonatomic, strong) NSManagedObject * taskList;

@end
