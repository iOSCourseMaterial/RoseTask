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
#import "RHTaskUserCell.h"
#import "RHSelectTaskListTaskUsersViewController.h"

#define kSelectTaskListTaskUsersSegue @"SelectTaskListTaskUsersSegue"

@interface RHTaskListDetailViewController ()
@property (nonatomic, strong) NSMutableArray * taskListTaskUsers;
@property (weak, nonatomic) UITextField *titleTextField;
@end

@implementation RHTaskListDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.titleTextField.text = self.taskList.title;
    self.taskListTaskUsers = [self.taskList.sortedTaskUsers mutableCopy];
    [self.tableView reloadData];
}

- (IBAction)deleteTaskList:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Delete %@", [self.taskList valueForKey:@"title"]]
                                                    message:@"Are you sure?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    [alert show];
}


#pragma mark - UITextField delegate
- (IBAction)textEditingDone:(id)sender {
    [sender resignFirstResponder];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (IBAction)save:(id)sender {
    // Save the changes to the title and jump back to the list of task lists.
    [self.taskList setTitle:self.titleTextField.text];
    
    // Consider: Put the check for the local_only user here instead.
    if ([self.taskUser.lowercaseEmail isEqualToString:LOCAL_ONLY_EMAIL]) {
        [self.taskList saveThenSync:NO];
    } else {
        [self.taskList saveThenSync:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editTaskListTaskUsers:(id)sender {
    [self performSegueWithIdentifier:kSelectTaskListTaskUsersSegue sender:self.taskList];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            // Title text field.
            return 1;
        case 1:
            return [self.taskList.sortedTaskUsers count];
        default:
            NSLog(@"Error in %s", __FUNCTION__);
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // TODO: Refactor this whole controller.  It is way out of date.  Managed Objects really?
    
    
    static NSString *TaskUserCellIdentifier = @"TaskUserCell";
    static NSString *TaskListTitleCellIdentifier = @"TaskListTitleCell";
    UITableViewCell * cell = nil;
    switch (indexPath.section) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:TaskListTitleCellIdentifier forIndexPath:indexPath];
            // TODO: Figure out how to get the content view to set the text field ... hum...
            NSArray * childViews = cell.contentView.subviews;
            NSLog(@"There are %d child views of the content view", [childViews count]);
            NSLog(@"The view at index 0 is of class %@.", [childViews[0] class]);
            self.titleTextField = childViews[0];
            self.titleTextField.text = self.taskList.title;
        }
            break;
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:TaskUserCellIdentifier forIndexPath:indexPath];
            [(RHTaskUserCell *) cell setTaskUser:self.taskList.sortedTaskUsers[indexPath.row]];
        }
            break;
        default:
        {
            NSLog(@"Error in %s", __FUNCTION__);
            return nil;
        }
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Pressing any user fires the selection tool.
    if (indexPath.section == 1) {
        [self performSegueWithIdentifier:kSelectTaskListTaskUsersSegue sender:self.taskList];
    }

}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Title";
    } else {
        return @"Team members";
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSelectTaskListTaskUsersSegue]) {
        if ([sender isKindOfClass:[TaskList class]]) {
            RHSelectTaskListTaskUsersViewController * destination = segue.destinationViewController;
            destination.taskList = self.taskList;
        }
    }
}

@end
