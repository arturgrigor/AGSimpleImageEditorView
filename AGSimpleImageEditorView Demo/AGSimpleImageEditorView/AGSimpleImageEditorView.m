//
//  AGSimpleImageEditorView.m
//  AGSimpleImageEditorView
//
//  Created by Artur Grigor on 28.02.2012.
//  Copyright (c) 2012 Artur Grigor. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "AGSimpleImageEditorView.h"

@interface AGSimpleImageEditorView ()

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, retain) UIView *ratioView;
@property (nonatomic, retain) UIView *ratioControlsView;

- (id)initWithAsset:(ALAsset *)theAsset image:(UIImage *)theImage andFrame:(CGRect)frame;
- (id)initWithAsset:(ALAsset *)theAsset andImage:(UIImage *)theImage;

//
//  Image
//
- (UIImage *)imageFromInstance:(id)instance;
- (void)redisplayImage;
- (void)displayImage:(id)instance;
- (void)overlayClipping;
- (void)repositionRatioControls;
- (void)rotateImageForImageView:(UIImageView *)theImageView withDuration:(NSTimeInterval)duration andRotation:(NSInteger)rotation;
- (void)repositionImageView;

//
//  Ratio
//
@property (nonatomic, assign) BOOL ratioControlsHidden;
- (void)showOrHideTheRatioControls;

//
//  Calculations
//
- (CGRect)imageFrameFromImageViewWithAspectFitMode:(UIImageView *)theImageView;
- (CGRect)centerForImage:(UIImage *)image inRect:(CGRect)rect scaleIfNeeded:(BOOL)scaleIfNeeded;
- (CGRect)rectForRatio:(CGFloat)ratio;

@end

@implementation AGSimpleImageEditorView

#pragma mark - Properties

@synthesize imageView, overlayView, ratioView, ratioControlsView, asset, image, ratio, ratioControlsHidden, ratioViewBorderColor, ratioViewBorderWidth, borderColor, borderWidth, rotation, animationDuration;

- (void)setAsset:(ALAsset *)theAsset
{
    if (asset != theAsset)
    {
        [asset release];
        asset = [theAsset retain];
        
        [self displayImage:asset];
    }
}

- (void)setImage:(UIImage *)theImage
{
    if (image != theImage)
    {
        [image release];
        image = [theImage retain];

        [self displayImage:image];
    }
}

- (void)setRatio:(CGFloat)theRatio
{
    ratio = theRatio;
    
    if (ratio > 0)
    {
        // Reposition ratio controls
        [self repositionRatioControls];
    }

    [self showOrHideTheRatioControls];
}

- (void)setRatioControlsHidden:(BOOL)theRatioControlsHidden
{
    self.ratioControlsView.hidden = theRatioControlsHidden;
}

- (void)showOrHideTheRatioControls
{
    self.ratioControlsHidden = (ratio == 0);
}

- (void)setRatioViewBorderColor:(UIColor *)theRatioViewBorderColor
{
    if (ratioViewBorderColor != theRatioViewBorderColor)
    {
        [ratioViewBorderColor release];
        ratioViewBorderColor = [theRatioViewBorderColor retain];
        
        self.ratioView.layer.borderColor = ratioViewBorderColor.CGColor;
    }
}

- (void)setRatioViewBorderWidth:(CGFloat)theRatioViewBorderWidth
{
    ratioViewBorderWidth = theRatioViewBorderWidth;
    
    self.ratioView.layer.borderWidth = ratioViewBorderWidth;
}

- (void)setBorderColor:(UIColor *)theBorderColor
{
    if (borderColor != theBorderColor)
    {
        [borderColor release];
        borderColor = [theBorderColor retain];
        
        self.layer.borderColor = borderColor.CGColor;
    }
}

- (void)setBorderWidth:(CGFloat)theBorderWidth
{
    borderWidth = theBorderWidth;
    
    self.layer.borderWidth = borderWidth;
    
    // Reposition image
    [self redisplayImage];
}

- (void)setRotation:(NSInteger)theRotation
{
    rotation = theRotation;
    if (rotation < -4)
        rotation = 4 - abs(rotation);
    if (rotation > 4)
        rotation = rotation - 4;
    
    [self rotateImageForImageView:self.imageView withDuration:self.animationDuration andRotation:rotation];
}

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [ratioViewBorderColor release];
    [ratioView release];
    [overlayView release];
    [ratioControlsView release];
    [imageView release];
    
    [asset release];
    [image release];
    
    [super dealloc];
}

#pragma mark - Designated Initializer

- (id)initWithAsset:(ALAsset *)theAsset image:(UIImage *)theImage andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Don't display outside this box
        self.clipsToBounds = YES;
        self.animationDuration = 0.5f;
        self.autoresizesSubviews = YES;
        
        displayedInstance = nil;
        ratio = 0;
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"transparencyPattern"]];
        
        // Creating the image view
        imageView = [[UIImageView alloc] initWithFrame:self.frame];
        imageView.userInteractionEnabled = NO;
        imageView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizesSubviews = YES;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:imageView];
        
        // Ratio Controls View
        ratioControlsView = [[UIView alloc] initWithFrame:imageView.frame];
        ratioControlsView.hidden = YES;
        ratioControlsView.autoresizesSubviews = YES;
        
        // Overlay
        overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        overlayView.alpha = .5;
        overlayView.backgroundColor = [UIColor blackColor];
        overlayView.userInteractionEnabled = NO;
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [ratioControlsView addSubview:overlayView];
        
        // Ratio view
        ratioView = [[UIView alloc] initWithFrame:CGRectZero];
        ratioView.autoresizingMask = UIViewAutoresizingNone;
        [ratioControlsView addSubview:ratioView];
        
        [self addSubview:ratioControlsView];
        
        self.asset = theAsset;
        self.image = theImage;
        
        self.ratioViewBorderColor = [UIColor redColor];
        self.ratioViewBorderWidth = 1.f;
        
        [self showOrHideTheRatioControls];
    }
    
    return self;
}

- (id)initWithAsset:(ALAsset *)theAsset andImage:(UIImage *)theImage
{
    return [self initWithAsset:theAsset image:theImage andFrame:CGRectMake(0, 0, 256.f, 256.f)];
}

#pragma mark - Initializers

- (id)initWithAsset:(ALAsset *)theAsset
{
    return [self initWithAsset:theAsset andImage:nil];
}

- (id)initWithImage:(UIImage *)theImage
{
    return [self initWithAsset:nil andImage:theImage];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithAsset:nil image:nil andFrame:frame];
}

#pragma mark - View

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Reposition ratio controls
    [self repositionRatioControls];
}

#pragma mark - Image

- (UIImage *)imageFromInstance:(id)instance
{
    if ([instance isKindOfClass:[ALAsset class]])
        return [UIImage imageWithCGImage:((ALAsset *)instance).defaultRepresentation.fullResolutionImage];
    else if ([instance isKindOfClass:[UIImage class]])
        return instance;
    else
        return nil;
}

- (void)redisplayImage
{
    [self displayImage:displayedInstance];
}

- (void)displayImage:(id)instance
{
    if (instance == nil)
        return;
    
    displayedInstance = instance;
    
    [self.imageView setImage:[self imageFromInstance:instance]];
    // Reposition the image view
    [self repositionImageView];

    // Reposition ratio controls
    [self repositionRatioControls];
}

- (void)repositionImageView
{
    [self.imageView setFrame:CGRectMake(
                                    borderWidth, 
                                    borderWidth, 
                                    self.frame.size.width - (borderWidth * 2), 
                                    self.frame.size.height - (borderWidth * 2))];
}

- (void)repositionRatioControls
{
    CGRect actualImageRect = [self imageFrameFromImageViewWithAspectFitMode:self.imageView];
    CGRect frame = CGRectZero;
    CGFloat imageRatio = self.imageView.image.size.width / self.imageView.image.size.height;
    if (imageRatio > self.ratio) {
        // Width > Height
        frame = CGRectMake(0, 0, self.ratio * actualImageRect.size.height, actualImageRect.size.height);
    } else {
        // Height > Width
        frame = CGRectMake(0, 0, actualImageRect.size.width, actualImageRect.size.width / self.ratio);
    }

    [self.ratioView setFrame:frame];
    [self.ratioControlsView setFrame:actualImageRect];

    // Reset overlay clipping
    [self overlayClipping];
}

- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();

    // Left side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 
                                        0, 
                                        self.ratioView.frame.origin.x, 
                                        self.overlayView.frame.size.height));
    // Right side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(
                                        self.ratioView.frame.origin.x + self.ratioView.frame.size.width, 
                                        0, 
                                        self.overlayView.frame.size.width - self.ratioView.frame.origin.x - self.ratioView.frame.size.width, 
                                        self.overlayView.frame.size.height));
    // Top side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 
                                        0, 
                                        self.overlayView.frame.size.width, 
                                        self.ratioView.frame.origin.y));
    // Bottom side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 
                                        self.ratioView.frame.origin.y + self.ratioView.frame.size.height, 
                                        self.overlayView.frame.size.width, 
                                        self.overlayView.frame.size.height));
    maskLayer.path = path;

    self.overlayView.layer.mask = maskLayer;
    [maskLayer release];
}

- (void)rotateImageForImageView:(UIImageView *)theImageView withDuration:(NSTimeInterval)duration andRotation:(NSInteger)theRotation
{
    [UIView animateWithDuration:duration animations:^{        
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(theRotation * M_PI / 2);
        self.imageView.transform = rotationTransform;
        
        // Reposition the image view
        [self repositionImageView];
    }];
}

- (void)rotateLeft
{
    self.rotation = self.rotation - 1;
}

- (void)rotateRight
{
    self.rotation = self.rotation + 1;
}

#pragma mark - Calculations

- (CGRect)centerForImage:(UIImage *)theImage inRect:(CGRect)theRect scaleIfNeeded:(BOOL)scaleIfNeeded
{
    CGSize imageSize = [theImage size];
    CGFloat x = 0, y = 0, width = imageSize.width, height = imageSize.height;

    if (scaleIfNeeded)
    {
        if (width > theRect.size.width || height > theRect.size.height)
        {
            if (width > height)
            {
                width = theRect.size.width;
                height = imageSize.height / imageSize.width * width;                
            } else
            {
                height = theRect.size.height;
                width = imageSize.width * height / imageSize.height;
            }
        }
    }

    x = (theRect.size.width - width) / 2;
    y = (theRect.size.height - height) / 2;

    return CGRectMake(theRect.origin.x + round(x), theRect.origin.y + round(y), round(width), round(height));
}

- (CGRect)rectForRatio:(CGFloat)theRatio
{
    CGFloat x = self.ratioView.frame.origin.x, y = self.ratioView.frame.origin.y;
    CGFloat height = self.imageView.frame.size.height, width = height / theRatio;
    
    return CGRectMake(x, y, width, height);
}

- (CGRect)imageFrameFromImageViewWithAspectFitMode:(UIImageView *)theImageView
{
    float imageRatio = theImageView.image.size.width / theImageView.image.size.height;
    float viewRatio = theImageView.frame.size.width / theImageView.frame.size.height;
    
    if (imageRatio < viewRatio)
    {
        float scale = theImageView.frame.size.height / theImageView.image.size.height; 
        float width = scale * theImageView.image.size.width;
        float topLeftX = (theImageView.frame.size.width - width) * 0.5;
        return CGRectMake(topLeftX, 0, width, theImageView.frame.size.height);
    }
    else
    {
        float scale = theImageView.frame.size.width / theImageView.image.size.width;
        float height = scale * theImageView.image.size.height;
        float topLeftY = (theImageView.frame.size.height - height) * 0.5;
        return CGRectMake(0, topLeftY, theImageView.frame.size.width, height);
    }
}

@end
