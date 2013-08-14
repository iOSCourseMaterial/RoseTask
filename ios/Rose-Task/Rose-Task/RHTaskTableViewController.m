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

@interface RHTaskTableViewController ()
@property (nonatomic, strong) NSMutableArray * tasks;
@end

@implementation RHTaskTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tasks = [self.taskList.sortedTasks mutableCopy];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Task * rowTask = (Task *) self.tasks[indexPath.row];
    cell.textLabel.text = rowTask.text;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task * selectedTask = (Task *) self.tasks[indexPath.row];
    [self performSegueWithIdentifier:@"TaskDetail" sender:selectedTask];
}

#pragma mark -

- (IBAction)addTask:(id)sender {
    
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
            NSLog(@"Editor for task %@", [sender valueForKey:@"text"]);
        }
        else {
            NSLog(@"Error launching Task editor");
        }
    }
}

@end
