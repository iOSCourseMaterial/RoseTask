//
//  DeleteTransaction.h
//  Rose-Task
//
//  Created by David Fisher on 8/15/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DeleteTransaction : NSManagedObject

@property (nonatomic, retain) NSString * entityType;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * lowercaseEmail;

@end
