//
//  TaskList+HelperUtils.h
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "TaskList.h"
@class TaskUser;

@interface TaskList (HelperUtils)

+ (TaskList *) taskListFromId:(NSNumber *) anId;
+ (TaskList *) createTaskListforTaskUser:(TaskUser *) aTaskUser;

@property (nonatomic, readonly) NSArray * sortedTasks;
@property (nonatomic, readonly) NSArray * sortedTaskUsers;
@property (nonatomic, readonly) NSArray * sortedTaskUserEmails;
- (void) saveThenSync:(BOOL) syncNeeded;
- (void) deleteThenSync:(BOOL) syncNeeded;
@end
