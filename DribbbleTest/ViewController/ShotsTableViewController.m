//
//  ShotsTableViewController.m
//  Dribbble
//
//  Created by elvis on 23.07.16.
//  Copyright (c) 2016 elvis. All rights reserved.
//

#import "ShotsTableViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "ShotsManager.h"
#import "AlertManager.h"
#import "ShotCell.h"
#import "Shot.h"

#define kDefaultCellHeight 44.f
#define MAX_UPLOAD_SHOTS_COUNT 50

@interface ShotsTableViewController () {
    NSInteger loadingPageCount;
    NSInteger shotsCount;
}

@end

@implementation ShotsTableViewController

static NSString *kShotCellIdentifier = @"ShotCellIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ShotCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kShotCellIdentifier];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(updateShots)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    

    loadingPageCount = 1;
    shotsCount = [Shot allShotsCountWithContext:[NSManagedObjectContext MR_defaultContext]];
    if (shotsCount == 0) {
        [self getShotsWithPageIndex:loadingPageCount];
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [Shot allShotsCountWithContext:[NSManagedObjectContext MR_defaultContext]];
}


- (ShotCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShotCell *cell = (ShotCell*)[tableView dequeueReusableCellWithIdentifier:kShotCellIdentifier forIndexPath:indexPath];
    
    //Uploading shots
    if ((indexPath.row > shotsCount - 5) && (shotsCount <= MAX_UPLOAD_SHOTS_COUNT) && (indexPath.row != 0) && [[NetworkManager sharedManager] isNetworkReachability] != 0j) {
        loadingPageCount++;
        [self getShotsWithPageIndex:loadingPageCount];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(ShotCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Shot *shot = [Shot shotWithManagedObjectContext:[NSManagedObjectContext MR_defaultContext] andInnerID:indexPath.row];//self.shots[indexPath.row];
    [cell setCellWithShotTitle:shot.title shotDescription:shot.shot_description];
    
    if (shot.image == nil) {
        [cell setShotImageWithImageURL:[NSURL URLWithString:shot.imageURL] forShot:shot];
    } else {
        [cell setShotImage:shot.image];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.height / 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - update shots

- (void)getShotsWithPageIndex:(NSInteger)pageIndex {
    __weak typeof(self)weakSelf = self;
    [[ShotsManager sharedManager] getShotsWithPage:@(pageIndex) completion:^(BOOL completion, NSArray *shots) {
        shotsCount = [Shot allShotsCountWithContext:[NSManagedObjectContext MR_defaultContext]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)updateShots {
    if (![[NetworkManager sharedManager] isNetworkReachability]) {
        AlertManager *alertManager = [AlertManager alertManagerWithTitle:NSLocalizedString(@"Error", @"")
                                                                 message:NSLocalizedString(@"The Internet connection appears to be offline.", @"Internet connection Error") preferredStyle:UIAlertControllerStyleAlert];
        [alertManager addActionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel completion:nil];
        [alertManager show];
        [self.refreshControl endRefreshing];
        return;
    }
    loadingPageCount = 1;
    __weak typeof(self)weakSelf = self;
    [[ShotsManager sharedManager] removeAllObjectsFromStoreWithCompletion:^(BOOL completion) {
        [[ShotsManager sharedManager] getShotsWithPage:@(loadingPageCount) completion:^(BOOL completion, NSArray *shots) {
            shotsCount = [Shot allShotsCountWithContext:[NSManagedObjectContext MR_defaultContext]];

            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.refreshControl endRefreshing];
            });
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
            }
        }];
    }];
}

@end
