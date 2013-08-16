//
//  RHAssignTaskController.m
//  Rose-Task
//
//  Created by David Fisher on 8/15/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHAssignTaskController.h"
#import "TaskList+HelperUtils.h"
#import "TaskUser+HelperUtils.h"
#import "Task+HelperUtils.h"
#import "RHTaskUserCell.h"

@interface RHAssignTaskController ()
@property (nonatomic, strong) NSArray * taskUsers;
@end

@implementation RHAssignTaskController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.taskUsers = self.task.taskList.sortedTaskUsers;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.taskUsers count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskUserCell";
    RHTaskUserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.row < [self.taskUsers count]) {
        cell.taskUser = self.taskUsers[indexPath.row];
        if (self.task.assignedTo != nil &&
            [self.task.assignedTo.lowercaseEmail length] > 0 &&
            [self.task.assignedTo.lowercaseEmail isEqualToString:[self.taskUsers[indexPath.row] lowercaseEmail]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        // This is the None row.
        cell.textLabel.text = @"None";
        cell.detailTextLabel.text = @"";
        if (self.task.assignedTo == nil) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.taskUsers count]) {
        self.task.assignedTo = self.taskUsers[indexPath.row];
    } else {
        self.task.assignedTo = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
