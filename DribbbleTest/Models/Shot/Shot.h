//
//  Shot.h
//  DribbbleTest
//
//  Created by elvis on 23.07.16.
//  Copyright (c) 2016 elvis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@import UIKit;


@interface Shot : NSManagedObject {
    NSDictionary *_images;
    UIImage *_image;
}

@property (nonatomic, retain) NSNumber * shot_id;
@property (nonatomic, retain) NSNumber * inner_id;
@property (nonatomic, retain) NSString * shot_description;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * animated;
@property NSDictionary *images;
@property UIImage * image;

+ (Shot*)shotWithManagedObjectContext:(NSManagedObjectContext *)context andInnerID:(NSInteger)innerID;
+ (NSInteger)allShotsCountWithContext:(NSManagedObjectContext *)managedObjectContext;

@end
