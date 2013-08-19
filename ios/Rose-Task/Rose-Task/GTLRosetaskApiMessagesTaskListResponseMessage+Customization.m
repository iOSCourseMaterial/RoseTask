//
//  GTLRosetaskApiMessagesTaskListResponseMessage+Customization.m
//  Rose-Task
//
//  Created by David Fisher on 8/18/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "GTLRosetaskApiMessagesTaskListResponseMessage+Customization.h"
#import "GTLRosetask.h"
#import "TaskList+HelperUtils.h"
#import "TaskUser+HelperUtils.h"
#import "Task+HelperUtils.h"

@implementation GTLRosetaskApiMessagesTaskListResponseMessage (Customization)

-(void) updateCoreDataForTaskUser:(TaskUser *) currentTaskUser {
    // Determine if this TaskList is already in CD
    TaskList * aTaskList = [TaskList taskListFromId:self.identifierProperty];
    if (aTaskList == nil) {
        // This is a new TaskList that is NOT within CD.  Let's add it.
        aTaskList = [TaskList createTaskListforTaskUser:currentTaskUser];
    } else {
        // This TaskList already exist.  Update the values.
        [aTaskList setTaskUsers:[[NSSet alloc] init]]; // Clears the users of this list.
        [aTaskList setTasks:[[NSSet alloc] init]]; // Clears the tasks of this list.
    }
    [aTaskList setSyncNeeded:@NO];
    [aTaskList setTitle:self.title];
    
    NSLog(@"List with title %@, has %d users", aTaskList.title, [aTaskList.taskUsers count]);
    for (GTLRosetaskApiMessagesTaskUserResponseMessage * gtlMessageTaskUser in aTaskList.taskUsers) {
        TaskUser * aTaskUser = [TaskUser taskUserFromMessage:gtlMessageTaskUser withParentTaskList:aTaskList];
        
        NSLog(@"Updating/creating the user email %@", aTaskUser.lowercaseEmail);
        [aTaskList addTaskUsersObject:aTaskUser];
    }
    NSLog(@"List with title %@, has %d tasks", aTaskList.title, [aTaskList.tasks count]);
    for (GTLRosetaskApiMessagesTaskResponseMessage * gtlMessageTask in aTaskList.tasks) {
        Task * aTask = [Task taskUserFromMessage:gtlMessageTask withParentTaskList:aTaskList];
        NSLog(@"Updating/creating the taskl %@", aTask.text);
        [aTaskList addTasksObject:aTask];
    }
}

@end
