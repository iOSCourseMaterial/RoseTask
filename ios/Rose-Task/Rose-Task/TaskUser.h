//
//  TaskUser.h
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TaskUser : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * google_plus_id;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * lowercase_email;
@property (nonatomic, retain) NSString * preferred_name;
@property (nonatomic, retain) NSNumber * sync_needed;
@property (nonatomic, retain) NSSet *task_lists;
@end

@interface TaskUser (CoreDataGeneratedAccessors)

- (void)addTask_listsObject:(NSManagedObject *)value;
- (void)removeTask_listsObject:(NSManagedObject *)value;
- (void)addTask_lists:(NSSet *)values;
- (void)removeTask_lists:(NSSet *)values;

@end
