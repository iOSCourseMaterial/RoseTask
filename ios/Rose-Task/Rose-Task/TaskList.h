//
//  TaskList.h
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Task, TaskUser;

@interface TaskList : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * sync_needed;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *task_users;
@property (nonatomic, retain) NSSet *tasks;
@end

@interface TaskList (CoreDataGeneratedAccessors)

- (void)addTask_usersObject:(TaskUser *)value;
- (void)removeTask_usersObject:(TaskUser *)value;
- (void)addTask_users:(NSSet *)values;
- (void)removeTask_users:(NSSet *)values;

- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
