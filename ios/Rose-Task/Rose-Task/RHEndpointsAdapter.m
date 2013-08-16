//
//  RHEndpointsAdapter.m
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHEndpointsAdapter.h"
#import "GTLServiceRosetask.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTLRosetask.h"
#import "TaskUser+HelperUtils.h"
#import "TaskList+HelperUtils.h"
#import "Task+HelperUtils.h"

#define LOCAL_TESTING_ONLY YES

@implementation RHEndpointsAdapter

+(id)sharedInstance
{
    static dispatch_once_t pred;
    static RHEndpointsAdapter *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[RHEndpointsAdapter alloc] init];
    });
    return sharedInstance;
}

- (GTLServiceRosetask *)roseTaskService {
    static GTLServiceRosetask *service = nil;
    if (!service) {
        service = [[GTLServiceRosetask alloc] init];
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.retryEnabled = YES;
        
        [GTMHTTPFetcher setLoggingEnabled:YES];
    }
    return service;
}


- (void) syncTaskUser:(TaskUser *) aTaskUser {
    if (LOCAL_TESTING_ONLY) {
        NSLog(@"Local testing no TaskUser sent");
        return;
    }
    GTLServiceRosetask *service = [self roseTaskService];
    // Convert the TaskUser into a GtlTaskUser.
    GTLRosetaskTaskUser *aGtlTaskUser = [GTLRosetaskTaskUser alloc];
    [aGtlTaskUser setPreferredName:aTaskUser.preferredName];
    [aGtlTaskUser setLowercaseEmail:aTaskUser.lowercaseEmail];
    [aGtlTaskUser setGooglePlusId:aTaskUser.googlePlusId];
    
    GTLQueryRosetask *query = [GTLQueryRosetask queryForTaskuserInsertWithObject:aGtlTaskUser];
    
    NSLog(@"Sending...");
    NSLog(@" lowercaseEmail = %@", aGtlTaskUser.lowercaseEmail);
    NSLog(@" preferredName = %@", aGtlTaskUser.preferredName);
    NSLog(@" googlePlusId = %@", aGtlTaskUser.googlePlusId);
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLRosetaskTaskUser *returnedGtlTaskUser, NSError *error) {
        NSLog(@"Done!");
        NSLog(@"Created = %@", returnedGtlTaskUser.created);
        NSLog(@"lowercaseEmail = %@", returnedGtlTaskUser.lowercaseEmail);
        NSLog(@"preferredName = %@", returnedGtlTaskUser.preferredName);
        NSLog(@"googlePlusId = %@", returnedGtlTaskUser.googlePlusId);
        
        // Mark the TaskUser in CD as no longer needing a sync.
        TaskUser * returnedTaskUser = [TaskUser taskUserFromEmail:returnedGtlTaskUser.lowercaseEmail];
        [returnedTaskUser saveThenSync:NO];
    }];
}

- (void) syncTask:(Task *) aTask {
    if (LOCAL_TESTING_ONLY) {
        NSLog(@"Local testing no Task sent");
        return;
    }
    GTLServiceRosetask *service = [self roseTaskService];
    // Convert the Task into a GtlTask.
    GTLRosetaskTask *aGtlTask = [GTLRosetaskTask alloc];
    [aGtlTask setIdentifier:aTask.identifier];
    [aGtlTask setText:aTask.text];
    [aGtlTask setTaskListId:aTask.taskList.identifier];
    [aGtlTask setDetails:aTask.details];
    [aGtlTask setAssignedToEmail:aTask.assignedTo.lowercaseEmail];
    [aGtlTask setComplete:aTask.complete];
    
    GTLQueryRosetask *query = [GTLQueryRosetask queryForTaskInsertWithObject:aGtlTask];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLRosetaskTask *returnedGtlTask, NSError *error) {
        NSLog(@"Done!");
        NSLog(@"text = %@", returnedGtlTask.text);
        NSLog(@"identifier = %@", returnedGtlTask.identifier);
        
        // Mark the TaskList in CD as no longer needing a sync.
        [aTask setIdentifier:returnedGtlTask.identifier];
        [aTask saveThenSync:NO];
    }];

}

- (void) syncTaskList:(TaskList *) aTaskList {
    if (LOCAL_TESTING_ONLY) {
        NSLog(@"Local testing no TaskList sent");
        return;
    }
    GTLServiceRosetask *service = [self roseTaskService];
    // Convert the TaskList into a GtlTaskList.
    GTLRosetaskTaskList *aGtlTaskList = [GTLRosetaskTaskList alloc];
    [aGtlTaskList setIdentifier:aTaskList.identifier];
    [aGtlTaskList setTitle:aTaskList.title];
    [aGtlTaskList setTaskUserEmails:aTaskList.sortedTaskUsers];
    // Note that tasks are not sent in TaskList updates

    GTLQueryRosetask *query = [GTLQueryRosetask queryForTasklistInsertWithObject:aGtlTaskList];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLRosetaskTaskList *returnedGtlTaskList, NSError *error) {
        NSLog(@"Done!");
        NSLog(@"title = %@", returnedGtlTaskList.title);
        NSLog(@"identifier = %@", returnedGtlTaskList.identifier);
        NSLog(@"emails = %@", returnedGtlTaskList.taskUserEmails);
        // Tasks are not given here.
        
        // Mark the TaskList in CD as no longer needing a sync.
        [aTaskList setIdentifier:returnedGtlTaskList.identifier];
        // Consider: Could sync the created times by converting the GAE created time string to an NSDate.
//        [aTaskList setCreated:returnedGtlTaskList.created];
        [aTaskList saveThenSync:NO];
        // Note, this might be adding the id to CD!  Originally I thought I'd do this.  No way.
        //TaskList * returnedTaskList = [TaskList taskListFromId:returnedGtlTaskList.identifier];
        //[returnedTaskList saveThenSync:NO];
    }];

}

- (void) syncDeletes {
    if (LOCAL_TESTING_ONLY) {
        NSLog(@"Local testing no Delete sent");
        return;
    }
    
}

@end
