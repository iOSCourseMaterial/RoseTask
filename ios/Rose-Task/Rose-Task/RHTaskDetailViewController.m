//
//  RHTaskDetailViewController.m
//  Rose-Task
//
//  Created by David Fisher on 8/11/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHTaskDetailViewController.h"
#import "Task+HelperUtils.h"
#import "TaskUser+HelperUtils.h"
#import "RHAssignTaskController.h"
#import "RHTaskUserCell.h"

@interface RHTaskDetailViewController () {
    BOOL _saveWasPressed;
}
@property (nonatomic, strong) NSNumber * tempIsComplete;
@property (nonatomic) TaskUser * originalAssignedTo;

@end

@implementation RHTaskDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textTextField.text = self.task.text;
    self.detailsTextView.text = @"Details will go here";
    self.tempIsComplete = self.task.complete;
    self.originalAssignedTo = self.task.assignedTo;
    _saveWasPressed = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    if ([self.task.text length] < 1) {
        [self.textTextField becomeFirstResponder];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    if (!_saveWasPressed) {
        self.task.assignedTo = self.originalAssignedTo;
    }
}


#pragma mark - Table view data source
// Static cells from storyboard

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.section) {
        case 0:
            // Text is the only row
            break;
        case 1:
            if (indexPath.row == 0) {
                // Row 0 is the assigned to
                [(RHTaskUserCell *) cell setTaskUser:self.task.assignedTo];
            } else {
                // Row 1 is the completed row
                if ([self.tempIsComplete isEqualToNumber:@YES]) {
                    cell.detailTextLabel.text = @"Yes";
                    [cell.detailTextLabel setTextColor:[UIColor colorWithRed:0 green:0.6 blue:0 alpha:1.0]];
                } else {
                    cell.detailTextLabel.text = @"No";
                    [cell.detailTextLabel setTextColor:[UIColor colorWithRed:0.6 green:0 blue:0 alpha:1.0]];
                }
            }
            break;
        case 2:
            // Row 0 is the details
        default:
            break;
    }
    return cell;
}


- (IBAction)save:(id)sender {
    _saveWasPressed = YES;
    self.task.text = self.textTextField.text;
    self.task.details = self.detailsTextView.text;
    self.task.complete = self.tempIsComplete;
    [self.task saveThenSync:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section) {
        case 0:
            // Text is the only row
            NSLog(@"Do nothing on text press");
            break;
        case 1:
            if (indexPath.row == 0) {
                // Row 0 is the assigned to
                NSLog(@"Launch the assign to screen.  All users in this TaskList displayed.");
                [self performSegueWithIdentifier:@"AssignTaskSegue" sender:self.task];
                
            } else {
                // Row 1 is the completed row
                NSLog(@"Change the complete status");
                if ([self.tempIsComplete isEqualToNumber:@YES]) {
                    self.tempIsComplete = @NO;
                } else {
                    self.tempIsComplete = @YES;
                }
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        case 2:
            // Row 0 is the details
            NSLog(@"Do nothing on details press");
        default:
            break;
    }

}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AssignTaskSegue"]) {
        if ([sender isKindOfClass:[Task class]]) {
            RHAssignTaskController * destination = segue.destinationViewController;
            destination.task = self.task;
            NSLog(@"Sent the task %@", self.task.text);
        }
    }
}


#pragma mark - UITextField delegate

- (IBAction)textEditingDone:(id)sender {
    [sender resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

@end
