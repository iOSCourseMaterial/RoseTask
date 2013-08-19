//
//  TaskUser+HelperUtils.m
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "TaskUser+HelperUtils.h"
#import "RHAppDelegate.h"
#import "TaskList+HelperUtils.h"
#import "RHEndpointsAdapter.h"
#import "GTLRosetaskApiMessagesTaskUserResponseMessage.h"

@implementation TaskUser (HelperUtils)

#pragma mark - Class methods
+ (TaskUser *) taskUserFromEmail:(NSString *) anEmail {
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"TaskUser"
                                              inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(lowercaseEmail == %@)", [anEmail lowercaseString]];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if ([array count] > 0) {
        return array[0]; // There should only ever be one.
    }
    return nil;
}

+ (TaskUser *) createFromEmail:(NSString *) anEmail {
    RHAppDelegate *ad = (RHAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    TaskUser * aTaskUser = (TaskUser *)[NSEntityDescription insertNewObjectForEntityForName:@"TaskUser"
                                                       inManagedObjectContext:moc];
    [aTaskUser setLowercaseEmail:[anEmail lowercaseString]];
    [aTaskUser setCreated:[NSDate date]];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
    }
    return aTaskUser;
}

+ (TaskUser *) taskUserFromMessage:(GTLRosetaskApiMessagesTaskUserResponseMessage *) apiTaskUserMessage withParentTaskList:(TaskList *) parentTaskList{
    // Determine if this TaskUser is already in CD
    TaskUser * aTaskUser = [TaskUser taskUserFromEmail:apiTaskUserMessage.lowercaseEmail];
    if (aTaskUser == nil) {
        // This is a new TaskUser that is NOT within CD.  Let's add it.
        aTaskUser = [TaskUser createFromEmail:apiTaskUserMessage.lowercaseEmail];
    }
    [aTaskUser setPreferredName:apiTaskUserMessage.preferredName];
    [aTaskUser setGooglePlusId:apiTaskUserMessage.googlePlusId];
    [aTaskUser addTaskListsObject:parentTaskList];
    
    if (aTaskUser.image == nil && [aTaskUser.googlePlusId length] > 0) {
        [aTaskUser addImageUsingFetch];
    }
    return aTaskUser;
}


+ (TaskUser *) localOnlyTaskUser {
    static TaskUser * theLocalOnlyTaskUser = nil;
    if (theLocalOnlyTaskUser == nil) {
        theLocalOnlyTaskUser = [TaskUser taskUserFromEmail:LOCAL_ONLY_EMAIL];
        if (theLocalOnlyTaskUser == nil) {
            // Create TaskUser in core data.
            theLocalOnlyTaskUser = [TaskUser createFromEmail:LOCAL_ONLY_EMAIL];
            [theLocalOnlyTaskUser saveThenSync:NO];
        }
    }
    return theLocalOnlyTaskUser;
}

#pragma mark - Instance methods
- (void) saveThenSync:(BOOL) syncNeeded {
    NSManagedObjectContext *moc = self.managedObjectContext;
    self.syncNeeded = [NSNumber numberWithBool:syncNeeded];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
    }
    // Potentially sync with Endpoints.
    if (syncNeeded && ![self.lowercaseEmail isEqualToString:LOCAL_ONLY_EMAIL]) {
        // Save the TaskUser with Endpoints
        NSLog(@"Updating Task User %@ with endpoints.", self.lowercaseEmail);
        [RHEndpointsAdapter.sharedInstance syncTaskUser:self];
    }
}


- (void) deleteThenSync:(BOOL) syncNeeded {
    NSManagedObjectContext *moc = self.managedObjectContext;
    self.syncNeeded = [NSNumber numberWithBool:syncNeeded];
    // Potentially sync with Endpoints.
    if (syncNeeded) {
        NSLog(@"TODO: Create a delete transaction and make it happen");
    }
    [moc deleteObject:self];
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"MOC error in %s - %@", __FUNCTION__, [error localizedDescription]);
    }
}


- (NSArray *)sortedTaskLists
{
    return [self.taskLists.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[(TaskList *) obj1 created] compare:[(TaskList *) obj2 created]];
    }];
}

- (void) addImageUsingFetch {
    if ([self.googlePlusId length] > 0) {
        // Get the image by using the Google+ id.
        NSLog(@"TODO: Figure out how to fetch the image url for Google+ id %@ for now cheat and use a hardcoded image url", self.googlePlusId);
        
//        NSString * plusRequest = [NSString stringWithFormat:@"https://www.googleapis.com/plus/v1/people/%@?fields=displayName%2Cimage&key=AIzaSyAUwqTXAMLGn2pynwuOJYEzZlW1oJuO0Nk", self.googlePlusId];

        // Make a request to Google to get the URL of the image.  Something like this:
//        https://www.googleapis.com/plus/v1/people/106027280718489289045?fields=displayName%2Cimage&key=AIzaSyAUwqTXAMLGn2pynwuOJYEzZlW1oJuO0Nk
        
            NSString * plusRequest = [NSString stringWithFormat:@"https://www.googleapis.com/plus/v1/people/%@?fields=image&key=AIzaSyAUwqTXAMLGn2pynwuOJYEzZlW1oJuO0Nk", self.googlePlusId];
        [self executeRequestUrlString:plusRequest withBlock:^(NSDictionary * jsonData) {
            NSString *imageUrl = [[jsonData valueForKey:@"image"] valueForKey:@"url"];
            NSLog(@"The image url is %@", imageUrl);
            // Use the image url to get an image
            // Sample with Kristy
            //        https://lh3.googleusercontent.com/-jFEun7oX1eI/AAAAAAAAAAI/AAAAAAAAAAA/yDmoCwnh_ew/photo.jpg?sz=50
            
            // Obviously we'll need to get the URL from the Google+ API request.
//            NSString * testUrl = @"https://lh3.googleusercontent.com/-jFEun7oX1eI/AAAAAAAAAAI/AAAAAAAAAAA/yDmoCwnh_ew/photo.jpg?sz=50";
//            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:testUrl]]];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
            
            // Save that image into Core Data
            NSData *imageData = UIImagePNGRepresentation(image);
            [self setImage:imageData];
            
            // TODO: Put this back.
            //        [self saveThenSync:NO];
        }];
    }
}

- (void)executeRequestUrlString:(NSString *)urlString withBlock:(void (^)(NSDictionary *jsonData))block {
    // Prepare for the call

    NSURLRequest * requestForImageUrl = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    // Make the call
    [NSURLConnection sendAsynchronousRequest:requestForImageUrl
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSError *error1;
                               NSMutableDictionary * innerJson = [NSJSONSerialization
                                                                  JSONObjectWithData:data options:kNilOptions error:&error1
                                                                  ];
                               if (error == nil) {
                                   NSLog(@"Error is nil.  NOW you can do the callback.");
                                   block(innerJson); // Call back the block passed into your method
                               } else {
                                   NSLog(@"Error with fetch %@.", urlString);
                               }
                           }];
}

- (UIImage *) googlePlusImage {
    if (self.image == nil) {
        return nil;
    }
    return [UIImage imageWithData:self.image];
}

@end
