//
//  DeleteTransaction+HelperUtils.h
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "DeleteTransaction.h"
@class Task;
@class TaskList;

@interface DeleteTransaction (HelperUtils)

+ (DeleteTransaction *) createTaskDeleteTransactionWithIdentifier:(Task *) taskAboutToBeDeleted;
+ (DeleteTransaction *) createTaskListDeleteTransactionWithIdentifier:(TaskList *) taskListAboutToBeDeleted;

- (void) transactionComplete;
@end
