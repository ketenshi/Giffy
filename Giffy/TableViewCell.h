//
//  MWTableViewCell.h
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RatingView;

@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet RatingView *ratingView;

@end
