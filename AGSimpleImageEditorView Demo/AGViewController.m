//
//  AGViewController.m
//  AGSimpleImageEditorView Demo
//
//  Created by Artur Grigor on 28.02.2012.
//  Copyright (c) 2012 Universitatea "Babes-Bolyai". All rights reserved.
//

#import "AGViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AGViewController ()

- (void)didChangeRatio:(id)sender;
- (void)arrangeItemsForInterfaceOrientation:(UIInterfaceOrientation)forInterfaceOrientation;

@end

@implementation AGViewController

- (void)dealloc
{
    [simpleImageEditorView release];
    [ratioSegmentedControl release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {   
        simpleImageEditorView = [[AGSimpleImageEditorView alloc] initWithImage:[UIImage imageNamed:@"springboard.jpg"]];
//        simpleImageEditorView = [[AGSimpleImageEditorView alloc] initWithImage:[UIImage imageNamed:@"panorama.jpg"]];
        simpleImageEditorView.borderWidth = 1.f;
        simpleImageEditorView.borderColor = [UIColor darkGrayColor];
        
        ratioSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"None", @"3:2", @"4:3", nil]];
        [ratioSegmentedControl addTarget:self action:@selector(didChangeRatio:) forControlEvents:UIControlEventValueChanged];
        
        [self arrangeItemsForInterfaceOrientation:self.interfaceOrientation];
        [self.view addSubview:simpleImageEditorView];
        [self.view addSubview:ratioSegmentedControl];
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
            ratio = 3./2.;
            break;
            
        case 2:
            ratio = 4./3.;
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
    
    CGRect editorFrame = CGRectMake((width - simpleImageEditorView.frame.size.width) / 2, 20.f, simpleImageEditorView.frame.size.width, simpleImageEditorView.frame.size.height);
    simpleImageEditorView.frame = editorFrame;
    CGRect segmentedFrame = CGRectMake((width - ratioSegmentedControl.frame.size.width) / 2, editorFrame.origin.y + editorFrame.size.height + 20.f, ratioSegmentedControl.frame.size.width, ratioSegmentedControl.frame.size.height);
    ratioSegmentedControl.frame = segmentedFrame;
}

@end
