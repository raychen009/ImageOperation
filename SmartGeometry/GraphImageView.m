//
//  GraphImageView.m
//  SmartGeometry
//
//  Created by kwan terry on 12-3-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "GraphImageView.h"

@implementation GraphImageView

@synthesize isGraphSelected;
@synthesize leftTopPoint,leftBottomPoint,rightTopPoint,rightBottomPoint;
@synthesize transformGraph;

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
    }
    
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {

    }
    return self;
}

-(void)initFourCorners
{
    leftTopPoint  = CGPointMake(self.frame.origin.x, self.frame.origin.y);
    rightTopPoint = CGPointMake(self.frame.origin.x+self.frame.size.width, self.frame.origin.y);
    leftBottomPoint = CGPointMake(self.frame.origin.x, self.frame.origin.y+self.frame.size.height);
    rightBottomPoint = CGPointMake(self.frame.origin.x+self.frame.size.width, self.frame.origin.y+self.frame.size.height);
}

-(void)calulateFourCorners
{
    if(!CGAffineTransformEqualToTransform(self.transformGraph, self.transform))
    {
        self.transformGraph = self.transform;
        CGPoint centerPoint = self.center;
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-centerPoint.x, -centerPoint.y);
        transform = CGAffineTransformConcat(transform, self.transformGraph);
        CGAffineTransform transform1 = CGAffineTransformMakeTranslation(centerPoint.x, centerPoint.y);
        transform = CGAffineTransformConcat(transform, transform1);
        
        leftTopPoint     = CGPointApplyAffineTransform(leftTopPoint, transform);
        rightTopPoint    = CGPointApplyAffineTransform(rightTopPoint, transform);
        rightBottomPoint = CGPointApplyAffineTransform(rightBottomPoint, transform);
        leftBottomPoint  = CGPointApplyAffineTransform(leftBottomPoint, transform);
    }
}

-(void)drawFrameWithContext:(CGContextRef)context
{    
    [self calulateFourCorners];
    for (int i=0; i<4; i++) 
    {
        CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextSetLineWidth(context, 1.0f);
        switch(i)
        {
            case 0:
            {
                
                CGContextMoveToPoint(context, leftTopPoint.x, leftTopPoint.y);
                CGContextAddLineToPoint(context, rightTopPoint.x, rightTopPoint.y);
                CGContextStrokePath(context);
                break;
            }
            case 1:
            {
                CGContextMoveToPoint(context, rightTopPoint.x, rightTopPoint.y);
                CGContextAddLineToPoint(context, rightBottomPoint.x, rightBottomPoint.y);
                CGContextStrokePath(context);
                break;
            }
            case 2:
            {
                CGContextMoveToPoint(context, rightBottomPoint.x, rightBottomPoint.y);
                CGContextAddLineToPoint(context, leftBottomPoint.x, leftBottomPoint.y);
                CGContextStrokePath(context);
                break;
            }
            case 3:
            {
                CGContextMoveToPoint(context, leftBottomPoint.x, leftBottomPoint.y);
                CGContextAddLineToPoint(context, leftTopPoint.x, leftTopPoint.y);
                CGContextStrokePath(context);
                break;
            }
        }
    }
}

@end
