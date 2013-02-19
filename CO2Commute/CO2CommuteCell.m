//
//  CO2CommuteCell.m
//  CO2Commute
//
//  Created by user on 04/12/2012.
//
//

#import "CO2CommuteCell.h"

@implementation CO2CommuteCell

@synthesize commuteText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
