/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2013 Google Inc.
 */

//
//  GTLRosetaskTaskCollection.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   rosetask/v1
// Description:
//   Rose Task API
// Classes:
//   GTLRosetaskTaskCollection (0 custom class methods, 2 custom properties)

#import "GTLRosetaskTaskCollection.h"

#import "GTLRosetaskTask.h"

// ----------------------------------------------------------------------------
//
//   GTLRosetaskTaskCollection
//

@implementation GTLRosetaskTaskCollection
@dynamic items, nextPageToken;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map =
    [NSDictionary dictionaryWithObject:[GTLRosetaskTask class]
                                forKey:@"items"];
  return map;
}

@end
