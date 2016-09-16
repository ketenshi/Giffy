//
//  TableViewController.m
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "TableViewController.h"

#import "Gif.h"
#import "GifDetailViewController.h"
#import "GifDatabase.h"

@interface TableViewController () <NSURLSessionDownloadDelegate, UISearchControllerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UISearchController *searchController;

@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) BOOL reachedEnd;
@property (strong, nonatomic) NSMutableArray <Gif *>*dataSource;
@property (strong, nonatomic) NSMutableDictionary *activeDownloadTasks;

@end

@implementation TableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.currentPage = 1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    
    self.searchController.searchBar.delegate = self;
    
//    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    [self updateTableResults];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadImages {
    NSLog(@"loading images");
    for (Gif *gif in self.dataSource) {
        if (gif.imageDownloaded) {
            continue;
        }
        
        NSURL *url = [NSURL URLWithString:gif.webURL];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        NSURLSessionDownloadTask *task = [defaultSession downloadTaskWithURL:url];
        
        [self.activeDownloadTasks setObject:gif forKey:gif.webURL];
        
        [task resume];
    }
    
    if (self.activeDownloadTasks.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }
}

- (void)setTag:(NSString *)tag {
    _tag = tag;
    self.title = tag;
}

- (NSMutableDictionary *)activeDownloadTasks {
    if (!_activeDownloadTasks) {
        _activeDownloadTasks = [NSMutableDictionary dictionary];
    }
    return _activeDownloadTasks;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    Gif *gif = (Gif *)[self.activeDownloadTasks objectForKey:downloadTask.originalRequest.URL.absoluteString];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    documentsPath = [NSString pathWithComponents:@[documentsPath, @"Database", gif.identifier]];
//    documentsPath = [documentsPath stringByAppendingPathExtension:@"gifData"];
//    
//    if (![fileManager fileExistsAtPath:documentsPath]) {
//        [fileManager createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    
//    documentsPath = [documentsPath stringByAppendingPathComponent:@"image.gif"];
////    documentsPath = [documentsPath stringByAppendingPathExtension:@"gif"];
//    
//    NSData *gifData = [NSData dataWithContentsOfURL:location];
//    [fileManager createFileAtPath:documentsPath contents:gifData attributes:nil];
//    
////    Gif *gif2 = [[GifDatabase sharedDatabase] gifWithIdentifier:gif.identifier];
//    gif.storagePath = documentsPath;
////
//    [gif saveData];
    
    [gif saveImage:location];
    
    [self.activeDownloadTasks removeObjectForKey:downloadTask.originalRequest.URL.absoluteString];
    
    if (self.activeDownloadTasks.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
//    NSLog(@"%@", error);
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
    
    Gif *gif = self.dataSource[indexPath.row];
    
    NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:gif.thumbnailPath];
    cell.imageView.image = [UIImage imageWithData:imageData];

    cell.textLabel.text = gif.tags;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GifDetailViewController *detailVC = (GifDetailViewController *)segue.destinationViewController;
    UITableViewCell *cell = (UITableViewCell *)sender;
    detailVC.gif = self.dataSource[[self.tableView indexPathForCell:cell].row];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.activeDownloadTasks.count > 0) {
        for (NSURLSessionDownloadTask *task in self.activeDownloadTasks) {
            [task cancel];
        }
        
        [self.activeDownloadTasks removeAllObjects];
    }
    
    self.tag = searchBar.text;
    
    self.searchController.active = NO;
    self.dataSource = nil;
    self.currentPage = 1;
    self.reachedEnd = NO;
    
    [self updateTableResults];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.activeDownloadTasks.count == 0 && indexPath.row == self.dataSource.count - 1 && !self.reachedEnd) {
        NSLog(@"B");
        self.currentPage += 1;
        [self updateTableResults];
    }
}

- (void)updateTableResults {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://gifbase.com/tag/%@?p=%ld&format=json", self.tag, self.currentPage]];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [defaultSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
        }
        else {
            NSDictionary *dict =  [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (dict[@"error"]) {
                self.reachedEnd = YES;
                return;
            }
            for (NSDictionary *gifData in dict[@"gifs"]) {
                Gif *gif = [[GifDatabase sharedDatabase] gifWithIdentifier:gifData[@"id"]];
                
                if (!gif) {
                    gif = [[GifDatabase sharedDatabase] createAndSaveGifWithData:gifData];
                }
                
                [self.dataSource addObject:gif];
            }
            [self loadImages];
        }
    }];
    
    [task resume];
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
