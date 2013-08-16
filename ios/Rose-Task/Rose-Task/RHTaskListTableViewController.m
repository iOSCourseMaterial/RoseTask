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

@end

@implementation RHTaskListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    // Fetch this user's TaskLists
    self.taskLists = [self.taskUser.sortedTaskLists mutableCopy];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.taskLists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    TaskList * rowTaskList = self.taskLists[indexPath.row];
    cell.textLabel.text = rowTaskList.title;
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

#pragma mark -

- (IBAction)addTaskList:(id)sender {
    
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
