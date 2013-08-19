//
//  TaskUser+HelperUtils.h
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "TaskUser.h"
@class GTLRosetaskApiMessagesTaskUserResponseMessage;
@class TaskList;

#define LOCAL_ONLY_EMAIL @"local_only"

@interface TaskUser (HelperUtils)

+ (TaskUser *) taskUserFromEmail:(NSString *) anEmail;
+ (TaskUser *) createFromEmail:(NSString *) anEmail;
+ (TaskUser *) taskUserFromMessage:(GTLRosetaskApiMessagesTaskUserResponseMessage *) apiTaskUserMessage withParentTaskList:(TaskList *) parentTaskList;
+ (TaskUser *) localOnlyTaskUser;

@property (nonatomic, readonly) NSArray * sortedTaskLists;
@property (nonatomic, strong) UIImage * googlePlusImage;

- (void) saveThenSync:(BOOL) syncNeeded;
- (void) addImageUsingFetch;

@end
