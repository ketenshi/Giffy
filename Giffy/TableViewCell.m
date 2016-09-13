//
//  MWTableViewCell.m
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)layoutSubviews {
//    
//    
//    CGRect imageFrame = self.imageView.frame;
//    imageFrame.size.width = CGRectGetHeight(imageFrame);
//    
//    self.imageView.frame = imageFrame;
//    
//    [super layoutSubviews];
//}

@end
