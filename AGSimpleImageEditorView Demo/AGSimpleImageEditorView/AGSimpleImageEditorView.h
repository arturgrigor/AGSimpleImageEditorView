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

enum {
    AGMovementTypeVertically,
    AGMovementTypeHorizontally
};
typedef NSUInteger AGMovementType;

typedef void (^AGSIEVDidChangeCropRectBlock)(CGRect cropRect);
typedef void (^AGSIEVDidChangeRotationBlock)(NSInteger rotation);

@interface AGSimpleImageEditorView : UIView<NSCoding>
{
    id displayedInstance;
    
    ALAsset *asset;
    UIImage *image;
    
    UIImageView *imageView;
    UIView *overlayView;
    UIView *ratioView;
    UIView *ratioControlsView;
    AGMovementType ratioViewMovementType;
    
    CGFloat ratio;
    UIColor *ratioViewBorderColor;
    CGFloat ratioViewBorderWidth;
    UIColor *borderColor;
    CGFloat borderWidth;
    
    NSInteger rotation;
    NSTimeInterval animationDuration;
    
    CGRect cropRect;
    
    UIPanGestureRecognizer *panGestureRecognizer;
    
    AGSIEVDidChangeCropRectBlock didChangeCropRectBlock;
    AGSIEVDidChangeRotationBlock didChangeRotationBlock;
}

@property (nonatomic, copy) ALAsset *asset;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) CGFloat ratio;
@property (nonatomic, retain) UIColor *ratioViewBorderColor;
@property (nonatomic, assign) CGFloat ratioViewBorderWidth;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) NSInteger rotation;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, readonly) UIImage *output;

@property (nonatomic, copy) AGSIEVDidChangeCropRectBlock didChangeCropRectBlock;
@property (nonatomic, copy) AGSIEVDidChangeRotationBlock didChangeRotationBlock;

- (void)setRotation:(NSInteger)rotation animated:(BOOL)animated;

- (id)initWithAsset:(ALAsset *)theAsset;
- (id)initWithImage:(UIImage *)theImage;

- (void)rotateLeft;
- (void)rotateRight;

@end
