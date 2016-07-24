//
//  ShotCell.h
//  Dribbble
//
//  Created by elvis on 23.07.16.
//  Copyright (c) 2016 elvis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shot.h"

@interface ShotCell : UITableViewCell

- (void)setCellWithShotTitle:(NSString*)title shotDescription:(NSString*)description;
- (void)setShotImageWithImageURL:(NSURL*)imageURL forShot:(Shot*)shot;
- (void)setShotImage:(UIImage*)image;

@end
