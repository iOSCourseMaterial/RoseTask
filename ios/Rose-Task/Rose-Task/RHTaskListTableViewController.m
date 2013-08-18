//
//  RHTaskListTableViewController.m
//  Rose-Task
//
//  Created by David Fisher on 8/8/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHTaskListTableViewController.h"
#import "RHAppDelegate.h"
#import "RHTaskListDetailViewController.h"
#import "RHTaskTableViewController.h"
#import "TaskUser+HelperUtils.h"
#import "TaskList+HelperUtils.h"

@interface RHTaskListTableViewController ()
@property (nonatomic, strong) NSMutableArray * taskLists;
- (void)addTaskList;
@end

@implementation RHTaskListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    // Fetch this user's TaskLists
    self.taskLists = [self.taskUser.sortedTaskLists mutableCopy];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void) refreshData {
    self.taskLists = [self.taskUser.sortedTaskLists mutableCopy];
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
	
    NSUInteger count = [self.taskLists count];
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
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.editing) {
        return [self.taskLists count] + 1;
    } else {
        return [self.taskLists count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TaskListCellIdentifier = @"TaskListCell";
    static NSString *AddTaskListCellIdentifier = @"AddTaskListCell";
    UITableViewCell *cell = nil;
    if (indexPath.row == [self.taskLists count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:AddTaskListCellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:TaskListCellIdentifier forIndexPath:indexPath];
        TaskList * rowTaskList = self.taskLists[indexPath.row];
        cell.textLabel.text = rowTaskList.title;
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskList * selectedTaskList = self.taskLists[indexPath.row];
    [self performSegueWithIdentifier:@"DisplayTasks" sender:selectedTaskList];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    TaskList * selectedTaskList = self.taskLists[indexPath.row];
    [self performSegueWithIdentifier:@"EditTaskListSegue" sender:selectedTaskList];
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// The Add Tag row gets an insertion marker, the others a delete marker.
	if (indexPath.row == [self.taskLists count]) {
		return UITableViewCellEditingStyleInsert;
	}
    return UITableViewCellEditingStyleDelete;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source (CD notification will reload the table data)
        TaskList * deleteTaskList = self.taskLists[indexPath.row];
        [deleteTaskList deleteThenSync:YES];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        [self addTaskList];
    }
}


#pragma mark -

- (void)addTaskList {
    
    // Create a new task list.  Fire the segway manually to open the TaskList editor.
    TaskList * newTaskList = [TaskList createTaskListforTaskUser:self.taskUser];
    [self performSegueWithIdentifier:@"EditTaskListSegue" sender:newTaskList];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditTaskListSegue"]) {
        if ([sender isKindOfClass:[TaskList class]]) {
            // Edit this TaskList (title and team members).
            RHTaskListDetailViewController *detailController = segue.destinationViewController;
            detailController.taskList = sender;
            detailController.taskUser = self.taskUser;
        }
        else {
            NSLog(@"Error launching TaskList editor");
        }
    } else if ([segue.identifier isEqualToString:@"DisplayTasks"]) {
        if ([sender isKindOfClass:[TaskList class]]) {
            RHTaskTableViewController * tasksTableViewController = segue.destinationViewController;
            tasksTableViewController.taskList = sender;
        }
        else {
            NSLog(@"Error displaying Tasks in TaskList");            
        }
    }
}

@end
