//
//  RHLoginViewController.m
//  Rose-Task
//
//  Created by David Fisher on 8/10/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHLoginViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "RHTaskListTableViewController.h"
#import "RHAppDelegate.h"
#import "RHEndpointsAdapter.h"
#import "GTLRosetask.h"
#import "TaskUser+HelperUtils.h"
#import "TaskList+HelperUtils.h"
#import "Task+HelperUtils.h"


#define SIGN_IN_SECTION_INDEX 0


@interface RHLoginViewController ()

@end

@implementation RHLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (NO) {
        // Create a local_only Task User if needed.
        TaskUser * theLocalOnlyTaskUser = [TaskUser localOnlyTaskUser];
        TaskUser * test1 = [TaskUser createFromEmail:@"test1"];
        TaskUser * test2 = [TaskUser createFromEmail:@"test2"];
        TaskUser * test3 = [TaskUser createFromEmail:@"test3"];
        TaskUser * test4 = [TaskUser createFromEmail:@"test4"];
        [test1 setPreferredName:@"Test1"];
        [test2 setPreferredName:@"Best2"];
        
        // Create a TaskList for local only
        TaskList * list1 = [TaskList createTaskListforTaskUser:theLocalOnlyTaskUser];
        TaskList * list2 = [TaskList createTaskListforTaskUser:theLocalOnlyTaskUser];
        [list1 setTitle:@"List 1"];
        [list2 setTitle:@"List 2"];
        
        [list1 addTaskUsersObject:theLocalOnlyTaskUser];
        [list1 addTaskUsersObject:test1];
        [list1 addTaskUsersObject:test2];
        [list1 addTaskUsersObject:test3];
        [list1 addTaskUsersObject:test4];
        [list2 addTaskUsersObject:theLocalOnlyTaskUser];
        [list2 addTaskUsersObject:test1];
        [list2 addTaskUsersObject:test4];
        
        // Create Tasks for the lists
        Task * l1s1 = [Task createTaskforTaskList:list1];
        Task * l1s2 = [Task createTaskforTaskList:list1];
        Task * l1s3 = [Task createTaskforTaskList:list1];
        Task * l2s1 = [Task createTaskforTaskList:list2];
        Task * l2s2 = [Task createTaskforTaskList:list2];
        Task * l2s3 = [Task createTaskforTaskList:list2];
        Task * l2s4 = [Task createTaskforTaskList:list2];
        [l1s1 setText:@"List 1 Step 1 assigned"];
        [l1s2 setText:@"List 1 Step 2 assigned"];
        [l1s3 setText:@"List 1 Step 3"];
        [l2s1 setText:@"List 2 Step 1"];
        [l2s2 setText:@"List 2 Step 2"];
        [l2s3 setText:@"List 2 Step 3"];
        [l2s4 setText:@"List 2 Step 4 assigned"];
        
        [l1s1 setAssignedTo:test1];
        [l1s2 setAssignedTo:test2];
        [l2s4 setAssignedTo:test4];
        
        
        // Grab the one and only context (from anywhere) and save all.
        NSManagedObjectContext *moc = [(RHAppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Endpoints OAuth

static NSString *const kKeychainItemName = @"App Engine APIs: RoseTask";
NSString *kMyClientID = @"692785471170-iphols9ldsfi4596dn12oc617400d7qc.apps.googleusercontent.com";
NSString *kMyClientSecret = @"T6gvtmpB3ugjZ8j3xCACCcNY";
NSString *scope = @"https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/plus.me";
bool signedIn = false;

- (IBAction)signInPress:(id)sender {
    [self signin];
}

- (void)signin {
    if (!signedIn) {
        GTMOAuth2ViewControllerTouch *viewController;
        viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                    clientID:kMyClientID
                                                                clientSecret:kMyClientSecret
                                                            keychainItemName:kKeychainItemName
                                                                    delegate:self
                                                            finishedSelector:@selector(viewController:finishedWithAuth:error:)];
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        signedIn = false;
        // TODO: Change the text on the TableVeiwCell to sign in again.
//        [self.signInButton setTitle:@"Sign in" forState:UIControlStateNormal];
        
    }
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        // Authentication succeeded
        signedIn = true;
        [RHEndpointsAdapter.sharedInstance.roseTaskService setAuthorizer:auth];
        auth.authorizationTokenKey = @"id_token";
        
        // TODO: Change the text on the Table View Cell to sign out instead.
//        [self.signInButton setTitle:@"Sign out" forState:UIControlStateNormal];
        
        
        [self dismissViewControllerAnimated:YES completion:^{
            // Determine if this user has a preferred_name set.
            TaskUser * currentTaskUser = [TaskUser taskUserFromEmail:auth.userEmail];
            if (currentTaskUser == nil) {
                // First login for this users ask there for their name.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Set your preferred name", @"Set your preferred name")
                                                                message:@"Usually just your first name"
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
                [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [alert show];
            } else {
                // Repeat login.
                [self performSegueWithIdentifier:@"PushTaskListsSegue" sender:currentTaskUser];
            }
        }];
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // The class of the sender will be either UITableViewCell (if not signing in, local only)
    // If they signed in with Google the sender class will be a TaskUser
    RHTaskListTableViewController *taskListController = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"PushTaskListsSegue"]) {
        if ([sender isKindOfClass:[TaskUser class]]) {
            taskListController.taskUser = sender;
        }
        else {
            taskListController.taskUser = [TaskUser localOnlyTaskUser];
        }
    }
}


#pragma mark - Table view data source

// Currently using static cells (might change when we need more features)

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SIGN_IN_SECTION_INDEX) {
        [self signin];
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // For now there is only one alert view so assume it is the name dialog.
    NSString * preferred_name = [[alertView textFieldAtIndex:0] text];
    
    // Create TaskUser in core data.
    GTMOAuth2Authentication * auth = [[[RHEndpointsAdapter sharedInstance] roseTaskService] authorizer];
    TaskUser * currentTaskUser = [TaskUser createFromEmail:[auth userEmail]];
    currentTaskUser.googlePlusId = [auth userID];
    currentTaskUser.preferredName = preferred_name;
    [currentTaskUser saveThenSync:YES];
    
    // Display the TaskLists for this user.
    [self performSegueWithIdentifier:@"PushTaskListsSegue" sender:currentTaskUser];
}

@end
