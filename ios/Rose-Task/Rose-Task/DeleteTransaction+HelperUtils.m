//
//  DeleteTransaction+HelperUtils.m
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "DeleteTransaction+HelperUtils.h"
#import "RHAppDelegate.h"
#import "Task+HelperUtils.h"
#import "TaskList+HelperUtils.h"

@implementation DeleteTransaction (HelperUtils)

+ (DeleteTransaction *) createTaskDeleteTransactionWithIdentifier:(Task *) taskAboutToBeDeleted {
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    DeleteTransaction * dt = (DeleteTransaction *)[NSEntityDescription insertNewObjectForEntityForName:@"DeleteTransaction"
                                                                     inManagedObjectContext:moc];
    [dt setEntityType:@"Task"];
    [dt setIdentifier:taskAboutToBeDeleted.identifier];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
    }
    return dt;
}

+ (DeleteTransaction *) createTaskListDeleteTransactionWithIdentifier:(TaskList *) taskListAboutToBeDeleted {
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    DeleteTransaction * dt = (DeleteTransaction *)[NSEntityDescription insertNewObjectForEntityForName:@"DeleteTransaction"
                                                                                inManagedObjectContext:moc];
    [dt setEntityType:@"Task"];
    [dt setIdentifier:taskListAboutToBeDeleted.identifier];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
    }
    return dt;
}

+ (DeleteTransaction *) deleteTransactionForIdentifier:(NSNumber *) anIdentifier {
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"DeleteTransaction"
                                              inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(identifier == %@)", anIdentifier];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if ([array count] > 0) {
        return array[0]; // There should only ever be one.
    }
    return nil;
}

#pragma mark - Instance methods
- (void) transactionComplete {
    
    NSManagedObjectContext *moc = self.managedObjectContext;
    [moc deleteObject:self];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
    }
}


@end
