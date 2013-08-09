//
//  RHRootViewController.h
//  Rose-Task
//
//  Created by David Fisher on 8/9/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTLServiceRosetask;


@interface RHRootViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
- (IBAction)signInPress:(id)sender;
- (IBAction)createMePress:(id)sender;
- (IBAction)createTasksPress:(id)sender;
- (IBAction)queryPress:(id)sender;

- (GTLServiceRosetask *)roseTaskService;


@end
