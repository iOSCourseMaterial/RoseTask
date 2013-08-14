//
//  RHLoginViewController.h
//  Rose-Task
//
//  Created by David Fisher on 8/10/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTLServiceRosetask;

@interface RHLoginViewController : UITableViewController <UIAlertViewDelegate>

- (GTLServiceRosetask *)roseTaskService;
@property (nonatomic, strong) NSManagedObject * localOnlyTaskUser;

@end
