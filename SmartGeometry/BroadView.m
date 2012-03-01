//
//  BroadView.m
//  SmartGeometry
//
//  Created by kwan terry on 11-12-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SmartGeometryViewController.h"
#import "BroadView.h"
#import "SCPoint.h"
#import "PenInfo.h"
#import "Threshold.h"
#import "UnitFactory.h"

@implementation BroadView

@synthesize arrayAbandonedStrokes,arrayStrokes;
@synthesize currentColor,currentSize;
@synthesize undoButton,redoButton,deleteButton;
@synthesize owner;
@synthesize unitList,graphList,newGraphList,pointGraphList,saveGraphList;
@synthesize context;
@synthesize factory;
@synthesize hasDrawed;
@synthesize graphImageView;

-(BOOL)isMultipleTouchEnabled {
	return NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
    }
    return self;
}

-(void) viewJustLoaded 
{
    //NSLog(@"%d",111);
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    
    self.currentSize = 5.0f;
    self.currentColor= [UIColor blackColor];
    
    graphImageView = [[GraphImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 200.0f)];
    [graphImageView setCenter:CGPointMake(1024/2.0f, 768/2.0f)];
    [graphImageView initFourCorners];
    [graphImageView setImage:[UIImage imageNamed:@"0001.png"]];
    [self addSubview:graphImageView];
    graphImageView.transform = CGAffineTransformMakeTranslation(-100, -100);
}

-(void)undoFunc:(id)sender
{
    if ([arrayStrokes count]>0)
    {
		NSMutableDictionary* dictAbandonedStroke = [arrayStrokes lastObject];
		[self.arrayAbandonedStrokes addObject:dictAbandonedStroke];
		[self.arrayStrokes removeLastObject];
		[self setNeedsDisplay];
    }
    
    if([graphList count] != 0)
    {
        [saveGraphList addObject:[graphList lastObject]];
        [graphList removeLastObject];
    }
    [self setNeedsDisplay];
    
}

-(void)redoFunc:(id)sender
{
    if ([arrayAbandonedStrokes count]>0) 
    {
		NSMutableDictionary* dictReusedStroke = [arrayAbandonedStrokes lastObject];
		[self.arrayStrokes addObject:dictReusedStroke];
		[self.arrayAbandonedStrokes removeLastObject];
		[self setNeedsDisplay];
	}
    
    if([saveGraphList count] != 0)
    {
        [graphList addObject:[saveGraphList lastObject]];
        [saveGraphList removeLastObject];
    }
    [self setNeedsDisplay];
    
    
}

-(void)deleteFunc:(id)sender
{
//    [self.arrayStrokes removeAllObjects];
//    [self.arrayAbandonedStrokes removeAllObjects];
    
    UIGraphicsBeginImageContext(graphImageView.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [graphImageView setImage:image];
    
//    UIImageView* imageView = [[UIImageView alloc]init];
//    [imageView setFrame:CGRectMake(0, 0, 500, 500)];
//    [imageView setImage:image];
//    [self addSubview:imageView];
    
//    [self setNeedsDisplay];
    
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    CGPoint point = [[touches anyObject] locationInView:self];
    
    if(CGRectContainsPoint(graphImageView.frame, point))
    {
        graphImageView.isGraphSelected = YES;
    }
    else
    {
        graphImageView.isGraphSelected = NO;
    }
    [self setNeedsDisplay];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject]locationInView:self];
    CGPoint prevPoint = [[touches anyObject]previousLocationInView:self];
    [self setNeedsDisplay];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setNeedsDisplay];
}


-(void)drawRect:(CGRect)rect
{
    context = UIGraphicsGetCurrentContext();
    if(graphImageView.isGraphSelected)
    {
        [graphImageView drawFrameWithContext:context];
    }
}

-(void)dealloc
{
    [super dealloc];
    
    [arrayStrokes release];
    [arrayAbandonedStrokes release];
    
    [currentColor release];
}

@end
