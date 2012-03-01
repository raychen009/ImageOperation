//
//  Threshold.m
//  SmartGeometry
//
//  Created by  on 11-12-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "Threshold.h"
#import <math.h>
//#import "Point_Graph"
//#import "Line_Graph"
//#import "Curve_Graph"

@implementation Threshold

const float PI = 3.14159;

//用于判断是否能成为三角形或四边形的阀值
const float is_closed = 100.0;

//用于判定点是否在其他图形上,TY4.29
const float is_point_connection = 25.0;
const float is_point_on_lines = 15.0;
const float IS_POINT_ON_CIRCLE = 15.0;
const float MAX_K = 2147483647;
const float can_be_adjust = 15.0;

const float IS_SELECT_POINT=35.0;
const float IS_SELECT_LINE=20.0;

const int   point_pix_number=10;
const float judge_line_value=0.9;   //用于直线判定时的阀值
const float circle_jude=2.0;        //椭圆长短周半径值之比判断为圆的阀值
const float equal_to_zero = 0.01;
const float stander_deviation=0.1;  //判断是否为二次曲线的标准差
const int   draw_circle_increment=500;
const int   cut_line_distance=30;
const int   joined_distance=20;
const float k_equal_minimal=0.98;
const float k_equal_max=1.02;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(float) Distance:(const SCPoint*)p1 :(const SCPoint*)p2
{
    return sqrt((float)((p1.x-p2.x)*(p1.x-p2.x)+(p1.y-p2.y)*(p1.y-p2.y)));
}

+(float) pointToLine:(SCPointGraph *)pointGraph :(SCLineGraph *)lineGraph
{
    SCPoint* point = pointGraph.pointUnit.start;
    LineUnit* lineUnit = lineGraph.lineUnit;
    float distance = 100.0f;
    if(abs(lineUnit.k) > 20000.0)
    {
        distance = (float)abs(point.x - lineUnit.start.x);
    }
    else
    {
        float temp1 = sqrtf(pow(lineUnit.k,2)+1);
        float temp2 = abs(lineUnit.k*point.x - point.y + lineUnit.b);
        distance = temp2/temp1;
    }
    lineUnit = NULL;
    
    return distance;
}

+(float)pointToLIne:(SCPoint *)point :(LineUnit *)lineUnit
{
    float distance = 100.0;
    if(abs(lineUnit.k)>20000.0)
    {
        distance = (float)abs(point.x-lineUnit.start.x);
    }
    else
    {
        float temp1 = sqrtf(powf(lineUnit.k, 2)+1);
        float temp2 = abs(lineUnit.k*point.x - point.y + lineUnit.b);
        
        distance = temp2/temp1;
    }
    return distance;
}

+(float) angle_of_vectors:(SCPoint *)a :(SCPoint *)b
{
    float length1 = a.x*a.x + a.y*a.y;
    float length2 = b.x*b.x + b.y*b.y;
    
    float con_theta = (a.x*b.x+a.y*b.y)/sqrtf(length1*length2);
    
    return acosf(con_theta)*180.0f/PI;
}

@end
