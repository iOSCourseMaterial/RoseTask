//
//  RHTaskListDetailViewController.m
//  Rose-Task
//
//  Created by David Fisher on 8/12/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHTaskListDetailTableViewController.h"

#import "RHTaskListTitleCell.h"


@interface RHTaskListDetailTableViewController ()
@property (strong, nonatomic) UIBarButtonItem *saveButton;
- (void) save;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *cancelButton;
- (void) cancel;
@end

@implementation RHTaskListDetailTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                    target:self
                                                                    action:@selector(save)];
    self.backButton = self.navigationItem.leftBarButtonItem;
    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                      target:self
                                                                      action:@selector(cancel)];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    self.navigationItem.rightBarButtonItem = (editing) ? self.saveButton : self.editButtonItem;
    self.navigationItem.leftBarButtonItem = (editing) ? self.cancelButton : self.backButton;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch( section) {
        case 0:
        case 2:
            return 1;
        case 1:
            // Otherwise this is the emails section.
            return [[self.taskList valueForKey:@"task_users"] count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TitleCellIdentifier = @"TaskListTitleCell";
    static NSString *TaskUserCellIdentifier = @"TaskUser";
    static NSString *DeleteTaskListCellIdentifier = @"DeleteTaskList";
    UITableViewCell *cell = nil;
    switch( indexPath.section) {
        case 0:
            // Just make a new cell for the title and don't bother with reuse (it was confusing me).
            cell = [[RHTaskListTitleCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:TitleCellIdentifier];
            [(RHTaskListTitleCell *)cell setValue:[self.taskList valueForKey:@"title"]];            break;
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:TaskUserCellIdentifier forIndexPath:indexPath];
            NSArray * taskUsers = [self.taskList valueForKey:@"task_users"];
            NSManagedObject * aTaskUser = taskUsers[0];
            
            // Display each user in this list.
            NSString * displayName = [aTaskUser valueForKey:@"lowercase_email"];
            if ([aTaskUser valueForKey:@"preferred_name"] != nil) {
                cell.detailTextLabel.text = displayName;
                displayName = [aTaskUser valueForKey:@"preferred_name"];
                // TODO: Set the image
            }
            cell.textLabel.text = displayName;
        
            break;
        }
        case 2:
        {
            // Delete button in all red.
            cell = [tableView dequeueReusableCellWithIdentifier:DeleteTaskListCellIdentifier forIndexPath:indexPath];
            break;
        }
    }
    return cell;
}


- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
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
    if (indexPath.section == 2) {
        // Delete button
        // Ask to make sure first.
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Delete %@", [self.taskList valueForKey:@"title"]]
                                                        message:@"Are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Delete", nil];
        [alert show];

        
    }
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Title:", @"Title:");
            break;
        case 1:
            sectionName = NSLocalizedString(@"Users", @"Users");
            break;
        default:
            sectionName = @"------------";
            break;
    }
    return sectionName;
}

#pragma mark - (Private) Instance methods
- (void) save {
    [self setEditing:NO
            animated:YES];
    
    // Update the title only for now.
    for (UITableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell isKindOfClass:[RHTaskListTitleCell class]]) {
            [self.taskList setValue:[(RHTaskListTitleCell *)cell value] forKey:@"title"];
            NSLog(@"Title updated to %@", [(RHTaskListTitleCell *)cell value] );
        }
    }
    
    NSError * error;
    if (![self.taskList.managedObjectContext save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
    
    [self.tableView reloadData];
}

- (void) cancel {
    [self setEditing:NO
            animated:YES];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Delete"])
    {
        NSLog(@"TODO actually delete this list and return");
        
        // TODO: Delete this TaskList from Core Data and from GAE too.
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
