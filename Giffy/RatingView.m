//
//  RatingView.m
//  Giffy
//
//  Created by Eugene on 2016-09-18.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "RatingView.h"

static CGFloat circleDiameter = 20.f;
static CGFloat circleRadius = 10.f;
static CGFloat circleMargins = 5.f;

@interface RatingView ()

@property (class, readonly) CGColorRef circleColor;

@end

@implementation RatingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    
    self.userInteractionEnabled = NO;
    
    [self update];
    
    return self;
}

- (void)update {
    NSArray <CAShapeLayer *>*circleLayers = [self createCircleLayers];
    
    for (CAShapeLayer *layer in circleLayers) {
        [self.layer addSublayer:layer];
    }
}

- (void)setRatingValue:(CGFloat)ratingValue {
    _ratingValue = ratingValue;
    
    [self update];
}

- (NSArray <CAShapeLayer *> *)createCircleLayers {
    NSMutableArray *layers = [NSMutableArray array];
    
    CGFloat xPosition = 0;
    for (int i = 0; i < 5; i++) {
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        [layers addObject:circleLayer];
        circleLayer.strokeColor = [RatingView circleColor];
        [circleLayer setPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(xPosition, 0, circleDiameter, circleDiameter)].CGPath];

        if (floorf(self.ratingValue) > i) {
            circleLayer.fillColor = [RatingView circleColor];
        }
        else {
            circleLayer.fillColor = [UIColor whiteColor].CGColor;
            
            if (i < self.ratingValue && self.ratingValue < i + 1) {
                CAShapeLayer *halfCircleLayer = [CAShapeLayer layer];
                [layers addObject:halfCircleLayer];
                halfCircleLayer.strokeColor = [RatingView circleColor];
                halfCircleLayer.fillColor = [RatingView circleColor];
                [halfCircleLayer setPath:[UIBezierPath bezierPathWithArcCenter:CGPointMake(xPosition + circleRadius, circleRadius) radius:circleRadius startAngle:M_PI_2 endAngle:(CGFloat)3*M_PI_2 clockwise:YES].CGPath];
            }
        }
        
        xPosition += circleDiameter + circleMargins;
    }
    
    return [layers copy];
}



+ (CGColorRef)circleColor {
    return [UIColor darkGrayColor].CGColor;
}

@end
