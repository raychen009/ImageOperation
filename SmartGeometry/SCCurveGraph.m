//
//  SCCurveGraph.m
//  SmartGeometry
//
//  Created by kwan terry on 12-1-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SCCurveGraph.h"

@implementation SCCurveGraph

@synthesize curveUnit;

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
        curveUnit = [[CurveUnit alloc]init];
        [self initWithId:-1];
        self.graphType = Curver_Graph;
    }
    
    return self;
}

-(id)initWithCurveUnit:(CurveUnit *)curveUnitLocal ID:(int)tempLocalGraphID
{
    //如果需要初始化派生类中的新增数据成员，请在此函数
    [self init];
    curveUnit = curveUnitLocal;
    graphType = Curver_Graph;
    
    return self;
}

-(void)setOrigalMajorMinorAxis
{
    [curveUnit setOriginalMajorAndOriginalMinor];
}

-(void)getCurveUnitByUnit:(CurveUnit *)tempCurveUnit
{
    tempCurveUnit = curveUnit;
}

-(void)drawWithContext:(CGContextRef)context
{
    [curveUnit drawWithContext:context];
}


@end
