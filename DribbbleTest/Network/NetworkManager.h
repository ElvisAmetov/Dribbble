//
//  Network.h
//  Dribbble
//
//  Created by elvis on 23.07.16.
//  Copyright (c) 2016 elvis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>


typedef void (^SuccessResponce)(NSArray *array, RKObjectRequestOperation *operation);
typedef void (^FailureResponce)(NSError *error, RKObjectRequestOperation *operation);

typedef void (^SuccessDownloadImage)(UIImage *image);
typedef void (^FailureDownloadImage)(NSError *error);

@interface NetworkManager : NSObject

@property (nonatomic, retain, readwrite) NSMutableArray *registredClass;

+ (instancetype)sharedManager;

- (void) setupCoreData;

- (NSManagedObjectContext *)managedObjectContext;

//MARK: Mapping

- (void)addMappingForEntityForName:(NSString *)entityName
andAttributeMappingsFromDictionary:(NSDictionary *)attributeMappings
       andIdentificationAttributes:(NSArray *)ids
                    andPathPattern:(NSString *)pathPattern
                 andRepresentation:(NSDictionary*)dict;


//MARK: Requests
- (void)sendGETRequestWithPath:(NSString*)path parametrs:(NSDictionary *)parameters
                       success:(SuccessResponce)success
                       failure:(FailureResponce)failure;

//MARK: Image download
- (void)downloadImageFromURL:(NSURL*)imageURL success:(SuccessDownloadImage)success failure:(FailureDownloadImage)failure;

- (BOOL)isNetworkReachability;

@end
