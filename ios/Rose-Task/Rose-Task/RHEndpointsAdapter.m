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
    GTLRosetaskTaskUser *aGtlTaskUser = [GTLRosetaskTaskUser alloc];
    [aGtlTaskUser setPreferredName:aTaskUser.preferred_name];
    [aGtlTaskUser setLowercaseEmail:aTaskUser.lowercase_email];
    [aGtlTaskUser setGooglePlusId:aTaskUser.google_plus_id];
    
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
    
}

- (void) syncTaskList:(TaskList *) aTaskList {
    GTLServiceRosetask *service = [self roseTaskService];
    // Convert the TaskList into a GtlTaskList.
    GTLRosetaskTaskList *aGtlTaskList = [GTLRosetaskTaskList alloc];
    [aGtlTaskList setTitle:aTaskList.title];
    // Users
    // Tasks

    GTLQueryRosetask *query = [GTLQueryRosetask queryForTasklistInsertWithObject:aGtlTaskList];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLRosetaskTaskList *returnedGtlTaskList, NSError *error) {
        NSLog(@"Done!");
        NSLog(@"Title = %@", returnedGtlTaskList.title);
        // Tasks
        // Users
        
        // Mark the TaskList in CD as no longer needing a sync.
        [aTaskList saveThenSync:NO];
        
        // TODO: Switch to 100% API methods please.
        // That way we can get the id and other things will be less messy.
        
//        TaskList * returnedTaskList = [TaskList taskListFromId:returnedGtlTaskList.identifier];
//        [returnedTaskList saveThenSync:NO];
    }];

}

- (void) syncDeletes {
    
}

@end
