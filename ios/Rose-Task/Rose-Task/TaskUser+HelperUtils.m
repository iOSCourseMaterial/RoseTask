//
//  TaskUser+HelperUtils.m
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "TaskUser+HelperUtils.h"
#import "RHAppDelegate.h"
#import "TaskList.h"
#import "RHEndpointsAdapter.h"

@implementation TaskUser (HelperUtils)

#pragma mark - Class methods
+ (TaskUser *) taskUserFromEmail:(NSString *) anEmail {
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"TaskUser"
                                              inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(lowercase_email == %@)", [anEmail lowercaseString]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if ([array count] > 0) {
        return array[0]; // There should only ever be one.
    }
    return nil;
}

+ (TaskUser *) createFromEmail:(NSString *) anEmail {
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    TaskUser * aTaskUser = (TaskUser *)[NSEntityDescription insertNewObjectForEntityForName:@"TaskUser"
                                                       inManagedObjectContext:moc];
    [aTaskUser setValue:[anEmail lowercaseString] forKey:@"lowercase_email"];
    [aTaskUser setCreated:[NSDate date]];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
    }
    return aTaskUser;
}

+ (TaskUser *) localOnlyTaskUser {
    static TaskUser * theLocalOnlyTaskUser = nil;
    if (theLocalOnlyTaskUser == nil) {
        theLocalOnlyTaskUser = [TaskUser taskUserFromEmail:LOCAL_ONLY_EMAIL];
        if (theLocalOnlyTaskUser == nil) {
            // Create TaskUser in core data.
            theLocalOnlyTaskUser = [TaskUser createFromEmail:LOCAL_ONLY_EMAIL];
            [theLocalOnlyTaskUser saveThenSync:NO];
        }
    }
    return theLocalOnlyTaskUser;
}

#pragma mark - Instance methods
- (void) saveThenSync:(BOOL) syncNeeded {
    NSManagedObjectContext *moc = self.managedObjectContext;
    self.sync_needed = [NSNumber numberWithBool:syncNeeded];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
    }
    // Potentially sync with Endpoints.
    if (syncNeeded && ![self.lowercase_email isEqualToString:LOCAL_ONLY_EMAIL]) {
        // Save the TaskUser with Endpoints
        NSLog(@"Updating Task User %@ with endpoints.", self.lowercase_email);
        [RHEndpointsAdapter.sharedInstance syncTaskUser:self];
    }
}

- (NSArray *)sortedTaskLists
{
    return [self.task_lists.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(TaskList *) obj1 created] compare:[(TaskList *) obj2 created]];
    }];
}

@end
