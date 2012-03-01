//
//  AGSimpleImageEditorView.h
//  AGSimpleImageEditorView
//
//  Created by Artur Grigor on 28.02.2012.
//  Copyright (c) 2012 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

@interface AGSimpleImageEditorView : UIView
{
    id displayedInstance;
    
    ALAsset *asset;
    UIImage *image;
    
    UIImageView *imageView;
    UIView *overlayView;
    UIView *ratioView;
    UIView *ratioControlsView;
    
    CGFloat ratio;
    UIColor *ratioViewBorderColor;
    CGFloat ratioViewBorderWidth;
    UIColor *borderColor;
    CGFloat borderWidth;
    
    NSInteger rotation;
    NSTimeInterval animationDuration;
}

@property (nonatomic, copy) ALAsset *asset;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, assign) CGFloat ratio;
@property (nonatomic, retain) UIColor *ratioViewBorderColor;
@property (nonatomic, assign) CGFloat ratioViewBorderWidth;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) NSInteger rotation;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, readonly) UIImage *output;

- (id)initWithAsset:(ALAsset *)theAsset;
- (id)initWithImage:(UIImage *)theImage;

- (void)rotateLeft;
- (void)rotateRight;

@end
