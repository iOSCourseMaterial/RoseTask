/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2013 Google Inc.
 */

//
//  GTLRosetaskTaskList.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   rosetask/v1
// Description:
//   Rose Task API
// Classes:
//   GTLRosetaskTaskList (0 custom class methods, 5 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

@class GTLRosetaskUserMessage;

// ----------------------------------------------------------------------------
//
//   GTLRosetaskTaskList
//

@interface GTLRosetaskTaskList : GTLObject
@property (copy) NSString *created;

// ProtoRPC container for users.User objects. Attributes: email: String; The
// email of the user. auth_domain: String; The auth domain of the user. user_id:
// String; The user ID. federated_identity: String; The federated identity of
// the user.
@property (retain) GTLRosetaskUserMessage *creator;

@property (retain) NSArray *taskKeys;  // of NSString
@property (retain) NSArray *taskUserEmails;  // of NSString
@property (copy) NSString *title;
@end
