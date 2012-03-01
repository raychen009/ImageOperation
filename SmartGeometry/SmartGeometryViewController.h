//
//  SmartGeometryViewController.h
//  SmartGeometry
//
//  Created by kwan terry on 11-12-10.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BroadView.h"

@interface SmartGeometryViewController : UIViewController<MFMailComposeViewControllerDelegate>
{
    NSMutableArray* arrayStrokes;
    NSMutableArray* arrayAbandonedStrokes;
    
    UIColor* currentColor;
    float    currentSize;
}

@property (retain)      NSMutableArray* arrayStrokes;
@property (retain)      NSMutableArray* arrayAbandonedStrokes;
@property (retain)      UIColor*        currentColor;
@property (readwrite)   float           currentSize;

@end
