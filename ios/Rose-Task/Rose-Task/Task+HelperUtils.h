//
//  Task+HelperUtils.h
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "Task.h"
@class TaskList;

@interface Task (HelperUtils)

+ (Task *) taskFromId:(NSInteger) anId;
+ (Task *) createTaskforTaskList:(TaskList *) aTaskList;

- (void) saveThenSync:(BOOL) syncNeeded;

@end
