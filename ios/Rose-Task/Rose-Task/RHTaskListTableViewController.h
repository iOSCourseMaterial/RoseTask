//
//  RHTaskListTableViewController.h
//  Rose-Task
//
//  Created by David Fisher on 8/8/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RHMocDidChangeTableViewController.h"
@class TaskUser;

@interface RHTaskListTableViewController : RHMocDidChangeTableViewController

@property (nonatomic) TaskUser * taskUser;

@end
