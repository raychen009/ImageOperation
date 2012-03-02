//
//  GraphImageView.h
//  SmartGeometry
//
//  Created by kwan terry on 12-3-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    Translation = 0,
    Scale       = 1,
    Rotation    = 2,
    Nothing     = 3
}OperationType;

@interface GraphImageView : UIImageView
{
    Boolean isGraphSelected;
    CGPoint leftTopPoint;
    CGPoint rightTopPoint; 
    CGPoint leftBottomPoint; 
    CGPoint rightBottomPoint;
    CGPoint rotationPoint;
    CGPoint centerPoint;
    CGAffineTransform transformGraph;
    OperationType operationType;
    
    CGPoint point1,point2,point3,point4,point5;
}

@property (readwrite) Boolean isGraphSelected;
@property (readwrite) CGPoint leftTopPoint;
@property (readwrite) CGPoint rightTopPoint;
@property (readwrite) CGPoint leftBottomPoint;
@property (readwrite) CGPoint rightBottomPoint;
@property (readwrite) CGPoint rotationPoint;
@property (readwrite) CGPoint centerPoint;
@property (readwrite) OperationType operationType;
@property (readwrite) CGAffineTransform transformGraph;
@property (readwrite) CGPoint point1;
@property (readwrite) CGPoint point2;
@property (readwrite) CGPoint point3;
@property (readwrite) CGPoint point4;
@property (readwrite) CGPoint point5;

-(void)drawFrameWithContext:(CGContextRef)context;
-(void)calulateFourCorners;
-(void)initFourCorners;
@end
