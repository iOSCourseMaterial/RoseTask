//
//  Task+HelperUtils.h
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "Task.h"
@class TaskList;
@class GTLRosetaskApiMessagesTaskResponseMessage;

@interface Task (HelperUtils)

+ (Task *) taskFromId:(NSNumber *) anId;
+ (Task *) createTaskforTaskList:(TaskList *) aTaskList;
+ (Task *) taskUserFromMessage:(GTLRosetaskApiMessagesTaskResponseMessage *) apiTaskMessage  withParentTaskList:(TaskList *) parentTaskList;
- (void) saveThenSync:(BOOL) syncNeeded;
- (void) deleteThenSync:(BOOL) syncNeeded;

@end
