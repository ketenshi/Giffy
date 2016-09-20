//
//  MWGifDetailViewController.m
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "GifDetailViewController.h"

#import "Gif.h"
#import "RatingView.h"

#import <FLAnimatedImage/FLAnimatedImage.h>

@interface GifDetailViewController()

@property (weak, nonatomic) IBOutlet FLAnimatedImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *tags;
@property (weak, nonatomic) IBOutlet UILabel *rating;
@property (weak, nonatomic) IBOutlet UISlider *ratingSlider;
@property (weak, nonatomic) IBOutlet RatingView *ratingCircles;

@end

@implementation GifDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareGif:)];
    
    NSData *gifData = [[NSFileManager defaultManager] contentsAtPath:self.gif.imagePath];
    
    FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
    
    self.imageView.animatedImage = animatedImage;
    
    self.tags.text = [self formattedHashTags];
    self.rating.text = [NSString stringWithFormat:@"%.1f",self.gif.rating/2.0];
    self.ratingSlider.value = self.gif.rating/2.0;
    
    self.ratingCircles.ratingValue = self.gif.rating/2.0;
//    [self.ratingCircles update];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rateChange:(UISlider *)slider {
    CGFloat val = roundf(slider.value * 2)/2; // ensure we only get multiples of 0.5
    
    self.rating.text = [NSString stringWithFormat:@"%.1f",val];
    self.ratingCircles.ratingValue = self.gif.rating/2.0;
    
    self.gif.rating = val * 2;
    [self.gif saveData];
}

- (NSString *)formattedHashTags {
    NSMutableString *hashTags = [NSMutableString string];
    for (NSString *tag in self.gif.tags) {
        [hashTags appendFormat:@"#%@ ", tag];
    }
    return hashTags;
}

- (void)shareGif:(id)sender {
    NSData *gifData = [[NSFileManager defaultManager] contentsAtPath:self.gif.imagePath];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[gifData] applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
