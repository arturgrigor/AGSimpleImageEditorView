//
//  AGViewController.m
//  AGSimpleImageEditorView Demo
//
//  Created by Artur Grigor on 28.02.2012.
//  Copyright (c) 2012 Artur Grigor. All rights reserved.
//

#import "AGViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AGViewController ()

- (void)saveImage;

- (void)rotateLeft:(id)sender;
- (void)rotateRight:(id)sender;

- (void)didChangeRatio:(id)sender;
- (void)arrangeItemsForInterfaceOrientation:(UIInterfaceOrientation)forInterfaceOrientation;

@end

@implementation AGViewController

- (void)dealloc
{
    [simpleImageEditorView release];
    [ratioSegmentedControl release];
    [rotateLeftButton release], [rotateRightButton release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {   
//        simpleImageEditorView = [[AGSimpleImageEditorView alloc] initWithImage:[UIImage imageNamed:@"springboard.jpg"]];
        simpleImageEditorView = [[AGSimpleImageEditorView alloc] initWithImage:[UIImage imageNamed:@"apple.jpg"]];
//        simpleImageEditorView = [[AGSimpleImageEditorView alloc] init];
//        simpleImageEditorView.image = [UIImage imageNamed:@"apple.jpg"];
        simpleImageEditorView.borderWidth = 1.f;
        simpleImageEditorView.borderColor = [UIColor darkGrayColor];
        simpleImageEditorView.ratioViewBorderWidth = 3.f;
        
        ratioSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"None", @"4:3", @"3:2", @"16:10", @"18:10", nil]];
        [ratioSegmentedControl addTarget:self action:@selector(didChangeRatio:) forControlEvents:UIControlEventValueChanged];
        
        rotateLeftButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [rotateLeftButton setTitle:@"<-" forState:UIControlStateNormal];
        [rotateLeftButton addTarget:self action:@selector(rotateLeft:) forControlEvents:UIControlEventTouchUpInside];
        rotateRightButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [rotateRightButton setTitle:@"->" forState:UIControlStateNormal];
        [rotateRightButton addTarget:self action:@selector(rotateRight:) forControlEvents:UIControlEventTouchUpInside];
        
        [self arrangeItemsForInterfaceOrientation:self.interfaceOrientation];
        [self.view addSubview:simpleImageEditorView];
        [self.view addSubview:ratioSegmentedControl];
        [self.view addSubview:rotateLeftButton];
        [self.view addSubview:rotateRightButton];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    [self arrangeItemsForInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Private

- (void)didChangeRatio:(id)sender
{
    CGFloat ratio = 0;
    switch (ratioSegmentedControl.selectedSegmentIndex) {
        case 1:
            ratio = 4./3.;
            break;
            
        case 2:
            ratio = 3./2.;
            break;
            
        case 3:
            ratio = 16./10.;
            break;
            
        case 4:
            ratio = 18./10.;
            break;
    }
    
    simpleImageEditorView.ratio = ratio;
}

- (void)arrangeItemsForInterfaceOrientation:(UIInterfaceOrientation)forInterfaceOrientation
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat width = bounds.size.width, height = bounds.size.height;
    
    if (UIInterfaceOrientationIsLandscape(forInterfaceOrientation)) {
        width = bounds.size.height;
        height = bounds.size.width;
    }
    
    CGRect segmentedFrame = CGRectMake(
                                       (width - ratioSegmentedControl.frame.size.width) / 2, 
                                       height - ratioSegmentedControl.frame.size.height - (20.f * 2), 
                                       ratioSegmentedControl.frame.size.width, 
                                       ratioSegmentedControl.frame.size.height);
    ratioSegmentedControl.frame = segmentedFrame;
    CGRect editorFrame = CGRectMake(20.f, 20.f, width - (20.f * 2), segmentedFrame.origin.y - (20.f * 2));
    simpleImageEditorView.frame = editorFrame;
    
    rotateLeftButton.frame = CGRectMake(20.f, segmentedFrame.origin.y, 40.f, 44.f);
    rotateRightButton.frame = CGRectMake(width - 20.f - 40.f, segmentedFrame.origin.y, 40.f, 44.f);
}

- (void)rotateLeft:(id)sender
{
    [simpleImageEditorView rotateLeft];
}

- (void)rotateRight:(id)sender
{
    [simpleImageEditorView rotateRight];
}

- (void)saveImage
{
    NSData *data = UIImageJPEGRepresentation(simpleImageEditorView.output, 1);
    [data writeToFile:@"/Users/arturgrigor/Documents/image.jpg" atomically:YES];
}

@end
