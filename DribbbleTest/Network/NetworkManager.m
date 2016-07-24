//
//  Network.m
//  Dribbble
//
//  Created by elvis on 23.07.16.
//  Copyright (c) 2016 elvis. All rights reserved.
//
#define MR_SHORTHAND
#import "NetworkManager.h"
#import <MagicalRecord/MagicalRecord.h>
#import "AlertManager.h"

@interface NetworkManager()

@end

@implementation NetworkManager {
    RKObjectManager *objectManager;
    RKManagedObjectStore *managedObjectStore;
    AFRKHTTPClient* client;
}

@synthesize registredClass;

static NetworkManager *manager = nil;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
        [manager setupServer];
        // Configure CoreData managed object model.
        [MagicalRecord setupCoreDataStackWithStoreNamed:@"DribbbleTest"];
        [manager setupCoreData];
        
    });
    return manager;
}


- (NSManagedObjectContext *)managedObjectContext
{
    return [NSManagedObjectContext MR_defaultContext];
}

- (void) setupCoreData  {
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"DribbbleTest"];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DribbbleTest" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"DribbbleTest.sqlite"];
    NSError *error = nil;
    [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    [managedObjectStore createManagedObjectContexts];
    
    // Configure MagicalRecord to use RestKit's Core Data stack
    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:managedObjectStore.persistentStoreCoordinator];
    [NSManagedObjectContext MR_setRootSavingContext:managedObjectStore.persistentStoreManagedObjectContext];
    [NSManagedObjectContext MR_setDefaultContext:managedObjectStore.mainQueueManagedObjectContext];
    
    objectManager.managedObjectStore = managedObjectStore;
    
}

- (void)setupServer {
    client = [[AFRKHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    [objectManager.HTTPClient clearAuthorizationHeader];
    
    //set default HTTP headers
    [objectManager.HTTPClient setDefaultHeader:@"Content-Type" value:@"application/json"];
    [objectManager.HTTPClient setDefaultHeader:@"access_token" value:kAccessToken];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"{application/json"];
    
    objectManager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    [RKObjectManager setSharedManager:objectManager];
}

#pragma mark - mapping 

- (void)addMappingForEntityForName:(NSString *)entityName
andAttributeMappingsFromDictionary:(NSDictionary *)attributeMappings
       andIdentificationAttributes:(NSArray *)ids
                    andPathPattern:(NSString *)pathPattern
                 andRepresentation:(NSDictionary*)dict
{
    if (!managedObjectStore)
        return;
    
    // Create mapping for entity.
    RKEntityMapping *objectMapping = [RKEntityMapping mappingForEntityForName:entityName
                                                         inManagedObjectStore:managedObjectStore];
    [objectMapping addAttributeMappingsFromDictionary:attributeMappings];
    objectMapping.identificationAttributes = ids;
    
    //throws no animated objects
    RKDynamicMapping *dynamicMapping = [[RKDynamicMapping alloc] init];
    [dynamicMapping setObjectMappingForRepresentationBlock:^RKObjectMapping *(id representation) {
        for (NSString *key in [dict allKeys]) {
            if ([representation[key] isEqual:dict[key]]) {
                return objectMapping;
            }
        }
        return nil;
    }];
    
    // Register mappings with the provider using a response descriptor.
    RKResponseDescriptor *characterResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:dynamicMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:nil
                                                keyPath:@""
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:characterResponseDescriptor];
}
	
#pragma mark - request

- (void)sendGETRequestWithPath:(NSString*)path parametrs:(NSDictionary *)parameters
                                  success:(SuccessResponce)success
                                  failure:(FailureResponce)failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    //Set parameters. Access token is default parameter
    [params setObject:kAccessToken forKey:kAccessTokenPath];
    [params addEntriesFromDictionary:parameters];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:path
                                    parameters:[params copy]
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           NSArray *objects = [mappingResult array];
                                           NSLog(@"%@", objects);
                                           success (objects, operation);
                                       } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                           failure(error, operation);
                                       }];

}

#pragma mark - image download



- (void)downloadImageFromURL:(NSURL*)imageURL success:(SuccessDownloadImage)success failure:(FailureDownloadImage)failure {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:imageURL];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   success(image);
                               } else{
                                   failure(error);
                               }
                           }];
}

- (BOOL)isNetworkReachability {
    return client.networkReachabilityStatus;
}

@end
