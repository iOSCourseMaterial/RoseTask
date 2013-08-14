//
//  TaskUser+HelperUtils.h
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "TaskUser.h"

#define LOCAL_ONLY_EMAIL @"local_only"

@interface TaskUser (HelperUtils)

+ (TaskUser *) taskUserFromEmail:(NSString *) anEmail;
+ (TaskUser *) createFromEmail:(NSString *) anEmail;
+ (TaskUser *) localOnlyTaskUser;

@property (nonatomic, readonly) NSArray * sortedTaskLists;

- (void) saveThenSync:(BOOL) syncNeeded;

@end
