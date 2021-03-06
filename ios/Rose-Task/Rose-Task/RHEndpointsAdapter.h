//
//  RHEndpointsAdapter.h
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GTLServiceRosetask;
@class TaskUser;
@class Task;
@class TaskList;
@class DeleteTransaction;

@interface RHEndpointsAdapter : NSObject

@property (nonatomic, readonly) GTLServiceRosetask * roseTaskService;
+ (RHEndpointsAdapter *) sharedInstance;

- (void) syncTaskUser:(TaskUser *) aTaskUser;
- (void) syncTask:(Task *) aTask;
- (void) syncTaskList:(TaskList *) aTaskList;

- (void) syncAll;
- (void) deleteTask:(DeleteTransaction *) aTaskDeleteTransaction;
- (void) deleteTaskList:(DeleteTransaction *) aTaskListDeleteTransaction;

- (void) updateAllForTaskUser:(TaskUser *) currentTaskUser;

@end
