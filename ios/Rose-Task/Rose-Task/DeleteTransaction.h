//
//  DeleteTransaction.h
//  Rose-Task
//
//  Created by David Fisher on 8/14/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DeleteTransaction : NSManagedObject

@property (nonatomic, retain) NSString * entity_type;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * lowercase_email;

@end
