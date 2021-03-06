/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2013 Google Inc.
 */

//
//  GTLRosetaskApiMessagesTaskResponseMessage.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   rosetask/v1
// Description:
//   Rose Task API
// Classes:
//   GTLRosetaskApiMessagesTaskResponseMessage (0 custom class methods, 5 custom properties)

#import "GTLRosetaskApiMessagesTaskResponseMessage.h"

#import "GTLRosetaskApiMessagesTaskUserResponseMessage.h"

// ----------------------------------------------------------------------------
//
//   GTLRosetaskApiMessagesTaskResponseMessage
//

@implementation GTLRosetaskApiMessagesTaskResponseMessage
@dynamic assignedTo, complete, details, identifierProperty, text;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObjectsAndKeys:
      @"assigned_to", @"assignedTo",
      @"identifier", @"identifierProperty",
      nil];
  return map;
}

@end
