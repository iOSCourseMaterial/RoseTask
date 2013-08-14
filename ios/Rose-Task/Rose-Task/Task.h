//
//  Task.h
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSNumber * complete;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * sync_needed;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSManagedObject *assigned_to;
@property (nonatomic, retain) NSManagedObject *task_list;

@end
