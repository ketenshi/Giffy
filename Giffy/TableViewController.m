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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadImages {
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



- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    Gif *gif = (Gif *)[self.activeDownloadTasks objectForKey:downloadTask.originalRequest.URL.absoluteString];
    [gif saveImage:location];
    
    [self.activeDownloadTasks removeObjectForKey:downloadTask.originalRequest.URL.absoluteString];
    
    if (self.activeDownloadTasks.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

#pragma mark Accessor

- (void)setTag:(NSString *)tag {
    _tag = tag;
    self.title = tag;
}

#pragma mark Lazy

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

@end
