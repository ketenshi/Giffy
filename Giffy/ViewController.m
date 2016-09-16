//
//  ViewController.m
//  Giffy
//
//  Created by Eugene on 2016-09-11.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "ViewController.h"

#import "TableViewController.h"

@interface ViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *suggestionsTable;

@property (strong, nonatomic) NSArray *tagSuggestions;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.searchTextField.delegate = self;
    self.suggestionsTable.delegate = self;
    self.suggestionsTable.dataSource = self;
    self.suggestionsTable.hidden = YES;
    
    self.title = @"Giffy";
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Search", nil)
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:nil
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TableViewController *tableVC = (TableViewController *)segue.destinationViewController;
    
    NSString *tag = @"happy";
    if (self.searchTextField.text != nil && ![self.searchTextField.text isEqualToString:@""]) {
        tag = self.searchTextField.text;
    }
    
    tableVC.tag = tag;
}

#pragma mark Lazy

- (NSArray *)tagSuggestions {
    if (!_tagSuggestions) {
        _tagSuggestions = [NSArray array];
    }
    return _tagSuggestions;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *substring = textField.text;
    substring = [substring stringByAppendingString:string];
    [self reloadSuggestionsTableWithSubstring:substring];
    return YES;
}

- (void)reloadSuggestionsTableWithSubstring:(NSString *)substring {
    if (substring.length < 2) return;
    
    self.suggestionsTable.hidden = NO;
    
    self.tagSuggestions = nil;
    
    NSString *tagFilePath = [[NSBundle mainBundle] pathForResource:@"tags" ofType:@"json"];
    NSData *tagData = [NSData dataWithContentsOfFile:tagFilePath];
    NSArray *tagsArray = [NSJSONSerialization JSONObjectWithData:tagData options:0 error:nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", substring];
    self.tagSuggestions = [tagsArray filteredArrayUsingPredicate:predicate];
    
    self.tagSuggestions = [self.tagSuggestions subarrayWithRange:NSMakeRange(0, MIN(self.tagSuggestions.count, 5))];
    
    [self.suggestionsTable reloadData];
}

#pragma mark - Table View
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.searchTextField.text = self.tagSuggestions[indexPath.row];
    
    self.suggestionsTable.hidden = YES;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tagSuggestions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestionsCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"suggestionsCell"];
    }
    cell.textLabel.text = self.tagSuggestions[indexPath.row];
    
    return cell;
}

@end
