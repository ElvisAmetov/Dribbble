//
//  ShotsRequest.h
//  Dribbble
//
//  Created by elvis on 23.07.16.
//  Copyright (c) 2016 elvis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkManager.h"

typedef void (^CompletionBlock)(BOOL completion, NSArray *shots);
typedef void (^RemoveFromStoreCompletion)(BOOL completion);

@interface ShotsManager : NSObject

+ (instancetype)sharedManager;

- (void)getShotsWithPage:(NSNumber*)page completion:(CompletionBlock)completion;
- (void)removeAllObjectsFromStoreWithCompletion:(RemoveFromStoreCompletion)completion;

@end
