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

@interface RHTaskDetailViewController ()

@end

@implementation RHTaskDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textTextField.text = self.task.text;
    self.detailsTextView.text = @"Details will go here";

}

#pragma mark - Table view data source
// Static cells from storyboard

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            // Text is the only row
            break;
        case 1:
            if (indexPath.row == 0) {
                // Row 0 is the assigned to
                TaskUser * assignToTaskUser = (TaskUser *) self.task.assignedTo;
                cell.textLabel.text = assignToTaskUser.lowercaseEmail;
            } else {
                // Row 1 is the completed row
                if (self.task.complete) {
                    cell.detailTextLabel.text = @"Yes";
                    // TODO: make the color green.
                } else {
                    cell.detailTextLabel.text = @"No";
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
    NSLog(@"You'd like to save.  Good for you");
}

- (IBAction)deleteTask:(id)sender {
    NSLog(@"You'd like to delete this Task");
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
            } else {
                // Row 1 is the completed row
                NSLog(@"Change the complete status");
            }
            break;
        case 2:
            // Row 0 is the details
            NSLog(@"Do nothing on details press");
        default:
            break;
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
