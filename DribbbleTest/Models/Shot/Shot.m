//
//  Shot.m
//  DribbbleTest
//
//  Created by elvis on 23.07.16.
//  Copyright (c) 2016 elvis. All rights reserved.
//

#import "Shot.h"


@implementation Shot

@dynamic shot_id;
@dynamic inner_id;
@dynamic shot_description;
@dynamic title;
@dynamic image;
@dynamic imageURL;
@dynamic animated;
@dynamic images;

#pragma mark - Getters & Setters

- (void)setImages:(NSDictionary *)images
{
    if (!images)
        return;
    
    _images = images;
    if (images[@"hidpi"] != [NSNull null]) {
        self.imageURL = images[@"hidpi"];
    } else if (images[@"normal"] != [NSNull null]) {
        self.imageURL = images[@"normal"];
    } else if (images[@"teaser"] != [NSNull null]) {
        self.imageURL = images[@"teaser"];
    }
}

- (NSDictionary *)images
{
    return _images;
}

- (void)setImage:(UIImage *)image {
    _image = image;
}

- (UIImage*)image {
    return _image;
}

// Gets count for all saved CoreData "Shots" objects.
+ (NSInteger)allShotsCountWithContext:(NSManagedObjectContext *)managedObjectContext
{
    NSUInteger retVal;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shot" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    NSError *err;
    retVal = [managedObjectContext countForFetchRequest:request error:&err];
    
    if (err)
        NSLog(@"Error: %@", [err localizedDescription]);
    
    return retVal;
}

// Returns a "Shot" CoreData object for specified innerID attribute.
+ (Shot*)shotWithManagedObjectContext:(NSManagedObjectContext *)context andInnerID:(NSInteger)innerID
{
    Shot *retVal = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Shot" inManagedObjectContext:context];
    [request setEntity:entity];
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"inner_id = %d", innerID];
    [request setPredicate:searchFilter];
    
    NSError *err;
    NSArray *results = [context executeFetchRequest:request error:&err];
    if (results.count > 0)
        retVal = [results objectAtIndex:0];
    
    if (err)
        NSLog(@"Error: %@", [err localizedDescription]);
    
    return retVal;
}


@end
