//
//  RHMocDidChangeTableViewController.m
//  Rose-Task
//
//  Created by David Fisher on 8/16/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHMocDidChangeTableViewController.h"

@interface RHMocDidChangeTableViewController ()

@end

@implementation RHMocDidChangeTableViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mocChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:nil];
}

- (void)mocChange:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:nil];
    
    // Do stuff.
    //    NSDictionary *userInfoDictionary = [notification userInfo];
    //    NSSet *insertedObjects = [userInfoDictionary objectForKey:NSInsertedObjectsKey];
    //    NSSet *deletedObjects = [userInfoDictionary objectForKey:NSDeletedObjectsKey];
    //    NSSet *updatedObjects = [userInfoDictionary objectForKey:NSUpdatedObjectsKey];
    
    // Easier just to do a full reload of the table on the page than look at the specifics.
    [self refreshData];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mocChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:nil];
}

- (void) refreshData {
    // Do work in the subclass BEFORE calling super.
    NSLog(@"Reloading table data %s", __FUNCTION__);
    [self.tableView reloadData];
    // Note if the refreshData function is called from a background thread you'll need to do this...
    //    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

@end
