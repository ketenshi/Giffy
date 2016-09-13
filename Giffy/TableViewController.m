//
//  TableViewController.m
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "TableViewController.h"

#import "GifDetailViewController.h"

@interface TableViewController () <NSURLSessionDownloadDelegate>

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSMutableArray <NSString *> *imageIDs;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://gifbase.com/tag/%@?format=json", self.tag]];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [defaultSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
        }
        else {
            NSDictionary *dict =  [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"data");
            self.dataSource = dict[@"gifs"];
            
            [self loadImages];
            
            [self.tableView reloadData];
        }
        NSLog(@"data");
    }];
    
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadImages {
    for (NSDictionary *gif in self.dataSource) {
        NSURL *url = [NSURL URLWithString:gif[@"url"]];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        NSURLSessionDownloadTask *task = [defaultSession downloadTaskWithURL:url];
//        NSURLSessionDataTask *task = [defaultSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [task resume];
//        }];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    if (!self.imageIDs) {
        self.imageIDs = [NSMutableArray array];
    }
    NSLog(@"A");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    documentsPath = [documentsPath stringByAppendingPathComponent:@"Gifs"];
    
    if (![fileManager fileExistsAtPath:documentsPath]) {
        [fileManager createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *s = [[NSUUID UUID] UUIDString];
    documentsPath = [documentsPath stringByAppendingPathComponent:s];
    documentsPath = [documentsPath stringByAppendingPathExtension:@"gif"];
    
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:self.imageIDs.count inSection:0];
    
    [self.imageIDs addObject:s];
    
    NSData *gifData = [NSData dataWithContentsOfURL:location];
    
//    [gifData writeToURL:[NSURL URLWithString:documentsPath] atomically:YES];
    
    [fileManager createFileAtPath:documentsPath contents:gifData attributes:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    });
    
    
//    [fileManager copyItemAtURL:location toURL:[NSURL URLWithString:documentsPath] error:nil];
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"%@", error);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
    
    NSString *imageName = self.imageIDs[indexPath.row];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    documentsPath = [documentsPath stringByAppendingPathComponent:@"Gifs"];
    documentsPath = [documentsPath stringByAppendingPathComponent:imageName];
    documentsPath = [documentsPath stringByAppendingPathExtension:@"gif"];
    
    NSData *imageData = [fileManager contentsAtPath:documentsPath];
    
    cell.imageView.image = [UIImage imageWithData:imageData];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"A");
    GifDetailViewController *detailVC = (GifDetailViewController *)segue.destinationViewController;
    
    UITableViewCell *cell = (UITableViewCell *)sender;
    
    detailVC.gifId = self.imageIDs[[self.tableView indexPathForCell:cell].row];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
