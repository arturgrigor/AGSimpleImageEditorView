//
//  AGAppDelegate.h
//  AGSimpleImageEditorView Demo
//
//  Created by Artur Grigor on 28.02.2012.
//  Copyright (c) 2012 Artur Grigor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGViewController;

@interface AGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) AGViewController *viewController;

@end
