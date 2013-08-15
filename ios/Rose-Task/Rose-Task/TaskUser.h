//
//  TaskUser.h
//  Rose-Task
//
//  Created by David Fisher on 8/15/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Task, TaskList;

@interface TaskUser : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * googlePlusId;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * lowercaseEmail;
@property (nonatomic, retain) NSString * preferredName;
@property (nonatomic, retain) NSNumber * syncNeeded;
@property (nonatomic, retain) NSSet *taskLists;
@property (nonatomic, retain) Task *assignments;
@end

@interface TaskUser (CoreDataGeneratedAccessors)

- (void)addTaskListsObject:(TaskList *)value;
- (void)removeTaskListsObject:(TaskList *)value;
- (void)addTaskLists:(NSSet *)values;
- (void)removeTaskLists:(NSSet *)values;

@end
