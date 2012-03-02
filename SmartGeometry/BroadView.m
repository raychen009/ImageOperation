//
//  BroadView.m
//  SmartGeometry
//
//  Created by kwan terry on 11-12-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SmartGeometryViewController.h"
#import "BroadView.h"

@implementation BroadView

@synthesize arrayAbandonedStrokes,arrayStrokes;
@synthesize currentColor,currentSize;
@synthesize undoButton,redoButton,deleteButton;
@synthesize owner;
@synthesize unitList,graphList,newGraphList,pointGraphList,saveGraphList;
@synthesize context;
@synthesize hasDrawed;
@synthesize graphImageView;
@synthesize beginPoint;
@synthesize rotationTransform;
@synthesize translationTransform;
@synthesize scaleTransform;

-(BOOL)isMultipleTouchEnabled 
{
	return YES;
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
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    
    self.currentSize = 5.0f;
    self.currentColor= [UIColor blackColor];
    
    graphImageView = [[GraphImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 200.0f)];
    [graphImageView setCenter:CGPointMake(500.0f, 300.0f)];
    [graphImageView initFourCorners];
    [graphImageView setImage:[UIImage imageNamed:@"0001.png"]];
    [self addSubview:graphImageView];

    rotationTransform = self.transform;
    translationTransform = self.transform;
    scaleTransform = self.transform;
    
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
    UIGraphicsBeginImageContext(graphImageView.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [graphImageView setImage:image];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    beginPoint = [[touches anyObject] locationInView:self];
    
    if(!graphImageView.isGraphSelected)
    {
        if(CGRectContainsPoint(graphImageView.frame, beginPoint))
        {
            graphImageView.isGraphSelected = YES;
            graphImageView.operationType   = Translation;
        }
        else
        {
            graphImageView.isGraphSelected = NO;
            graphImageView.operationType   = Nothing;
        }
    }
    else
    {
        CGRect rotationSelectRect = CGRectMake(graphImageView.rotationPoint.x-9, graphImageView.rotationPoint.y-9, 18, 18);
        CGRect scaleSelectRect[4];
        scaleSelectRect[0] = CGRectMake(graphImageView.leftTopPoint.x-6, graphImageView.leftTopPoint.y-6, 12, 12);
        scaleSelectRect[1] = CGRectMake(graphImageView.rightTopPoint.x-6, graphImageView.rightTopPoint.y-6, 12, 12);
        scaleSelectRect[2] = CGRectMake(graphImageView.rightBottomPoint.x-6, graphImageView.rightBottomPoint.y-6, 12, 12);
        scaleSelectRect[3] = CGRectMake(graphImageView.leftBottomPoint.x-6, graphImageView.leftBottomPoint.y-6, 12, 12);
        if(CGRectContainsPoint(rotationSelectRect, beginPoint))
        {
            graphImageView.operationType = Rotation;
        }
        else if(CGRectContainsPoint(scaleSelectRect[0], beginPoint) ||
                CGRectContainsPoint(scaleSelectRect[1], beginPoint) ||
                CGRectContainsPoint(scaleSelectRect[2], beginPoint) ||
                CGRectContainsPoint(scaleSelectRect[3], beginPoint))
        {
            graphImageView.operationType = Scale;
        }
        else if(CGRectContainsPoint(graphImageView.frame, beginPoint))
        {
            graphImageView.operationType = Translation;
        }
        else 
        {
            graphImageView.isGraphSelected = NO;
            graphImageView.operationType   = Nothing;
        }
        
    }
    
    [self setNeedsDisplay];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject]locationInView:self];
    CGPoint prevPoint = [[touches anyObject]previousLocationInView:self];
    
    if(graphImageView.isGraphSelected && graphImageView.operationType == Rotation)
    {
        CGPoint vector1 = CGPointMake(prevPoint.x-graphImageView.centerPoint.x, prevPoint.y-graphImageView.centerPoint.y);
        CGPoint vector2 = CGPointMake(point.x-graphImageView.centerPoint.x, point.y-graphImageView.centerPoint.y);
        float angle1 = atan2f(vector1.x, vector1.y);
        float angle2 = atan2f(vector2.x, vector2.y);
        float rotationAngle =  -(angle2- angle1);
        self.rotationTransform = CGAffineTransformRotate(self.rotationTransform, rotationAngle);
        graphImageView.transform = self.rotationTransform;
        graphImageView.transformGraph = self.rotationTransform;
        [graphImageView calulateFourCorners];
        
        [self setNeedsDisplay];
        return;
    }
    if(graphImageView.isGraphSelected && graphImageView.operationType == Translation)
    {
        CGPoint vector = CGPointMake(point.x-prevPoint.x, point.y-prevPoint.y);
        self.translationTransform = CGAffineTransformConcat(self.translationTransform, CGAffineTransformMakeTranslation(vector.x, vector.y));
        graphImageView.transform = self.translationTransform;
        graphImageView.transformGraph = self.translationTransform;
        [graphImageView calulateFourCorners];
        
        [self setNeedsDisplay];
        return;
    }
    if(graphImageView.isGraphSelected && graphImageView.operationType == Scale)
    {
        CGPoint vector1 = CGPointMake(prevPoint.x-graphImageView.centerPoint.x, prevPoint.y-graphImageView.centerPoint.y);
        CGPoint vector2 = CGPointMake(point.x-graphImageView.centerPoint.x, point.y-graphImageView.centerPoint.y);
        float len1 = sqrtf(vector1.x*vector1.x + vector1.y*vector1.y);
        float len2 = sqrtf(vector2.x*vector2.x + vector2.y*vector2.y);
        float scaleFactor = len2/len1;
        CGPoint scaleFactor1 = CGPointMake(fabs(vector2.x/vector1.x), fabs(vector2.y/vector1.y));
//        self.scaleTransform = CGAffineTransformScale(self.scaleTransform, scaleFactor.x, scaleFactor.y);
//        self.scaleTransform = CGAffineTransformConcat(self.scaleTransform, CGAffineTransformMakeScale(scaleFactor,scaleFactor));
        self.scaleTransform = CGAffineTransformScale(self.scaleTransform, scaleFactor, scaleFactor);
        graphImageView.transform = self.scaleTransform;
        graphImageView.transformGraph = self.scaleTransform;
        [graphImageView calulateFourCorners];
        
        [self setNeedsDisplay];
        return;
    }
    
    
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.rotationTransform = graphImageView.transform;
    self.translationTransform = graphImageView.transform;
    self.scaleTransform = graphImageView.transform;
    
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
