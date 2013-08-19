//
//  RHTaskTableViewController.m
//  Rose-Task
//
//  Created by David Fisher on 8/8/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHTaskTableViewController.h"
#import "TaskList+HelperUtils.h"
#import "TaskUser+HelperUtils.h"
#import "Task+HelperUtils.h"
#import "RHTaskDetailViewController.h"
#import "RHEndpointsAdapter.h"

@interface RHTaskTableViewController ()
@property (nonatomic, strong) NSMutableArray * tasks;
- (void)addTask;
@end

@implementation RHTaskTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tasks = [self.taskList.sortedTasks mutableCopy];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}

- (void) refreshData {
    self.tasks = [self.taskList.sortedTasks mutableCopy];
    [super refreshData];
    
    // TODO: Make sure this task list is fresh with Endpoints.
}


#pragma mark - UITableViewController override
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
	
	// Don't show the Back button while editing.
	[self.navigationItem setHidesBackButton:editing animated:YES];
	[self.tableView beginUpdates];
	
    NSUInteger count = [self.tasks count];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Return the number of tags in the array, adding one if editing (for the Add Tag row).
	if (self.editing) {
		return [self.tasks count] + 1;
	}
    return [self.tasks count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TaskCellIdentifier = @"TaskCell";
    static NSString *AddNewTaskCellIdentifier = @"AddNewTaskCell";
    UITableViewCell *cell = nil;
    if (indexPath.row == [self.tasks count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:AddNewTaskCellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:TaskCellIdentifier forIndexPath:indexPath];
        Task * rowTask = (Task *) self.tasks[indexPath.row];
        cell.textLabel.text = rowTask.text;
        if ([rowTask.complete isEqualToNumber:@YES]) {
            [cell.textLabel setTextColor:[UIColor colorWithRed:0 green:0.6 blue:0 alpha:1.0]];
        } else {
            [cell.textLabel setTextColor:[UIColor colorWithRed:0.4 green:0.2 blue:0.2 alpha:1.0]];
        }
    }
    return cell;

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task * selectedTask = (Task *) self.tasks[indexPath.row];
    [self performSegueWithIdentifier:@"TaskDetail" sender:selectedTask];
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// The Add Tag row gets an insertion marker, the others a delete marker.
	if (indexPath.row == [self.tasks count]) {
		return UITableViewCellEditingStyleInsert;
	}
    return UITableViewCellEditingStyleDelete;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source (CD notification will reload the table data)
        Task * deleteTask = self.tasks[indexPath.row];
        [deleteTask deleteThenSync:YES]; // Note that is delete will trigger a reload.
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        [self addTask];
    }    
}

#pragma mark -

- (void)addTask {
    
    // Create a new Task for the TaskList.  Fire the segway manually to open the Task editor.
    Task * newTask = [Task createTaskforTaskList:self.taskList];
    [self performSegueWithIdentifier:@"TaskDetail" sender:newTask];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"TaskDetail"]) {
        if ([sender isKindOfClass:[Task class]]) {
            // Edit this Task
            RHTaskDetailViewController *detailController = segue.destinationViewController;
            detailController.task = sender;
        }
        else {
            NSLog(@"Error launching Task editor");
        }
    }
}

@end
