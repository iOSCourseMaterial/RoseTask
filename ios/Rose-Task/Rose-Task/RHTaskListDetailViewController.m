//
//  RHTaskListDetailViewController.m
//  Rose-Task
//
//  Created by David Fisher on 8/12/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHTaskListDetailViewController.h"
#import "TaskList+HelperUtils.h"
#import "TaskUser+HelperUtils.h"

@interface RHTaskListDetailViewController ()

@end

@implementation RHTaskListDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.titleTextField.text = self.taskList.title;
    self.taskListTaskUsers = [self.taskList.sortedTaskUsers mutableCopy];
}


- (IBAction)deleteTaskList:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Delete %@", [self.taskList valueForKey:@"title"]]
                                                    message:@"Are you sure?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    [alert show];
}

- (IBAction)textEditingDone:(id)sender {
    [sender resignFirstResponder];
}
#pragma mark - UITextField delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (IBAction)save:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    // Save the changes to the title and jump back to the list of task lists.
    [self.taskList setTitle:self.titleTextField.text];
    
    // Consider: Put the check for the local_only user here instead.
    if ([self.taskUser.lowercase_email isEqualToString:LOCAL_ONLY_EMAIL]) {
        [self.taskList saveThenSync:NO];
    } else {
        [self.taskList saveThenSync:YES];
    }
}

- (IBAction)editTaskListTaskUsers:(id)sender {
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.taskList valueForKey:@"task_users"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TaskUserCellIdentifier = @"TaskUserCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:TaskUserCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:TaskUserCellIdentifier];
    }
    // TODO: Sort the users only once. :)
    NSSet * taskUsers = [self.taskList valueForKey:@"task_users"];
    NSArray * sortedTaskUsers = [taskUsers.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[obj1 valueForKey:@"created"] compare:[obj2 valueForKey:@"created"]];
    }];

    //NSManagedObject * aTaskUser = [taskUsers anyObject];
    NSManagedObject * aTaskUser = sortedTaskUsers[indexPath.row];
    
    // Display each user in this list.
    NSString * displayName = [aTaskUser valueForKey:@"lowercase_email"];
    if ([aTaskUser valueForKey:@"preferred_name"] != nil) {
        cell.detailTextLabel.text = displayName;
        displayName = [aTaskUser valueForKey:@"preferred_name"];
        // TODO: Set the image
    }
    cell.textLabel.text = displayName;
    return cell;
}


- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
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

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Team members";
}



@end
