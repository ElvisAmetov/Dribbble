//
//  ShotCell.m
//  Dribbble
//
//  Created by elvis on 23.07.16.
//  Copyright (c) 2016 elvis. All rights reserved.
//

#import "ShotCell.h"
#import "NetworkManager.h"
#import <MagicalRecord/MagicalRecord.h>
#import "HTMLLabel.h"

@interface ShotCell()

@property (weak, nonatomic) IBOutlet UIImageView *shotImageView;
@property (weak, nonatomic) IBOutlet HTMLLabel *shotTitleLabel;
@property (weak, nonatomic) IBOutlet HTMLLabel *shotDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation ShotCell

- (void)awakeFromNib {
    // Initialization code
    [self.indicatorView startAnimating];
    [self.indicatorView setHidden:NO];
}

- (void)setCellWithShotTitle:(NSString*)title shotDescription:(NSString*)description {
    [self.shotTitleLabel setText:title];
    [self.shotDescriptionLabel setText:description];
}

- (void)setShotImageWithImageURL:(NSURL*)imageURL forShot:(Shot*)shot {
    self.shotImageView.image = nil;
    __weak typeof(self)weakSelf = self;
    [[NetworkManager sharedManager] downloadImageFromURL:imageURL success:^(UIImage *image) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * context) {
            shot.image = image;
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.shotImageView setImage:image];
            [weakSelf.indicatorView stopAnimating];
            [weakSelf.indicatorView setHidden:YES];
        });
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        [weakSelf.indicatorView stopAnimating];
        [weakSelf.indicatorView setHidden:YES];
    }];
}

- (void)setShotImage:(UIImage*)image {
    [self.shotImageView setImage:image];
}

@end
