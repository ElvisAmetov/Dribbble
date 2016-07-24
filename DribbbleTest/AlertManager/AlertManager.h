//
//  AlertManager.h
//  DribbbleTest
//
//  Created by elvis on 23.07.16.
//  Copyright (c) 2016 elvis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertManager : UIAlertController

+ (instancetype)alertManagerWithTitle:(NSString *)title
                              message:(NSString *)message
                       preferredStyle:(UIAlertControllerStyle)preferredStyle;

- (void)show;
- (void)addActionWithTitle:(NSString*)title style:(UIAlertActionStyle)style completion:(void(^)(UIAlertAction *action))completion;

+ (void)showAlertWithError:(NSError*)error;

@end
