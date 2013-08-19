//
//  GTLRosetaskApiMessagesTaskListResponseMessage+Customization.h
//  Rose-Task
//
//  Created by David Fisher on 8/18/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "GTLRosetaskApiMessagesTaskListResponseMessage.h"
@class TaskUser;

@interface GTLRosetaskApiMessagesTaskListResponseMessage (Customization)

-(void) updateCoreDataForTaskUser:(TaskUser *) currentTaskUser;

@end
