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
@synthesize leftTopPoint,leftBottomPoint,rightTopPoint,rightBottomPoint,rotationPoint;
@synthesize transformGraph;
@synthesize operationType;
@synthesize point1,point2,point3,point4;
@synthesize centerPoint,point5;

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
        operationType = Nothing;
        isGraphSelected = NO;
        self.transformGraph = self.transform;
    }
    return self;
}

-(void)initFourCorners
{
    leftTopPoint  = CGPointMake(self.frame.origin.x, self.frame.origin.y);
    rightTopPoint = CGPointMake(self.frame.origin.x+self.frame.size.width, self.frame.origin.y);
    leftBottomPoint = CGPointMake(self.frame.origin.x, self.frame.origin.y+self.frame.size.height);
    rightBottomPoint = CGPointMake(self.frame.origin.x+self.frame.size.width, self.frame.origin.y+self.frame.size.height);
    centerPoint = self.center;
    CGPoint middlePoint = CGPointMake((leftTopPoint.x+rightTopPoint.x)/2, (leftTopPoint.y+rightTopPoint.y)/2);
    rotationPoint = CGPointMake(3*middlePoint.x/2-self.center.x/2, 3*middlePoint.y/2-self.center.y/2);
    
    point1 = leftTopPoint;
    point2 = rightTopPoint;
    point3 = leftBottomPoint;
    point4 = rightBottomPoint;
    point5 = self.center;
    
}

-(void)calulateFourCorners
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-self.center.x, -self.center.y);
    transform = CGAffineTransformConcat(transform, self.transformGraph);
    CGAffineTransform transform1 = CGAffineTransformMakeTranslation(self.center.x, self.center.y);
    transform = CGAffineTransformConcat(transform, transform1);
    
    leftTopPoint     = CGPointApplyAffineTransform(point1, transform);
    rightTopPoint    = CGPointApplyAffineTransform(point2, transform);
    rightBottomPoint = CGPointApplyAffineTransform(point4, transform);
    leftBottomPoint  = CGPointApplyAffineTransform(point3, transform);
    centerPoint = CGPointApplyAffineTransform(point5, transform);
    
    CGPoint middlePoint = CGPointMake((leftTopPoint.x+rightTopPoint.x)/2, (leftTopPoint.y+rightTopPoint.y)/2);
    rotationPoint = CGPointMake(3*middlePoint.x/2-centerPoint.x/2, 3*middlePoint.y/2-centerPoint.y/2);
}

-(void)drawFrameWithContext:(CGContextRef)context
{    
//    [self calulateFourCorners];
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
    UIImage* pointImage = [UIImage imageNamed:@"controlPointScale.png"];
    [pointImage drawAtPoint:CGPointMake(leftTopPoint.x-6, leftTopPoint.y-6)];
    [pointImage drawAtPoint:CGPointMake(rightTopPoint.x-6, rightTopPoint.y-6)];
    [pointImage drawAtPoint:CGPointMake(rightBottomPoint.x-6, rightBottomPoint.y-6)];
    [pointImage drawAtPoint:CGPointMake(leftBottomPoint.x-6, leftBottomPoint.y-6)];
    
    CGPoint middlePoint = CGPointMake((leftTopPoint.x+rightTopPoint.x)/2, (leftTopPoint.y+rightTopPoint.y)/2);
    CGContextMoveToPoint(context, middlePoint.x, middlePoint.y);
    CGContextAddLineToPoint(context, rotationPoint.x, rotationPoint.y);
    CGContextStrokePath(context);
    pointImage = [UIImage imageNamed:@"controlPointRotation.png"];
    [pointImage drawAtPoint:CGPointMake(rotationPoint.x-9, rotationPoint.y-9)];
    
}

@end
