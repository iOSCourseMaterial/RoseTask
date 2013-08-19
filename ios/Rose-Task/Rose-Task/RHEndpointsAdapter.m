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
#import "DeleteTransaction+HelperUtils.h"
#import "GTLRosetaskApiMessagesTaskListResponseMessage+Customization.h"

#define LOCAL_TESTING_ONLY NO

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

        if ([returnedGtlTaskUser.lowercaseEmail isEqualToString:aGtlTaskUser.lowercaseEmail]) {
            NSLog(@"*** Done sending TaskUser and it worked!");
            // Mark the TaskUser in CD as no longer needing a sync.
            TaskUser * returnedTaskUser = [TaskUser taskUserFromEmail:returnedGtlTaskUser.lowercaseEmail];
            [returnedTaskUser saveThenSync:NO];
        } else {
            NSLog(@"*** Done sending TaskUser, but it failed. :(");
        }
        NSLog(@"  created = %@", returnedGtlTaskUser.created);
        NSLog(@"  lowercaseEmail = %@", returnedGtlTaskUser.lowercaseEmail);
        NSLog(@"  preferredName = %@", returnedGtlTaskUser.preferredName);
        NSLog(@"  googlePlusId = %@", returnedGtlTaskUser.googlePlusId);
    }];
}

- (void) syncTask:(Task *) aTask {
    if (LOCAL_TESTING_ONLY) {
        NSLog(@"Local testing no Task sent");
        return;
    }
    if (!aTask.taskList.identifier) {
        NSLog(@"Abort this task sync.  There is no TaskList identifier.  Don't waste Endpoints time.");
        return;
    }
    GTLServiceRosetask *service = [self roseTaskService];
    // Convert the Task into a GtlTask.
    GTLRosetaskTask *aGtlTask = [GTLRosetaskTask alloc];
    if (aTask.identifier != nil && [aTask.identifier longLongValue] > 0) {
        // Only add the identifier if it already exist.
        [aGtlTask setIdentifier:aTask.identifier];
    } else {
        // Go ahead and make sure it's nil if this is a new entry.
        [aGtlTask setIdentifier:nil];
    }
    [aGtlTask setText:aTask.text];
    [aGtlTask setTaskListId:aTask.taskList.identifier];
    [aGtlTask setDetails:aTask.details];
    [aGtlTask setAssignedToEmail:aTask.assignedTo.lowercaseEmail];
    [aGtlTask setComplete:aTask.complete];
    
    GTLQueryRosetask *query = [GTLQueryRosetask queryForTaskInsertWithObject:aGtlTask];
    
    NSLog(@"Sending...");
    NSLog(@" text = %@", aGtlTask.text);
    NSLog(@" identifier = %@", aGtlTask.identifier);
    NSLog(@" details = %@", aGtlTask.details);
    
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
    if (aTaskList.identifier != nil && [aTaskList.identifier longLongValue] > 0) {
        // Only add the identifier if it already exist.
        [aGtlTaskList setIdentifier:aTaskList.identifier];
    } else {
        // Go ahead and make sure it's nil if this is a new entry.
        [aGtlTaskList setIdentifier:nil];
    }
    [aGtlTaskList setTitle:aTaskList.title];
    [aGtlTaskList setTaskUserEmails:aTaskList.sortedTaskUserEmails];
    
    // Note that tasks are not sent in TaskList updates

    GTLQueryRosetask *query = [GTLQueryRosetask queryForTasklistInsertWithObject:aGtlTaskList];
    
    NSLog(@"Sending...");
    NSLog(@" title = %@", aGtlTaskList.title);
    NSLog(@" identifier = %@", aGtlTaskList.identifier);
    
    if (aGtlTaskList.identifier) {
        // Only add the identifier if it already exist.
        NSLog(@"aGtlTaskList HAS an identifier %@", aGtlTaskList.identifier);
        [aGtlTaskList setIdentifier:aTaskList.identifier];
    } else {
        NSLog(@"aGtlTaskList has no identifier");
    }

    NSLog(@" emails = %@", aGtlTaskList.taskUserEmails);
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLRosetaskTaskList *returnedGtlTaskList, NSError *error) {
        NSLog(@"Done!");
        NSLog(@"title = %@", returnedGtlTaskList.title);
        NSLog(@"identifier = %@", returnedGtlTaskList.identifier);
        NSLog(@"emails = %@", returnedGtlTaskList.taskUserEmails);
        // Tasks are not given here.
        
        // Mark the TaskList in CD as no longer needing a sync.
        [aTaskList setIdentifier:returnedGtlTaskList.identifier];
        [aTaskList saveThenSync:NO];
    }];

}

- (void) deleteTask:(DeleteTransaction *) aTaskDeleteTransaction{
    if (LOCAL_TESTING_ONLY) {
        NSLog(@"Local testing no Delete Task sent");
        return;
    }
    
    // Create an API message to delete a task
    GTLServiceRosetask *service = [self roseTaskService];
    GTLRosetaskTask *aGtlTask = [GTLRosetaskTask alloc];
    [aGtlTask setIdentifier:aTaskDeleteTransaction.identifier];
    // Rest can be blank.
    
    GTLQueryRosetask *query = [GTLQueryRosetask queryForTaskDeleteWithIdentifier:[aTaskDeleteTransaction.identifier longLongValue]];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLRosetaskTask *returnedGtlTask, NSError *error) {
        NSLog(@"Done!");
        NSLog(@"text = %@", returnedGtlTask.text);
        NSLog(@"identifier = %@", returnedGtlTask.identifier);
        

        // Consider:  Make sure it worked. :)
        if ([returnedGtlTask.text caseInsensitiveCompare:@"deleted"] == NSOrderedSame) {
            NSLog(@"Yes confirmed.  Task was deleted.");
        }
        [aTaskDeleteTransaction transactionComplete];
    }];
    

}


- (void) deleteTaskList:(DeleteTransaction *) aTaskListDeleteTransaction {
    if (LOCAL_TESTING_ONLY) {
        NSLog(@"Local testing no Delete TaskList sent");
        return;
    }
    
    // Create an API message to delete a task
    GTLServiceRosetask *service = [self roseTaskService];
    GTLRosetaskTask *aGtlTask = [GTLRosetaskTask alloc];
    [aGtlTask setIdentifier:aTaskListDeleteTransaction.identifier];
    // Rest can be blank.
    
    GTLQueryRosetask *query = [GTLQueryRosetask queryForTasklistDeleteWithIdentifier:[aTaskListDeleteTransaction.identifier longLongValue]];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLRosetaskTaskList *returnedGtlTaskList, NSError *error) {
        NSLog(@"Done!");
        NSLog(@"text = %@", returnedGtlTaskList.title);
        NSLog(@"identifier = %@", returnedGtlTaskList.identifier);
        
        
        // Consider:  Make sure it worked. :)
        if ([returnedGtlTaskList.title caseInsensitiveCompare:@"deleted"] == NSOrderedSame) {
            NSLog(@"Yes confirmed.  Task was deleted.");
        }
        [aTaskListDeleteTransaction transactionComplete];
    }];

}

- (void) syncDeletes {
    if (LOCAL_TESTING_ONLY) {
        NSLog(@"Local testing no Deletes sent");
        return;
    }
    
    // Find all the DeleteTransaction managed objects and send them.
}

- (void) updateAllForTaskUser:(TaskUser *) currentTaskUser {
    if (LOCAL_TESTING_ONLY) {
        NSLog(@"Local testing no Sync all sent");
        return;
    }
    GTLServiceRosetask *service = [self roseTaskService];
    GTLQueryRosetask *query = [GTLQueryRosetask queryForTasklistGettasklists];
    // Note there is another version where you can set limits (current is 20 TaskLists) queryForTasklistInsertWithObject:(GTLRosetaskTaskList *)object;

    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLRosetaskApiMessagesTaskListListResponse *object, NSError *error) {
        NSLog(@"Done with the kitchen sink reply! Num items is %d", [object.items count]);
        for(GTLRosetaskApiMessagesTaskListResponseMessage * taskListMessage in object.items) {
            NSLog(@"Updating/creating the list %@", taskListMessage.title);
            [taskListMessage updateCoreDataForTaskUser: currentTaskUser];
        }
    }];

}

- (void) syncAll{
    if (LOCAL_TESTING_ONLY) {
        NSLog(@"Local testing no Sync all sent");
        return;
    }
    
    // Find all the managed objects with syncNeeded set and send them.
}


@end
