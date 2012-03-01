//
//  GraphImageView.h
//  SmartGeometry
//
//  Created by kwan terry on 12-3-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphImageView : UIImageView
{
    Boolean isGraphSelected;
    CGPoint leftTopPoint;
    CGPoint rightTopPoint; 
    CGPoint leftBottomPoint; 
    CGPoint rightBottomPoint;
    CGAffineTransform transformGraph;
}

@property (readwrite) Boolean isGraphSelected;
@property (readwrite) CGPoint leftTopPoint;
@property (readwrite) CGPoint rightTopPoint;
@property (readwrite) CGPoint leftBottomPoint;
@property (readwrite) CGPoint rightBottomPoint;
@property (readwrite) CGAffineTransform transformGraph;

-(void)drawFrameWithContext:(CGContextRef)context;
-(void)calulateFourCorners;
-(void)initFourCorners;
@end
