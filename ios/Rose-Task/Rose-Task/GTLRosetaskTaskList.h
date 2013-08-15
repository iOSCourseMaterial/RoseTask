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
//   GTLRosetaskTaskList (0 custom class methods, 4 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLRosetaskTaskList
//

@interface GTLRosetaskTaskList : GTLObject
@property (copy) NSString *created;

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (retain) NSNumber *identifier;  // longLongValue

@property (retain) NSArray *taskUserEmails;  // of NSString
@property (copy) NSString *title;
@end
