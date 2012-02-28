//
//  AGViewController.h
//  AGSimpleImageEditorView Demo
//
//  Created by Artur Grigor on 28.02.2012.
//  Copyright (c) 2012 Universitatea "Babes-Bolyai". All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AGSimpleImageEditorView.h"

@interface AGViewController : UIViewController
{
    AGSimpleImageEditorView *simpleImageEditorView;
    UISegmentedControl *ratioSegmentedControl;
}

@end
