//
//  TaskList.h
//  Rose-Task
//
//  Created by David Fisher on 8/15/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Task, TaskUser;

@interface TaskList : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * syncNeeded;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *taskUsers;
@property (nonatomic, retain) NSSet *tasks;
@end

@interface TaskList (CoreDataGeneratedAccessors)

- (void)addTaskUsersObject:(TaskUser *)value;
- (void)removeTaskUsersObject:(TaskUser *)value;
- (void)addTaskUsers:(NSSet *)values;
- (void)removeTaskUsers:(NSSet *)values;

- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

@end
