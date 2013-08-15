//
//  Task.h
//  Rose-Task
//
//  Created by David Fisher on 8/15/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TaskList, TaskUser;

@interface Task : NSManagedObject

@property (nonatomic, retain) NSNumber * complete;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSNumber * syncNeeded;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) TaskUser *assignedTo;
@property (nonatomic, retain) TaskList *taskList;

@end
