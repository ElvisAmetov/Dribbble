//
//  AlertManager.m
//  DribbbleTest
//
//  Created by elvis on 23.07.16.
//  Copyright (c) 2016 elvis. All rights reserved.
//

#import "AlertManager.h"

@interface AlertManager ()

@property (nonatomic) UIWindow *alertWindow;

@end

@implementation AlertManager


+ (instancetype)alertManagerWithTitle:(NSString *)title
                                          message:(NSString *)message
                                   preferredStyle:(UIAlertControllerStyle)preferredStyle {
    return [AlertManager alertManagerWithTitle:title
                                       message:message
                                preferredStyle:preferredStyle
                                   alertWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
}

+ (instancetype)alertManagerWithTitle:(NSString *)title
                                          message:(NSString *)message
                                   preferredStyle:(UIAlertControllerStyle)preferredStyle
                                      alertWindow:(UIWindow *)alertWindow {
    
    AlertManager *fdlAlertController = [self alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    alertWindow.rootViewController = [[UIViewController alloc] init];
    alertWindow.windowLevel = UIWindowLevelAlert + 1;
    fdlAlertController.alertWindow = alertWindow;
    return fdlAlertController;
}

- (void)show {
    [self.alertWindow makeKeyAndVisible];
    [self.alertWindow.rootViewController presentViewController:self animated:YES completion:nil];
}

- (UIWindow *)alertWindow {
    if (!_alertWindow) {
        UIWindow *window =  [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        window.rootViewController = [[UIViewController alloc] init];
        window.windowLevel = UIWindowLevelAlert + 1;
        _alertWindow = window;
    }
    return _alertWindow;
}

- (void)addActionWithTitle:(NSString*)title style:(UIAlertActionStyle)style completion:(void(^)(UIAlertAction *action))completion {
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *action) {
        if (completion) {
            completion(action);
        }
    }];
    [self addAction:alertAction];
}

+ (void)showAlertWithError:(NSError*)error {
    NSString *errorString = [error localizedDescription];
    AlertManager *alertManager = [AlertManager alertManagerWithTitle:NSLocalizedString(@"Error", @"") message:errorString preferredStyle:UIAlertControllerStyleAlert];
    [alertManager addActionWithTitle:NSLocalizedString(@"Close", @"") style:UIAlertActionStyleCancel completion:nil];
    [alertManager show];
}

@end
