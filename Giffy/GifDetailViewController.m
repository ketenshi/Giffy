//
//  MWGifDetailViewController.m
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "GifDetailViewController.h"

#import "Gif.h"

@interface GifDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation GifDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSData *gifData = [[NSFileManager defaultManager] contentsAtPath:self.gif.imagePath];
    
    self.imageView.image = [UIImage imageWithData:gifData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
