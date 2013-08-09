/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2013 Google Inc.
 */

//
//  GTLRosetaskUserMessage.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   rosetask/v1
// Description:
//   Rose Task API
// Classes:
//   GTLRosetaskUserMessage (0 custom class methods, 4 custom properties)

#import "GTLRosetaskUserMessage.h"

// ----------------------------------------------------------------------------
//
//   GTLRosetaskUserMessage
//

@implementation GTLRosetaskUserMessage
@dynamic authDomain, email, federatedIdentity, userId;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObjectsAndKeys:
      @"auth_domain", @"authDomain",
      @"federated_identity", @"federatedIdentity",
      @"user_id", @"userId",
      nil];
  return map;
}

@end
