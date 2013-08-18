//
//  RHSelectTaskListTaskUsersViewController.m
//  Rose-Task
//
//  Created by David Fisher on 8/16/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHSelectTaskListTaskUsersViewController.h"
#import "RHTaskUserCell.h"
#import "RHAppDelegate.h"
#import "TaskUser+HelperUtils.h"
#import "TaskList+HelperUtils.h"

#define kAddNewEmailCell @"AddNewEmailCell"


@interface RHSelectTaskListTaskUsersViewController ()
@property (nonatomic, strong, readonly) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, strong) NSMutableArray * emailsInTaskList;
@end

@implementation RHSelectTaskListTaskUsersViewController
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // Helper to determine which emails get a checkmark to start with.
    self.emailsInTaskList = [self.taskList.sortedTaskUserEmails mutableCopy];

    // Fetch any existing entities
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"FetchedResultsController error %s - %@", __FUNCTION__, [error localizedDescription]);
    }
}

- (NSFetchedResultsController *) fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest * fr = [[NSFetchRequest alloc] init];
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    NSEntityDescription *entityClass = [NSEntityDescription entityForName:@"TaskUser"
                                                   inManagedObjectContext:moc];
    [fr setEntity:entityClass];
    [fr setFetchBatchSize:20];
    
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"preferredName" ascending:NO];
    NSSortDescriptor *emailSort = [[NSSortDescriptor alloc] initWithKey:@"lowercaseEmail" ascending:YES];
    NSArray * sortArray = @[nameSort, emailSort];
    [fr setSortDescriptors:sortArray];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fr
                                                                    managedObjectContext:moc
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

#pragma mark -
#pragma NSFetchResults delegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

// Won't actually happen.
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}

// Boilerplate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

// Boilerplate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - UITableViewController override
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
	
	// Don't show the Back button while editing.
	[self.navigationItem setHidesBackButton:editing animated:YES];
	
	[self.tableView beginUpdates];
	
    
    id<NSFetchedResultsSectionInfo>sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSUInteger count = [sectionInfo numberOfObjects];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:0];
    
	// Add or remove the Add row as appropriate.
    UITableViewRowAnimation animationStyle = UITableViewRowAnimationNone;
    if (animated) {
        animationStyle = UITableViewRowAnimationAutomatic;
    }
    
	if (editing) {
		[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animationStyle];
	}
	else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animationStyle];
    }
    
    [self.tableView endUpdates];
	
	// If editing is finished, save the managed object context.	
	if (!editing) {
        [self.tableView reloadData]; // Update the checkmarks.
        // Wait for the Save button press (not that it'll help :) )  It will get saved once in MOC.
//        [self.taskList saveThenSync:YES];
	}
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo>sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    if (self.editing) {
        return [sectionInfo numberOfObjects] + 1;
    } else {
        return [sectionInfo numberOfObjects];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TaskUserCellIdentifier = @"TaskUserCell";
    static NSString *AddNewEmailCellIdentifier = @"AddNewEmailCell";
    UITableViewCell *cell = nil;
    id<NSFetchedResultsSectionInfo>sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    if (indexPath.row == [sectionInfo numberOfObjects]) {
        cell = [tableView dequeueReusableCellWithIdentifier:AddNewEmailCellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:TaskUserCellIdentifier forIndexPath:indexPath];
        
        TaskUser * rowTaskUser = (TaskUser *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [(RHTaskUserCell *) cell setTaskUser:rowTaskUser];
        
        if ([self.emailsInTaskList containsObject:rowTaskUser.lowercaseEmail]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }

    }    
    return cell;
}


// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    id<NSFetchedResultsSectionInfo>sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
//    if (self.editing && indexPath.row == [sectionInfo numberOfObjects]) {
//        return YES;
//    }
//    TaskUser * rowTaskUser = (TaskUser *)[self.fetchedResultsController objectAtIndexPath:indexPath];
//    if ([rowTaskUser.taskLists count] == 0) {
//        // A way to delete typo email addresses.
//        return YES;
//    }
//    return NO;
//}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Return NO if you do not want the specified item to be editable.
    id<NSFetchedResultsSectionInfo>sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    if (self.editing && indexPath.row == [sectionInfo numberOfObjects]) {
        return UITableViewCellEditingStyleInsert;
    }
    TaskUser * rowTaskUser = (TaskUser *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([rowTaskUser.taskLists count] == 0) {
        // A way to delete typo email addresses.
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }
    
    NSManagedObjectContext *managedObjectContext=[self.fetchedResultsController managedObjectContext];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
        }
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add user"
                                                        message:@"Enter user's email address"
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
    }

}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Check team members";
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskUser * rowTaskUser = (TaskUser *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([self.emailsInTaskList containsObject:rowTaskUser.lowercaseEmail]) {
        // Remove the user at this row.
        [self.taskList removeTaskUsersObject:rowTaskUser];
        [self.emailsInTaskList removeObject:rowTaskUser.lowercaseEmail];
    } else {
        // Add the user at this row.
        [self.taskList addTaskUsersObject:rowTaskUser];
        [self.emailsInTaskList addObject:rowTaskUser.lowercaseEmail];
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // For now there is only one alert view so assume it is the name dialog.
    NSString * addEmail = [[alertView textFieldAtIndex:0] text];
    TaskUser * newTaskUser = [TaskUser createFromEmail:addEmail];
    [self.taskList addTaskUsersObject:newTaskUser];
    [self.emailsInTaskList addObject:addEmail];
    // Save now?
    [self.tableView reloadData];
}


@end
