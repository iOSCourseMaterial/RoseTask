//
//  RHTaskTableViewController.h
//  Rose-Task
//
//  Created by David Fisher on 8/8/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RHMocDidChangeTableViewController.h"
@class TaskList;

@interface RHTaskTableViewController : RHMocDidChangeTableViewController

@property (nonatomic) TaskList * taskList;

@end
