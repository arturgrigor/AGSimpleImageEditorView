//
//  AGSimpleImageEditorView.h
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

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

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

- (id)initWithAsset:(ALAsset *)theAsset;
- (id)initWithImage:(UIImage *)theImage;

- (void)rotateLeft;
- (void)rotateRight;

@end
