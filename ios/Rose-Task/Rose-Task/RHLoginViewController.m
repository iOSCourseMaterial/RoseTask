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
#define LOCAL_ONLY_ID @"local_only"

@interface RHLoginViewController ()

@end

@implementation RHLoginViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    // TODO: Create some data to run once.
    if (NO) {
        
        RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [ad managedObjectContext];
        
        NSManagedObject * taskUserMo1 = [NSEntityDescription insertNewObjectForEntityForName:@"TaskUser" inManagedObjectContext:managedObjectContext];
        [taskUserMo1 setValue:@"test3b" forKey:@"lowercase_email"];
        [taskUserMo1 setValue:@"108456725833219286408" forKey:@"google_plus_id"];
        [taskUserMo1 setValue:@"Dave" forKey:@"preferred_name"];
        
        NSManagedObject * taskUserMo2 = [NSEntityDescription insertNewObjectForEntityForName:@"TaskUser" inManagedObjectContext:managedObjectContext];
        [taskUserMo2 setValue:@"test4b" forKey:@"lowercase_email"];
        
        
        NSManagedObject * taskUserMo3 = [NSEntityDescription insertNewObjectForEntityForName:@"TaskUser" inManagedObjectContext:managedObjectContext];
        [taskUserMo3 setValue:@"test5b" forKey:@"lowercase_email"];
        
        NSManagedObject * taskList1 = [NSEntityDescription insertNewObjectForEntityForName:@"TaskList" inManagedObjectContext:managedObjectContext];
        [taskList1 setValue:@"List 2b" forKey:@"title"];
        NSSet * taskUserSet = [[NSSet alloc] initWithArray:@[taskUserMo1, taskUserMo2]];
        [taskList1 setValue:taskUserSet forKey:@"task_users"];
        
        NSManagedObject * task1 = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext];
        [task1 setValue:@"Step 1b" forKey:@"text"];
        [task1 setValue:taskList1 forKey:@"task_list"];
        NSManagedObject * task2 = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext];
        [task2 setValue:@"Step 2b" forKey:@"text"];
        [task2 setValue:taskList1 forKey:@"task_list"];
        NSManagedObject * task3 = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext];
        [task3 setValue:@"Step 3b" forKey:@"text"];
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

- (void) updateMyTaskUser:(NSString *) preferred_name {
    GTLServiceRosetask *service = [self roseTaskService];
    
    GTLRosetaskTaskUser *taskUser = [GTLRosetaskTaskUser alloc];
    if (preferred_name == nil) {
        // Use the name from Google for now.
    }
    [taskUser setLowercaseEmail:@"fisherds@gmail.com"];
    [taskUser setPreferredName:@"iOS Dave"];
    [taskUser setGooglePlusId:@"108456725833219286408"];
    
    GTLQueryRosetask *query = [GTLQueryRosetask queryForTaskuserInsertWithObject:taskUser];
    
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, GTLRosetaskTaskUser *object, NSError *error) {
        NSLog(@"Done!");
        NSLog(@"Created = %@", object.created);
        NSLog(@"lowercaseEmail = %@", object.lowercaseEmail);
        NSLog(@"preferredName = %@", object.preferredName);
        NSLog(@"googlePlusId = %@", object.googlePlusId);
    }];
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
            NSLog(@"Fire the segway automatically to view the tasks. for this user.");
            
            NSLog(@"userData = %@", auth.userData);
            NSLog(@"userID = %@", auth.userID);
            
            
            [self performSegueWithIdentifier:@"PushTaskListsSegue" sender:auth.userEmail];
            
        }];
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // The class of the sender will be either UITableViewCell (if not signing in)
    // If they signed in with Google the sender class will be an NSString (ther users email)
    RHTaskListTableViewController *taskListController = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"PushTaskListsSegue"]) {
        if ([sender isKindOfClass:[NSString class]]) {
            NSLog(@"Fire TaskListTableViewController for %@", sender);
            taskListController.userEmail = sender;
        }
        else {
            NSLog(@"sender = %@", sender);
            NSLog(@"sender class = %@", [sender class]);
            NSLog(@"Fire TaskListTableViewController for LocalOnly");
            taskListController.userEmail = LOCAL_ONLY_ID;
        }
    }
}


#pragma mark - Table view data source


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SIGN_IN_SECTION_INDEX) {
        [self signin];
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
