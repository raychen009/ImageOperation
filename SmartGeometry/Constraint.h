//
//  Constraint.h
//  SmartGeometry
//
//  Created by kwan terry on 11-12-12.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCGraph.h"
#import "Gunit.h"

@class SCGraph;
@interface Constraint : NSObject
{
    int related_graph_id;
    ConstraintType constraintType;
    SCGraph*       relatedGraph;
}

@property (readwrite) ConstraintType   constraintType;
@property (readwrite) int              related_graph_id;
@property (retain)    SCGraph*         relatedGraph;

@end
