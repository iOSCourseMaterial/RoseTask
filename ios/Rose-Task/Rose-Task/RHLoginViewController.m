//
//  RHLoginViewController.m
//  Rose-Task
//
//  Created by David Fisher on 8/10/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHLoginViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTLRosetask.h"
#import "RHTaskListTableViewController.h"
#import "RHAppDelegate.h"

#define SIGN_IN_SECTION_INDEX 0
#define LOCAL_ONLY_EMAIL @"local_only"

@interface RHLoginViewController ()
- (NSManagedObject *) getTaskUserMo:(NSString *) lowercase_email;
@end

@implementation RHLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // TESTING ONLY: Create some fake core data to run once.
    if (NO) {
        
        RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [ad managedObjectContext];
        
        NSManagedObject * taskUserMo1 = [NSEntityDescription insertNewObjectForEntityForName:@"TaskUser" inManagedObjectContext:managedObjectContext];
        [taskUserMo1 setValue:@"test1" forKey:@"lowercase_email"];
        [taskUserMo1 setValue:@"108456725833219286408" forKey:@"google_plus_id"];
        [taskUserMo1 setValue:@"Test1 like Dave" forKey:@"preferred_name"];
        
        NSManagedObject * taskUserMo2 = [NSEntityDescription insertNewObjectForEntityForName:@"TaskUser" inManagedObjectContext:managedObjectContext];
        [taskUserMo2 setValue:@"test2" forKey:@"lowercase_email"];
        
        
        NSManagedObject * taskUserMo3 = [NSEntityDescription insertNewObjectForEntityForName:@"TaskUser" inManagedObjectContext:managedObjectContext];
        [taskUserMo3 setValue:@"test3" forKey:@"lowercase_email"];
        
        NSManagedObject * taskList1 = [NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:managedObjectContext];
        [taskList1 setValue:@"List 1" forKey:@"title"];
        NSSet * taskUserSet = [[NSSet alloc] initWithArray:@[taskUserMo1, taskUserMo2]];
        [taskList1 setValue:taskUserSet forKey:@"task_users"];
        
        NSManagedObject * task1 = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext];
        [task1 setValue:@"Step 1" forKey:@"text"];
        [task1 setValue:taskList1 forKey:@"task_list"];
        NSManagedObject * task2 = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext];
        [task2 setValue:@"Step 2" forKey:@"text"];
        [task2 setValue:taskList1 forKey:@"task_list"];
        NSManagedObject * task3 = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext];
        [task3 setValue:@"Step 3" forKey:@"text"];
        [task3 setValue:taskList1 forKey:@"task_list"];
        
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Error saving fake data");
        } else {
            
            NSLog(@"Success saving fake data");
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Endpoints

static NSString *const kKeychainItemName = @"App Engine APIs: RoseTask";
NSString *kMyClientID = @"692785471170-iphols9ldsfi4596dn12oc617400d7qc.apps.googleusercontent.com"; // pre-assigned by service
NSString *kMyClientSecret = @"T6gvtmpB3ugjZ8j3xCACCcNY"; // pre-assigned by service
NSString *scope = @"https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/plus.me"; // scope for email
bool signedIn = false;

- (IBAction)signInPress:(id)sender {
    [self signin];
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

- (void)signin {
    if (!signedIn) {
        NSLog(@"Signing in");
        GTMOAuth2ViewControllerTouch *viewController;
        viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                    clientID:kMyClientID
                                                                clientSecret:kMyClientSecret
                                                            keychainItemName:kKeychainItemName
                                                                    delegate:self
                                                            finishedSelector:@selector(viewController:finishedWithAuth:error:)];
        
        [self presentViewController:viewController animated:YES completion:nil];
       
    } else {
        NSLog(@"Signed out");
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
        [[self roseTaskService] setAuthorizer:auth];
        auth.authorizationTokenKey = @"id_token";
        
        // TODO: Change the text on the Table View Cell to sign out instead.
//        [self.signInButton setTitle:@"Sign out" forState:UIControlStateNormal];
        
        
        [self dismissViewControllerAnimated:YES completion:^{
            // Determine if this user has a preferred_name set.
            if ([self getTaskUserMo:auth.userEmail] != nil) {
                NSLog(@"Repeat login.  Assume no updates needed. Fire the segway automatically to view the tasks. for %@.", auth.userEmail);
                [self performSegueWithIdentifier:@"PushTaskListsSegue" sender:[self getTaskUserMo:auth.userEmail]];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Set your preferred name", @"Set your preferred name")
                                                                message:@"Usually just your first name"
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
                [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
                [alert show];
            }
        }];
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // The class of the sender will be either UITableViewCell (if not signing in)
    // If they signed in with Google the sender class will be an NSString (ther users email)
    RHTaskListTableViewController *taskListController = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"PushTaskListsSegue"]) {
        if ([sender isKindOfClass:[NSManagedObject class]]) {
            //NSLog(@"Fire TaskListTableViewController for %@", sender);
            taskListController.taskUser = sender;
        }
        else {
            //NSLog(@"Fire TaskListTableViewController for %@", LOCAL_ONLY_EMAIL);
            taskListController.taskUser = [self localOnlyTaskUser];
        }
    }
}

- (NSManagedObject *) localOnlyTaskUser {
    if (_localOnlyTaskUser == nil) {
        // Create TaskUser in core data.
        RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *moc = [ad managedObjectContext];
        _localOnlyTaskUser = [NSEntityDescription insertNewObjectForEntityForName:@"TaskUser"
                                                                     inManagedObjectContext:moc];
        [_localOnlyTaskUser setValue:LOCAL_ONLY_EMAIL forKey:@"lowercase_email"];
        NSError *error = nil;
        if (![moc save:&error]) {
            NSLog(@"MOC error %@", [error localizedDescription]);
        }
    }
    return _localOnlyTaskUser;
}

#pragma mark - Table view data source


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
    NSLog(@"Got a preferred name of %@", preferred_name);
    
    // Create TaskUser in core data.
    GTMOAuth2Authentication * auth = [self.roseTaskService authorizer];
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext]; 
    NSManagedObject * taskUserMo = [NSEntityDescription insertNewObjectForEntityForName:@"TaskUser"
                                                             inManagedObjectContext:moc];
    [taskUserMo setValue:[[auth userEmail] lowercaseString] forKey:@"lowercase_email"];
    [taskUserMo setValue:[auth userID] forKey:@"google_plus_id"];
    [taskUserMo setValue:preferred_name forKey:@"preferred_name"];
    [taskUserMo setValue:[NSNumber numberWithBool:YES] forKey:@"sync_needed"];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error %@", [error localizedDescription]);
    }

    // Sync the TaskUser with GAE
    [self updateTaskUser:preferred_name];
    
    // Display the TaskLists for this user.
    [self performSegueWithIdentifier:@"PushTaskListsSegue" sender:auth.userEmail];
}

- (void) updateTaskUser:(NSString *) preferred_name {
    GTLServiceRosetask *service = [self roseTaskService];
    
    GTLRosetaskTaskUser *taskUser = [GTLRosetaskTaskUser alloc];
    if (preferred_name == nil) {
        // Use the name from Google for now.
    }
    
    [taskUser setPreferredName:preferred_name];
    GTMOAuth2Authentication * auth = [self.roseTaskService authorizer];
    [taskUser setLowercaseEmail:[auth userEmail]];
    [taskUser setGooglePlusId:[auth userID]];
    
    GTLQueryRosetask *query = [GTLQueryRosetask queryForTaskuserInsertWithObject:taskUser];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLRosetaskTaskUser *object, NSError *error) {
        NSLog(@"Done!");
        NSLog(@"Created = %@", object.created);
        NSLog(@"lowercaseEmail = %@", object.lowercaseEmail);
        NSLog(@"preferredName = %@", object.preferredName);
        NSLog(@"googlePlusId = %@", object.googlePlusId);
        
        // Mark the TaskUser as no longer needing a sync.
        RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *moc = [ad managedObjectContext];
        NSManagedObject * taskUser = [self getTaskUserMo:[object.lowercaseEmail lowercaseString]];
        [taskUser setValue:[NSNumber numberWithBool:NO] forKey:@"sync_needed"];
        NSError *mocError = nil;
        if (![moc save:&mocError]) {
            NSLog(@"MOC error %@", [mocError localizedDescription]);
        }

    }];
}

#pragma mark - GAE helpers
+ (NSManagedObject *) getTaskUserMo:(NSString *) lowercase_email {
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"TaskUser"
                                              inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(lowercase_email == %@)", lowercase_email];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if ([array count] > 0) {
        return array[0];
    }
    return nil;
}


@end
