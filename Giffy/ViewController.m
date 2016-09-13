//
//  ViewController.m
//  Giffy
//
//  Created by Eugene on 2016-09-11.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "ViewController.h"

#import "TableViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
    TableViewController *tableVC = (TableViewController *)navController.topViewController;
    
    NSString *tag = @"happy";
    if (self.searchTextField.text != nil && ![self.searchTextField.text isEqualToString:@""]) {
        tag = self.searchTextField.text;
    }
    
    tableVC.tag = tag;
}


@end
