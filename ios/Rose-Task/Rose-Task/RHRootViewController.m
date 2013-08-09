//
//  RHRootViewController.m
//  Rose-Task
//
//  Created by David Fisher on 8/9/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHRootViewController.h"

#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMHTTPFetcherLogging.h"
#import "GTLRosetask.h"

@interface RHRootViewController ()

@end

@implementation RHRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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

- (IBAction)createMePress:(id)sender {
    
    GTLServiceRosetask *service = [self roseTaskService];
    
    GTLRosetaskTaskUser *taskUser = [GTLRosetaskTaskUser alloc];
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
        [self.signInButton setTitle:@"Sign in" forState:UIControlStateNormal];
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
        [self.signInButton setTitle:@"Sign out" forState:UIControlStateNormal];
        //        [self queryScores];
    }
}

@end
