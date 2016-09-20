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

#import "RatingView.h"
#import "TableViewCell.h"

@interface TableViewController () <NSURLSessionDownloadDelegate>

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gifDataDidChange:) name:gifDataDidChangeNotification object:nil];
    
    [self updateTableResults];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark Notification

- (void)gifDataDidChange:(NSNotification *)notification {
    Gif *gifChanged = (Gif *)notification.object;
    
    if ([self.dataSource containsObject:gifChanged]) {
        [self.dataSource sortUsingComparator:[self dataSourceComparator]];
        [self.tableView reloadData];
    }
}

#pragma mark Helper
- (NSComparator)dataSourceComparator {
    static NSComparator _dataSourceComparator = nil;
    
    if (!_dataSourceComparator) {
        _dataSourceComparator = ^(Gif *gif1, Gif *gif2) {
            NSComparisonResult result = [@(gif2.rating) compare:@(gif1.rating)];
            if (result == NSOrderedSame) {
                result = NSOrderedAscending;
            }
            return result;
        };
    }
    
    return _dataSourceComparator;
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
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
    
    Gif *gif = self.dataSource[indexPath.row];
    
    NSData *imageData = [[NSFileManager defaultManager] contentsAtPath:gif.thumbnailPath];
    cell.imageView.image = [UIImage imageWithData:imageData]? : [UIImage imageNamed:@"thumbnail_placeholder"];
    
    cell.ratingView.ratingValue = gif.rating / 2.0;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    GifDetailViewController *detailVC = (GifDetailViewController *)segue.destinationViewController;
    UITableViewCell *cell = (UITableViewCell *)sender;
    detailVC.gif = self.dataSource[[self.tableView indexPathForCell:cell].row];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.activeDownloadTasks.count == 0 && indexPath.row == self.dataSource.count - 1 && !self.reachedEnd) {
        self.currentPage += 1;
        [self updateTableResults];
    }
}

- (void)updateTableResults {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://gifbase.com/tag/%@?p=%ld&format=json", self.tag, self.currentPage]];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [defaultSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error in retrieving gifbase data.\n Error: %@", error);
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
                
                NSUInteger objIndex = [self.dataSource indexOfObject:gif inSortedRange:NSMakeRange(0, self.dataSource.count) options:NSBinarySearchingInsertionIndex usingComparator:[self dataSourceComparator]];
                
                [self.dataSource insertObject:gif atIndex:objIndex];
            }
            [self loadImages];
        }
    }];
    
    [task resume];
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

@end
