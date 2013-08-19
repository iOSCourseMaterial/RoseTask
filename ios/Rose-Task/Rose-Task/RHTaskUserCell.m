//
//  RHTaskUserCell.m
//  Rose-Task
//
//  Created by David Fisher on 8/15/13.
//  Copyright (c) 2013 David Fisher. All rights reserved.
//

#import "RHTaskUserCell.h"
#import "TaskUser+HelperUtils.h"

@implementation RHTaskUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    // Always a subtitle cell.
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void) setTaskUser:(TaskUser *) aTaskUser {
    // Configure the cell at this time (I guess). Not sure.
    _taskUser = aTaskUser;
    if (self.taskUser == nil) {
        self.textLabel.text = @"None";
        self.detailTextLabel.text = @"";
        return;
    }
    if ([self.taskUser.preferredName length] > 0) {
        self.textLabel.text = self.taskUser.preferredName;
        self.detailTextLabel.text = self.taskUser.lowercaseEmail;
    } else {
        self.textLabel.text = self.taskUser.lowercaseEmail;
        self.detailTextLabel.text = @"";
    }
    
    if (self.taskUser.googlePlusImage != nil) {
        NSLog(@"We have an image for %@. Display it", self.taskUser.preferredName);
        self.imageView.image = self.taskUser.googlePlusImage;
    }
}

@end
