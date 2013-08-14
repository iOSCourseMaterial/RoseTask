//
//  RHTaskListTableViewController.h
//  Rose-Task
//
//  Created by David Fisher on 8/8/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RHTaskListTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>
- (IBAction)addTaskList:(id)sender;
@property (nonatomic, strong) NSManagedObject * taskUser;
@end
