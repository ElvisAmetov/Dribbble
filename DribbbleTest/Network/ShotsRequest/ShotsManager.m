//
//  ShotsRequest.m
//  Dribbble
//
//  Created by elvis on 23.07.16.
//  Copyright (c) 2016 elvis. All rights reserved.
//

#import "ShotsManager.h"
#import "Shot.h"
#import <MagicalRecord/MagicalRecord.h>
#import "AlertManager.h"

@implementation ShotsManager {
    NSInteger numberOfShots;
}

static ShotsManager *request = nil;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        request = [[[self class] alloc] init];
    });
    return request;
}

- (void)getShotsWithPage:(NSNumber*)page completion:(CompletionBlock)completion {
    NSDictionary *representation = @{@"animated": @0};
    
    //Mapping shots
    [[NetworkManager sharedManager] addMappingForEntityForName:@"Shot" andAttributeMappingsFromDictionary:@{@"id" : @"shot_id",
                                                                                                            @"title" : @"title",
                                                                                                            @"description" : @"shot_description",
                                                                                                            @"images" : @"images",
                                                                                                            @"animated" : @"animated"}
                                   andIdentificationAttributes:@[@"shot_id"] andPathPattern:[NSString stringWithFormat:@"?%@=%@", kAccessTokenPath, kAccessToken]
                                             andRepresentation:representation];
  
    //Get shots from server
    [[NetworkManager sharedManager] sendGETRequestWithPath:kShotsPathPattern parametrs:@{@"page" : page} success:^(NSArray *array, RKObjectRequestOperation *operation) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext * context) {
            NSInteger newInnerID = [Shot allShotsCountWithContext:[NSManagedObjectContext MR_defaultContext]] - array.count; // need to produce shots on an index of UITableViewCell
            for (Shot *shot in array) {
                if ([shot isKindOfClass:[Shot class]]) {
                    shot.inner_id = @(newInnerID);
                    newInnerID++;
                }
            }
            numberOfShots = newInnerID;
            completion(YES, array);
        }];
    } failure:^(NSError *error, RKObjectRequestOperation *operation) {
        completion(NO, nil);
        [AlertManager showAlertWithError:error];
    }];
}

- (void)removeAllObjectsFromStoreWithCompletion:(RemoveFromStoreCompletion)completion {
    NSArray *allEntities = [NSManagedObjectModel MR_defaultManagedObjectModel].entities;
    [allEntities enumerateObjectsUsingBlock:^(NSEntityDescription *entityDescription, NSUInteger idx, BOOL *stop) {
        [NSClassFromString([entityDescription managedObjectClassName]) MR_truncateAll];
        completion(stop);
    }];
}

@end
