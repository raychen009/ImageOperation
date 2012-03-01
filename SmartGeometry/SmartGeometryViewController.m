//
//  SmartGeometryViewController.m
//  SmartGeometry
//
//  Created by kwan terry on 11-12-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SmartGeometryViewController.h"
#import "BroadView.h"

@implementation SmartGeometryViewController

@synthesize arrayAbandonedStrokes,arrayStrokes;
@synthesize currentColor,currentSize;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    BroadView* broadView = [[BroadView alloc]initWithFrame:CGRectMake(0.0, 0.0, 1024, 748)];
    [self.view addSubview:broadView];
    [broadView viewJustLoaded];
    broadView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    broadView.owner = self;
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation==UIInterfaceOrientationLandscapeLeft || interfaceOrientation==UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
    
    [arrayStrokes release];
    [arrayAbandonedStrokes release];
    [currentColor release];
}

@end
