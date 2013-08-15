//
//  TaskList+HelperUtils.m
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "TaskList+HelperUtils.h"
#import "RHAppDelegate.h"
#import "RHEndpointsAdapter.h"
#import "Task+HelperUtils.h"
#import "TaskUser+HelperUtils.h"

@implementation TaskList (HelperUtils)

+ (TaskList *) taskListFromId:(NSNumber *) anId {
        RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *moc = [ad managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"TaskList"
                                                  inManagedObjectContext:moc];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(id == %@)", anId];
        [request setPredicate:predicate];
        NSError *error;
        NSArray *array = [moc executeFetchRequest:request error:&error];
        if ([array count] > 0) {
            return array[0]; // There should only ever be one.
        }
        return nil;

}

+ (TaskList *) createTaskListforTaskUser:(TaskUser *) aTaskUser {
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    TaskList * aTaskList = (TaskList *)[NSEntityDescription insertNewObjectForEntityForName:@"TaskList"
                                                                     inManagedObjectContext:moc];
    [aTaskList addTaskUsersObject:aTaskUser];
    [aTaskList setCreated:[NSDate date]];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error %@", [error localizedDescription]);
    }
    return aTaskList;
}

#pragma mark - Instance methods
- (void) saveThenSync:(BOOL) syncNeeded {
    NSManagedObjectContext *moc = self.managedObjectContext;
    self.syncNeeded = [NSNumber numberWithBool:syncNeeded];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
    }
    // Potentially sync with Endpoints.
    if (syncNeeded) {
        // Save the TaskUser with Endpoints
        [[RHEndpointsAdapter sharedInstance] syncTaskList:self];
    }
}


- (NSArray *)sortedTasks
{
    return [self.tasks.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(Task *) obj1 created] compare:[(Task *) obj2 created]];
    }];
}

- (NSArray *)sortedTaskUsers
{
    return [self.taskUsers.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        // If there is a preferred name use that then emails.
        NSString * obj1PreferredName = [(TaskUser *) obj1 preferredName];
        NSString * obj2PreferredName = [(TaskUser *) obj2 preferredName];
        if (obj1PreferredName == nil && obj2PreferredName == nil) {
            return [obj1PreferredName compare:obj2PreferredName];
        } else if (obj1PreferredName == nil) {
            return NSOrderedAscending;
        } else if (obj2PreferredName == nil) {
            return NSOrderedDescending;
        } else {
            return [[(TaskUser *) obj1 created] compare:[(TaskUser *) obj2 created]];
        }
    }];
}

@end
