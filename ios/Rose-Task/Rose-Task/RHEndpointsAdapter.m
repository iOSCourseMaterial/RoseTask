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
    GTLServiceRosetask *service = [self roseTaskService];
    // Convert the TaskUser into a GtlTaskUser.
    GTLRosetaskTaskUserProtoLowercaseEmailPreferredNameGooglePlusId *aGtlTaskUser = [GTLRosetaskTaskUserProtoLowercaseEmailPreferredNameGooglePlusId alloc];
    [aGtlTaskUser setPreferredName:aTaskUser.preferredName];
    [aGtlTaskUser setLowercaseEmail:aTaskUser.lowercaseEmail];
    [aGtlTaskUser setGooglePlusId:aTaskUser.googlePlusId];
    
    GTLQueryRosetask *query = [GTLQueryRosetask queryForTaskuserInsertWithObject:aGtlTaskUser];
    
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
    
    GTLServiceRosetask *service = [self roseTaskService];
    // Convert the Task into a GtlTask.
    GTLRosetaskTaskProtoIdTextTaskListIdDetailsCompleteAssignedToEmail *aGtlTask = [GTLRosetaskTaskProtoIdTextTaskListIdDetailsCompleteAssignedToEmail alloc];
    [aGtlTask setText:aTask.text];
    [aGtlTask setTaskListId:aTask.taskList.identifier];
    [aGtlTask setText:aTask.text];
    [aGtlTask setText:aTask.text];
    [aGtlTask setText:aTask.text];
    [aGtlTask setText:aTask.text];
    
    GTLQueryRosetask *query = [GTLQueryRosetask queryForTaskInsertWithObject:aGtlTask];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLRosetaskTask *returnedGtlTask, NSError *error) {
        NSLog(@"Done!");
        NSLog(@"Text = %@", returnedGtlTask.text);
        NSLog(@"id = %@", returnedGtlTask.identifier);
        
        // Mark the TaskList in CD as no longer needing a sync.
        [aTask setIdentifier:returnedGtlTask.identifier];
        [aTask saveThenSync:NO];
    }];

}

- (void) syncTaskList:(TaskList *) aTaskList {
    GTLServiceRosetask *service = [self roseTaskService];
    // Convert the TaskList into a GtlTaskList.
    GTLRosetaskTaskListProtoIdTitleTaskUserEmails *aGtlTaskList = [GTLRosetaskTaskListProtoIdTitleTaskUserEmails alloc];
    [aGtlTaskList setTitle:aTaskList.title];
    [aGtlTaskList setTaskUserEmails:aTaskList.sortedTaskUsers];
    // Note that tasks are not sent in TaskList updates

    GTLQueryRosetask *query = [GTLQueryRosetask queryForTasklistInsertWithObject:aGtlTaskList];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLRosetaskTaskList *returnedGtlTaskList, NSError *error) {
        NSLog(@"Done!");
        NSLog(@"Title = %@", returnedGtlTaskList.title);
        NSLog(@"id = %@", returnedGtlTaskList.identifier);
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
    
}

@end
