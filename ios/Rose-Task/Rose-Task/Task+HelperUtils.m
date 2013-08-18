//
//  Task+HelperUtils.m
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "Task+HelperUtils.h"
#import "RHAppDelegate.h"
#import "RHEndpointsAdapter.h"
#import "DeleteTransaction+HelperUtils.h"

@implementation Task (HelperUtils)

+ (Task *) taskFromId:(NSInteger) anId {
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Task"
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

+ (Task *) createTaskforTaskList:(TaskList *) aTaskList {
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    Task * aTask = (Task *)[NSEntityDescription insertNewObjectForEntityForName:@"Task"
                                                                     inManagedObjectContext:moc];
    [aTask setTaskList:aTaskList];
    [aTask setCreated:[NSDate date]];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
    }
    return aTask;
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
        [[RHEndpointsAdapter sharedInstance] syncTask:self];
    }
}

- (void) deleteThenSync:(BOOL) syncNeeded {
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    self.syncNeeded = [NSNumber numberWithBool:syncNeeded]; // About to be deleted. :)
    
    // Potentially sync with Endpoints.
    if (syncNeeded) {
        NSLog(@"TODO: Create a delete transaction and make it happen");
        DeleteTransaction * dt = [DeleteTransaction createTaskDeleteTransactionWithIdentifier:self];
        [[RHEndpointsAdapter sharedInstance] deleteTask:dt];
    }
    [moc deleteObject:self];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
    }

}

@end
