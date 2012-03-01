//
//  SCLineGraph.m
//  SmartGeometry
//
//  Created by kwan terry on 11-12-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SCLineGraph.h"
#import "Threshold.h"

@implementation SCLineGraph

@synthesize hasEnd,hasStart;
@synthesize lineUnit;

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
        self.graphType = Line_Graph;
    }
    
    return self;
}

-(id)initWithLine:(LineUnit *)lineUnit1 andId:(int)temp_local_graph_id
{
    [self init];
    
    lineUnit = [[LineUnit alloc]init];
    lineUnit = lineUnit1;
    hasEnd = hasStart = NO;
    
    return self;
}

-(void)drawWithContext:(CGContextRef)context
{
    NSLog(@"start:%f,%f",lineUnit.start.x,lineUnit.start.y);
    NSLog(@"end:%f,%f",lineUnit.end.x,lineUnit.end.y);
    
    [self.lineUnit drawWithContext:context];
    
    CGContextSetRGBFillColor(context, 0.0f, 0.0f, 1.0f, 1.0f);
    CGContextFillEllipseInRect(context, CGRectMake(lineUnit.start.x-5.0f,lineUnit.start.y-5.0f, 10.0f, 10.0f));
    CGContextFillEllipseInRect(context, CGRectMake(lineUnit.end.x-5.0f, lineUnit.end.y-5.0f, 10.0f, 10.0f));
}

-(void)recognizeConstraint:(NSMutableArray *)plist
{
    for(int i=0; i<plist.count; i++)
    {
        SCPointGraph* pointTemp = [plist objectAtIndex:i];
        if([Threshold Distance:lineUnit.start :pointTemp.pointUnit.start] <= is_point_connection)
        {
            [lineUnit setstart:pointTemp.pointUnit.start];
            self.hasStart = YES;
            pointTemp.is_vertex = YES;
            [self constructConstraintGraph1:self Type1:Start_Vertex_Of_Line Graph2:pointTemp Type2:Start_Vertex_Of_Line];
            
        }
        else if([Threshold Distance:lineUnit.end :pointTemp.pointUnit.start] <= is_point_connection)
        {
            [lineUnit setend:pointTemp.pointUnit.start];
            self.hasEnd = YES;
            pointTemp.is_vertex = YES;
            [self constructConstraintGraph1:self Type1:End_Vertex_Of_Line Graph2:pointTemp Type2:End_Vertex_Of_Line];
            
        }
    }
    if(hasStart && hasEnd)
    {
        return;
    }
    else
    {
        for(int i=0; i<plist.count; i++)
        {
            float length_of_line = [Threshold Distance:lineUnit.start :lineUnit.end];
            SCPointGraph* pointTemp = [plist objectAtIndex:i];
            if(([Threshold pointToLine:pointTemp :self] <= is_point_on_lines)
               && ([Threshold Distance:lineUnit.start :pointTemp.pointUnit.start] <= length_of_line)
               && ([Threshold Distance:lineUnit.end :pointTemp.pointUnit.start] <= length_of_line)
               && ([Threshold Distance:lineUnit.start :pointTemp.pointUnit.start] >= is_point_connection)
               && ([Threshold Distance:lineUnit.end :pointTemp.pointUnit.start] >= is_point_connection))
            {
                if(hasEnd && (!hasStart))
                {
                    [self adjustVertex:pointTemp.pointUnit.start :0];
                }
                else
                {
                    [self adjustVertex:pointTemp.pointUnit.start :1];
                }
                pointTemp.is_on_line = true;
                pointTemp.freedomType++;
                [self constructConstraintGraph1:self Type1:Point_On_Line Graph2:pointTemp Type2:Point_On_Line];
            }
        }
    }
}

-(void)adjustVertex:(SCPoint *)point :(int)num
{
//    float length = [Threshold Distance:lineUnit.start :lineUnit.end];
//    if(num == 0)
//    {
//        SCPoint* a = [[SCPoint alloc]initWithX:lineUnit.start.x-lineUnit.end.x andY:lineUnit.start.y-lineUnit.end.y];
//        SCPoint* b = [[SCPoint alloc]initWithX:point.x-lineUnit.start.x andY:point.y-lineUnit.start.y];
//        
//        //if()
//    }
}

@end
