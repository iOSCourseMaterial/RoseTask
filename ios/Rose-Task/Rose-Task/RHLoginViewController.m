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

- (IBAction)createTasksPress:(id)sender {
}

- (IBAction)queryPress:(id)sender {
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
        GTMOAuth2ViewControllerTouch *viewController;
        viewController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:scope
                                                                    clientID:kMyClientID
                                                                clientSecret:kMyClientSecret
                                                            keychainItemName:kKeychainItemName
                                                                    delegate:self
                                                            finishedSelector:@selector(viewController:finishedWithAuth:error:)];
        
        [self presentModalViewController:viewController
                                animated:YES];
    } else {
        signedIn = false;
//        [self.signInButton setTitle:@"Sign in" forState:UIControlStateNormal];
    }
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    [self dismissModalViewControllerAnimated:YES];
    
    if (error != nil) {
        // Authentication failed
    } else {
        // Authentication succeeded
        signedIn = true;
        [[self roseTaskService] setAuthorizer:auth];
        auth.authorizationTokenKey = @"id_token";
//        [self.signInButton setTitle:@"Sign out" forState:UIControlStateNormal];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
