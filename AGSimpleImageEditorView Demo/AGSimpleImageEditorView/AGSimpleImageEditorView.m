//
//  AGSimpleImageEditorView.m
//  AGSimpleImageEditorView
//
//  Created by Artur Grigor on 28.02.2012.
//  Copyright (c) 2012 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGSimpleImageEditorView.h"

#define kCodingKeyAsset                         @"asset"
#define kCodingKeyImage                         @"image"
#define kCodingKeyRatio                         @"ratio"
#define kCodingKeyRatioViewBorderColor          @"ratioViewBorderColor"
#define kCodingKeyRatioViewBorderWidth          @"ratioViewBorderWidth"
#define kCodingKeyBorderColor                   @"borderColor"
#define kCodingKeyBorderWidth                   @"borderWidth"
#define kCodingKeyRotation                      @"rotation"
#define kCodingKeyAnimationDuration             @"animationDuration"
#define kCodingKeyCropRect                      @"cropRect"

CGSize CGSizeAbsolute(CGSize size) {
    return (CGSize){fabs(size.width), fabs(size.height)};
}

@interface AGSimpleImageEditorView ()

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, retain) UIView *ratioView;
@property (nonatomic, retain) UIView *ratioControlsView;

- (void)initialize;

- (id)initWithAsset:(ALAsset *)theAsset image:(UIImage *)theImage andFrame:(CGRect)frame;
- (id)initWithAsset:(ALAsset *)theAsset andImage:(UIImage *)theImage;

//  
//  Gestures
//  
- (void)panGesture:(UIPanGestureRecognizer *)recognizer;

//
//  Output
//
- (CGSize)sizeForRotatedImage:(UIImage *)imageToRotate;
- (UIImage *)rotatedImage:(UIImage *)imageToRotate;
- (UIImage *)croppedImage:(UIImage *)imageToCrop;

//
//  Image
//
- (UIImage *)imageFromInstance:(id)instance;
- (void)redisplayImage;
- (void)displayImage:(id)instance;
- (void)overlayClipping;
- (void)resetRatioControls;
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

@end

@implementation AGSimpleImageEditorView

#pragma mark - Properties

@synthesize imageView, overlayView, ratioView, ratioControlsView, asset, image, ratio, ratioControlsHidden, ratioViewBorderColor, ratioViewBorderWidth, borderColor, borderWidth, rotation, animationDuration;

@synthesize didChangeCropRectBlock, didChangeRotationBlock;

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

- (CGRect)cropRect
{
    return (self.ratioView.frame);
}

- (void)setCropRect:(CGRect)theCropRect
{
    self.ratioView.frame = theCropRect;
    
    // Reset overlay clipping
    [self overlayClipping];
}

- (void)setRatio:(CGFloat)theRatio
{
    ratio = theRatio;
    
    if (ratio > 0)
    {
        // Reposition ratio controls
        [self resetRatioControls];
        
        // Notification
        if (self.didChangeCropRectBlock)
            self.didChangeCropRectBlock(self.ratioView.frame);
    }
    
    // Reset crop rect
    cropRect = CGRectZero;
    
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
    [self setRotation:theRotation animated:NO];
}

- (void)setRotation:(NSInteger)theRotation animated:(BOOL)animated
{
    rotation = theRotation;
    if (rotation < -4)
        rotation = 4 - abs(rotation);
    if (rotation > 4)
        rotation = rotation - 4;
    
    if (animated)
    {
        self.ratioControlsView.alpha = 0;
        
        [UIView animateWithDuration:self.animationDuration animations:^{        
            CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotation * M_PI / 2);
            self.imageView.transform = rotationTransform;
            
            // Reposition the image view
            [self repositionImageView];
        } completion:^(BOOL finished) {
            
            if (finished)
            {
                // Notification
                if (self.didChangeRotationBlock)
                    self.didChangeRotationBlock(rotation);
                
                // Reposition ratio controls
                [self resetRatioControls];
                
                [UIView animateWithDuration:self.animationDuration animations:^{
                    self.ratioControlsView.alpha = 1.f;
                }];   
            }
        }];
    } else
    {
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotation * M_PI / 2);
        self.imageView.transform = rotationTransform;
        
        // Reposition the image view
        [self repositionImageView];
        
        // Notification
        if (self.didChangeRotationBlock)
            self.didChangeRotationBlock(rotation);
        
        // Reposition ratio controls
        [self resetRatioControls];
    }
}

- (UIImage *)output
{    
    UIImage *rotatedImage = [self rotatedImage:self.imageView.image];
    UIImage *croppedImage = [self croppedImage:rotatedImage];
    
    return croppedImage;
}

#pragma mark - Object Lifecycle

- (void)dealloc
{
    [panGestureRecognizer release];
    
    [ratioViewBorderColor release];
    [ratioView release];
    [overlayView release];
    [ratioControlsView release];
    [imageView release];
    
    [asset release];
    [image release];
    
    [didChangeCropRectBlock release];
    [didChangeRotationBlock release];
    
    [super dealloc];
}

#pragma mark - Designated Initializer

- (void)initialize
{
    // Setup gestures
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    
    animationDuration = 0.5f;
    displayedInstance = nil;
    ratio = 0;
    
    // Creating the image view
    imageView = [[UIImageView alloc] initWithFrame:self.frame];
    imageView.userInteractionEnabled = NO;
    imageView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizesSubviews = YES;
    imageView.autoresizingMask = 
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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
    [ratioView addGestureRecognizer:panGestureRecognizer];
    [ratioControlsView addSubview:ratioView];
    
    [self addSubview:ratioControlsView];
    
    self.ratioViewBorderColor = [UIColor redColor];
    self.ratioViewBorderWidth = 1.f;
    
    [self showOrHideTheRatioControls];
}

- (id)initWithAsset:(ALAsset *)theAsset image:(UIImage *)theImage andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Don't display outside this box
        self.clipsToBounds = YES;
        self.autoresizesSubviews = YES;
        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"transparencyPattern"]];
        
        [self initialize];
        
        self.asset = theAsset;
        self.image = theImage;
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

#pragma mark - Coding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:self.asset forKey:kCodingKeyAsset];
    [aCoder encodeObject:self.image forKey:kCodingKeyImage];
    
    [aCoder encodeObject:self.borderColor forKey:kCodingKeyBorderColor];
    [aCoder encodeFloat:self.borderWidth forKey:kCodingKeyBorderWidth];
    
    [aCoder encodeObject:self.ratioViewBorderColor forKey:kCodingKeyRatioViewBorderColor];
    [aCoder encodeFloat:self.ratioViewBorderWidth forKey:kCodingKeyRatioViewBorderWidth];
    [aCoder encodeFloat:self.ratio forKey:kCodingKeyRatio];
    
    [aCoder encodeInteger:self.rotation forKey:kCodingKeyRotation];
    [aCoder encodeDouble:self.animationDuration forKey:kCodingKeyAnimationDuration];
    
    [aCoder encodeCGRect:self.ratioView.frame forKey:kCodingKeyCropRect];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    // Remove the encoded subviews
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    [self initialize];
    
    self.asset = [aDecoder decodeObjectForKey:kCodingKeyAsset];
    self.image = [aDecoder decodeObjectForKey:kCodingKeyImage];
    
    self.borderColor = [aDecoder decodeObjectForKey:kCodingKeyBorderColor];
    self.borderWidth = [aDecoder decodeFloatForKey:kCodingKeyBorderWidth];
    
    self.ratioViewBorderColor = [aDecoder decodeObjectForKey:kCodingKeyRatioViewBorderColor];
    self.ratioViewBorderWidth = [aDecoder decodeFloatForKey:kCodingKeyRatioViewBorderWidth];
    self.ratio = [aDecoder decodeFloatForKey:kCodingKeyRatio];
    
    self.rotation = [aDecoder decodeIntegerForKey:kCodingKeyRotation];
    self.animationDuration = [aDecoder decodeDoubleForKey:kCodingKeyAnimationDuration];
    
    self.cropRect = [aDecoder decodeCGRectForKey:kCodingKeyCropRect];
    
    return self;
}

#pragma mark - Public

- (void)rotateLeft
{
    [self setRotation:self.rotation - 1 animated:YES];
}

- (void)rotateRight
{
    [self setRotation:self.rotation + 1 animated:YES];
}

#pragma mark - Private

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
    [self resetRatioControls];
}

- (void)repositionImageView
{
    [self.imageView setFrame:CGRectMake(
                                        borderWidth, 
                                        borderWidth, 
                                        self.frame.size.width - (borderWidth * 2), 
                                        self.frame.size.height - (borderWidth * 2))];
}

- (void)resetRatioControls
{
    CGRect actualImageRect = [self imageFrameFromImageViewWithAspectFitMode:self.imageView];
    CGSize imageSizeAfterRotation = CGSizeAbsolute([self sizeForRotatedImage:self.imageView.image]);
    
    if (CGRectEqualToRect(actualImageRect, CGRectZero))
        return;
    
    CGRect frame = CGRectZero;
    CGFloat imageRatio = imageSizeAfterRotation.width / imageSizeAfterRotation.height;
    if (imageRatio > self.ratio) {
        // Width > Height
        frame = CGRectMake(0, 0, self.ratio * actualImageRect.size.height, actualImageRect.size.height);
        ratioViewMovementType = AGMovementTypeHorizontally;
    } else {
        // Height > Width
        frame = CGRectMake(0, 0, actualImageRect.size.width, actualImageRect.size.width / self.ratio);
        ratioViewMovementType = AGMovementTypeVertically;
    }
    
    [self.ratioView setFrame:frame];
    [self.ratioControlsView setFrame:actualImageRect];
    [self.overlayView setFrame:ratioControlsView.bounds];
    
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
                                        self.overlayView.frame.size.height - self.ratioView.frame.origin.y + self.ratioView.frame.size.height));
    maskLayer.path = path;
    
    self.overlayView.layer.mask = maskLayer;
    [maskLayer release];
    CGPathRelease(path);
}

#pragma mark - Calculations

- (CGRect)imageFrameFromImageViewWithAspectFitMode:(UIImageView *)theImageView
{
    if (theImageView.image == nil) {
        return CGRectMake(0, 0, 0, 0);
    }
    
    CGSize imageSize = CGSizeAbsolute([self sizeForRotatedImage:self.imageView.image]);
    
    float imageRatio = imageSize.width / imageSize.height;
    float viewRatio = self.frame.size.width / self.frame.size.height;
    
    if (imageRatio < viewRatio)
    {
        float scale = self.frame.size.height / imageSize.height; 
        float width = scale * imageSize.width;
        float topLeftX = .5 * (self.frame.size.width - width);
        return CGRectMake(topLeftX, 0, width, self.frame.size.height);
    }
    else
    {
        float scale = self.frame.size.width / imageSize.width;
        float height = scale * imageSize.height;
        float topLeftY = .5 * (self.frame.size.height - height);
        return CGRectMake(0, topLeftY, self.frame.size.width, height);
    }
}

#pragma mark - Output

- (CGSize)sizeForRotatedImage:(UIImage *)imageToRotate
{
    if (imageToRotate == nil) {
        return CGSizeMake(0, 0);
    }
    
    CGFloat rotationAngle = self.rotation * M_PI / 2;
    
    CGSize imageSize = imageToRotate.size;
    // Image size after the transformation
    CGSize outputSize = CGSizeApplyAffineTransform(imageSize, CGAffineTransformMakeRotation(rotationAngle));
    
    return outputSize;
}

- (UIImage *)rotatedImage:(UIImage *)imageToRotate
{
    CGFloat rotationAngle = self.rotation * M_PI / 2;
    
    CGSize imageSize = imageToRotate.size;
    // Image size after the transformation
    CGSize outputSize = [self sizeForRotatedImage:imageToRotate];
    CGSize absoluteOutputSize = CGSizeAbsolute(outputSize);
    UIImage *outputImage = nil;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(absoluteOutputSize);
    CGContextRef imageContextRef = UIGraphicsGetCurrentContext();
    
    // Set the anchor point to {0.5, 0.5}
    CGContextTranslateCTM(imageContextRef, .5 * absoluteOutputSize.width, .5 * absoluteOutputSize.height);
    
    // Apply rotation
    CGContextRotateCTM(imageContextRef, rotationAngle);
    
    // Draw the current image
    CGContextScaleCTM(imageContextRef, 1.0, -1.0);
    CGContextDrawImage(imageContextRef, (CGRect) {{-(.5 * imageSize.width), -(.5 * imageSize.height)}, imageSize}, imageToRotate.CGImage);
    
    outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

- (UIImage *)croppedImage:(UIImage *)imageToCrop
{
    CGSize imageSize = imageToCrop.size;
    CGSize scaledImageSize = [self imageFrameFromImageViewWithAspectFitMode:self.imageView].size;
    CGFloat widthFactor = scaledImageSize.width / imageSize.width;
    CGFloat heightFactor = scaledImageSize.height / imageSize.height;
    
    CGRect currentCropRect = self.ratioView.frame;
    CGRect actualCropRect = CGRectMake(
                                       roundf(currentCropRect.origin.x / widthFactor), 
                                       roundf(currentCropRect.origin.y / heightFactor), 
                                       roundf(currentCropRect.size.width / widthFactor), 
                                       roundf(currentCropRect.size.height / heightFactor)
                                       );
    UIImage *outputImage = nil;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(imageToCrop.CGImage, actualCropRect);
    outputImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return outputImage;
}

#pragma mark - Gestures

- (void)panGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self.ratioView];
    CGPoint center = CGPointMake(0, 0);
    
    if (ratioViewMovementType == AGMovementTypeHorizontally)
    {
        // Superview's width minus half of ratio view's width
        CGFloat maxXCenter = self.ratioControlsView.frame.size.width - (self.ratioView.frame.size.width * .5);
        // Half of ratio view's width
        CGFloat minXCenter = (self.ratioView.frame.size.width * .5);
        CGFloat computedXCenter = recognizer.view.center.x + translation.x;
        
        if (computedXCenter < minXCenter) {
            computedXCenter = minXCenter;
        } else if (computedXCenter > maxXCenter) {
            computedXCenter = maxXCenter;
        }
        
        center = CGPointMake(computedXCenter, recognizer.view.center.y);
    } else if (ratioViewMovementType == AGMovementTypeVertically)
    {
        // Superview's height minus half of ratio view's height
        CGFloat maxYCenter = self.ratioControlsView.frame.size.height - (self.ratioView.frame.size.height * .5);
        // Half of ratio view's height
        CGFloat minYCenter = (self.ratioView.frame.size.height * .5);
        CGFloat computedYCenter = recognizer.view.center.y + translation.y;
        
        if (computedYCenter < minYCenter) {
            computedYCenter = minYCenter;
        } else if (computedYCenter > maxYCenter) {
            computedYCenter = maxYCenter;
        }
        
        center = CGPointMake(recognizer.view.center.x, computedYCenter);
    }
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.ratioView];
    [recognizer.view setCenter:center];
    
    // Notification
    if (self.didChangeCropRectBlock)
        self.didChangeCropRectBlock(self.ratioView.frame);
    
    // Reset overlay clipping
    [self overlayClipping];
}

@end
