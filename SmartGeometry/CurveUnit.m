//
//  CurveUnit.m
//  SmartGeometry
//
//  Created by kwan terry on 12-1-6.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CurveUnit.h"

@implementation CurveUnit

@synthesize aFactor,bFactor,cFactor,dFactor,eFactor,fFactor;
@synthesize alpha,originalAlpha;
@synthesize majorAxis,minorAxis,originalMajor,originalMinor;
@synthesize startAngle,endAngle;
@synthesize isAntiClockCurve,isEllipse,isCompleteCurve,isHalfCurve,isArcGroup,isSplineGroup;
@synthesize isXDecrease,isXIncrease,isYDecrease,isYIncrease,hasSecondJudge;
@synthesize curveType;
@synthesize center,move,f1,f2,testE,testS;
@synthesize curveTrack,newDrawPointList,newSpecialPointList,arcIndexArray,arcUnitArray,artBoolArray,newDrawSecCurveTrack;
@synthesize px,py,ph,psx;

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialization code here.
        isAntiClockCurve = YES;
        isArcGroup = NO;
        isSplineGroup = NO;
        isXIncrease = NO;
        isXDecrease = NO;
        isYIncrease = NO;
        isYDecrease = NO;
        
        center = [[SCPoint alloc]init];
        move   = [[SCPoint alloc]init];
//        self.start  = [[SCPoint alloc]init];
//        self.end    = [[SCPoint alloc]init];
        f1     = [[SCPoint alloc]init];
        f2     = [[SCPoint alloc]init];
        testS  = [[SCPoint alloc]init];
        testE  = [[SCPoint alloc]init];
        curveTrack = [[NSMutableArray alloc]init];
        newDrawPointList = [[NSMutableArray alloc]init];
        newSpecialPointList = [[NSMutableArray alloc]init];
        arcIndexArray = [[NSMutableArray alloc]init];
        arcUnitArray = [[NSMutableArray alloc]init];
        arcBoolArray = [[NSMutableArray alloc]init];
        newDrawSecCurveTrack = [[NSMutableArray alloc]init];
    }
    
    return self;
}

-(id)initWithSPoint:(SCPoint *)startPoint EPoint:(SCPoint *)endPoint
{
    [self init];
    [self initWithStartPoint:startPoint endPoint:endPoint];
    
    curveType       = 1;
    self.type            = 2;
    
    isHalfCurve     = NO;
    isCompleteCurve = NO;
    hasSecondJudge  = NO;
    self.isSelected = NO;
    
    return self;
}

-(id)initWithAFactor:(float)a BFactor:(float)b CFactor:(float)c DFactor:(float)d EFactor:(float)e FFactor:(float)f
{
    [self init];
    
    curveType   = 1;//椭圆或圆形类型
    self.type        = 2;//二次曲线类型
    
    aFactor     = a;
    bFactor     = b;
    cFactor     = c;
    dFactor     = d;
    eFactor     = e;
    fFactor     = f;
    
    isHalfCurve     = NO;
    isCompleteCurve = NO;
    hasSecondJudge  = NO;
    self.isSelected = NO;
    
    return self;
}

-(id)initWithPointArray:(NSMutableArray *)pointList ID:(int)idNum
{
    [self init];
    
    self.type = 2;       //二次曲线类型
    curveType = 1;  //椭圆或圆形类型
    
    SCPoint* tempStart = [pointList objectAtIndex:0];
    self.start.x = tempStart.x;
    self.start.y = tempStart.y;
    
    SCPoint* tempEnd = [pointList lastObject];
    self.end.x = tempEnd.x;
    self.end.y = tempEnd.y;
    
    isHalfCurve = NO;
    isCompleteCurve = NO;
    self.isSelected = NO;
    
    float xArray[6] = {0};
    [self identifyWithPointArray:pointList XArray:xArray];
    [self judgeCurveWithPointArray:pointList];
    free(xArray);
    
    hasSecondJudge = NO;
    
    curveTrack = pointList;
    
    return self;
}

-(id)initWithPointArray:(NSMutableArray *)pointList
{
    [self init];
    
    self.type = 2;       //二次曲线类型
    curveType = 1;  //椭圆或圆形类型
    
    SCPoint* tempPoint = [[SCPoint alloc]init];
    if(pointList.count != 0)
    {
        tempPoint = [pointList objectAtIndex:0];
        self.start.x = tempPoint.x;
        self.start.y = tempPoint.y;
        tempPoint = [pointList objectAtIndex:pointList.count-1];
        self.end.x   = tempPoint.x;
        self.end.y   = tempPoint.y;
        
        isHalfCurve     = NO;
        isCompleteCurve = NO;
        hasSecondJudge  = NO;
        self.isSelected = NO;
        
        float xArray[6];
        [self identifyWithPointArray:pointList XArray:xArray];
        free(xArray);
        
        curveTrack = pointList;
        
        testS.x = self.start.x;
        testS.y = self.start.y;
        testE.x = self.end.x;
        testE.y = self.end.y;
        
    }
    
    return self;
}

-(void)judgeCurveWithPointArray:(NSMutableArray *)pointList
{
    if([self isSecondDegreeCurveWithPointArray:pointList])
    {
        //是二次曲线
        [self convertToStandardCurve];      //化简为标准方程
        float totalLength = 0.0f;
        int count = pointList.count;
        for(int i=1; i<count; i++)
        {
            totalLength += [self calculateDistanceWithPoint1:[pointList objectAtIndex:i] Point2:[pointList objectAtIndex:i-1]];
        }
        if([self calculateDistanceWithPoint1:[pointList objectAtIndex:0] Point2:[pointList objectAtIndex:count-1]] < totalLength*0.1)
        {
            self.end.x = self.start.x;
            self.end.y = self.start.y;
        }
        [self setStartTOEndAntiClockWithPointArray:pointList];
        [self calculateStartAndEndAngle];
        [self calculateNewDrawSecCurveTrack];
    }
    else
    {
        //非二次曲线
        self.type        = 3;
        curveTrack  = pointList;
        [self calculateCubicSplineWithPointList:pointList];
        [self calculateStartAndEndAngle];
    }
}

-(void)setOriginalAlpha
{
    originalAlpha = alpha;
}

-(void)setOriginalMajorAndOriginalMinor
{
    originalMajor = majorAxis;
    originalMinor = minorAxis;
}

-(void)identifyWithPointArray:(NSMutableArray *)pointList XArray:(float[6])xArray
{
    //--------------------------------------
    //二次曲线识别判断
    //--------------------------------------
    //
    //  先构造矩阵
    //  | x(4)y(0) x(3)y(1) x(2)y(2) x(3)y(0) x(2)y(1) x(2)y(0) |
    //  | x(3)y(1) x(2)y(2) x(1)y(3) x(2)y(1) x(1)y(2) x(1)y(1) |
    //  | x(2)y(2) x(1)y(3) x(0)y(4) x(1)y(2) x(0)y(3) x(0)y(2) |
    //  | x(3)y(0) x(2)y(1) x(1)y(2) x(2)y(0) x(1)y(1) x(1)y(0) |
    //  | x(2)y(1) x(1)y(2) x(0)y(3) x(1)y(1) x(0)y(2) x(0)y(1) |
    //
    //  aX^2+bXY+cY^2+dX+eY+f = 0;//椭圆方程
    //  aX^2+bXY+cY^2+dX+eY   = -f;//椭圆方程
    //  x(2)    xy  y(2)    x   y
    
    int count = pointList.count;
    float f = 1000000;
    
    float aArray[5][6];
    float bArray[5][2];
    
    for(int i=0; i<5; i++)
    {
        for(int j=0; j<6; j++)
            aArray[i][j] = 0.0f;
    }
    bArray[0][0]=2;bArray[0][1]=0;
    bArray[1][0]=1;bArray[1][1]=1;
    bArray[2][0]=0;bArray[2][1]=2;
    bArray[3][0]=1;bArray[3][1]=0;
    bArray[4][0]=0;bArray[4][1]=1;
    
    for(int i=0; i<count; i++)      //对于每个点
    {
        SCPoint* pointTemp = [pointList objectAtIndex:i];
        for(int j=0; j<5; j++)      //行
        {
            for(int k=0; k<5; k++)  //列
            {
                aArray[j][k] += powf(pointTemp.x, bArray[j][0]+bArray[k][0]) * powf(pointTemp.y, bArray[j][1]+bArray[k][1]);
            }
        }
    }
    for(int i=0; i<count; i++)
    {
        SCPoint* pointTemp = [pointList objectAtIndex:i];
        for(int j=0; j<5; j++)
        {
            aArray[j][5] -= powf(pointTemp.x, bArray[j][0]) * powf(pointTemp.y, bArray[j][1]) * f;
        }
    }
    
    float xAnswerArray[5] = {0};
    [self gaussianEliminationWithRow:5 Column:5 Matrix:aArray Answer:xAnswerArray];
    for(int i=0; i<5; i++)
    {
        xArray[i] = xAnswerArray[i];
    }
    xArray[5] = f;
    aFactor = xArray[0];
    bFactor = xArray[1];
    cFactor = xArray[2];
    dFactor = xArray[3];
    eFactor = xArray[4];
    fFactor = xArray[5];
    
    free(aArray);
    free(bArray);
    free(xAnswerArray);
    
}

-(void)gaussianEliminationWithRow:(int)row Column:(int)col Matrix:(float [5][6])matrix Answer:(float [5])answer
{
    float aArray[row][col+1];
    //将matrix的值赋值给aArray
    for(int i=0; i<row; i++)
    {
        for(int j=0; j<col+1; j++)
        {
            aArray[i][j] = matrix[i][j];
        }
    }
    //行列式变化，得到阶梯矩阵
    for(int j=0; j<row-1; j++)
    {
        for(int i=j+1; i<row; i++)
        {
            float t = aArray[i][j]/aArray[j][j];
            for(int k=j; k<=col; k++)
            {
                aArray[i][k] -= t*aArray[j][k];
            }
        }
    }
    
    //解阶梯型矩阵
    for(int i=col-1; i>=0; i--)
    {
        float sum = 0;
        for(int j=i+1; j<col; j++)
        {
            sum += answer[j]*aArray[i][j];
        }
        answer[i] = (aArray[i][col] - sum)/aArray[i][i];
    }    
    
    free(aArray);
    return;
}

-(void)convertToStandardCurve
{
    //平移标准化
    float y0 = (2*aFactor*eFactor - bFactor*dFactor)/(bFactor*bFactor - 4*aFactor*cFactor);
    float x0 = -(dFactor + bFactor*y0)/(2*aFactor);
    
    center.x = x0;  //二次曲线中心
    center.y = y0;  //二次曲线中心
    move.x = x0;
    move.y = y0;
    
    fFactor = aFactor*x0*x0 + bFactor*x0*y0 + cFactor*y0*y0 + dFactor*x0 + eFactor*y0 + fFactor;
    dFactor = eFactor = 0.0f;
    
    self.start.x -= center.x;
    self.start.y -= center.y;
    self.end.x   -= center.x;
    self.end.y   -= center.y;
    
    //旋转标准化逆时针旋转
    //  |               |
    //  |   cos     sin |
    //  |   -sin    cos |
    //  |               |
    alpha = atanf((bFactor + 0.00000000001) / (aFactor - cFactor+0.00000000001));
    alpha /= 2.0f;
    originalAlpha = alpha;
    
    float tempA = aFactor;
    float tempB = bFactor;
    float tempC = cFactor;
    
    float cos = cosf(alpha);
    float sin = sinf(alpha);
    aFactor = tempA*cos*cos + tempB*sin*cos + tempC*sin*sin;
    bFactor = (tempC - tempA)*sin*cos + (tempB/2.0)*(cos*cos - sin*sin);
    cFactor = tempA*sin*sin - tempB*sin*cos + tempC*cos*cos;
    
    SCPoint* tempPoint = [[SCPoint alloc]initWithX:self.start.x andY:self.start.y];
    self.start.x = tempPoint.x*cos + tempPoint.y*sin;
    self.start.y = tempPoint.x*(-sin) + tempPoint.y*cos;
    tempPoint.x = self.end.x;
    tempPoint.y = self.end.y;
    self.end.x = tempPoint.x*cos + tempPoint.y*sin;
    self.end.y = tempPoint.x*(-sin) + tempPoint.y*cos;
    
    if(curveType == 1)//圆形或者椭圆
    {
        if(fFactor/aFactor > 0) 
            aFactor = -aFactor;
        if(fFactor/aFactor > 0)
            cFactor = -cFactor;
        //圆形或者椭圆标准化
        float k = aFactor/cFactor;
        if(k > 1.0/circle_jude && k<circle_jude)
        {
            k = (aFactor + cFactor)/2.0;
            aFactor = cFactor = k;
            isEllipse = false;
        }
        else
        {
            isEllipse = true;
        }
        
        //将起点和终点缩放到椭圆上
        k = sqrtf(-fFactor / (aFactor*self.start.x*self.start.x + cFactor*self.start.y*self.start.y));
        self.start.x = self.start.x*k;
        self.start.y = self.start.y*k;
        k = sqrtf(-fFactor / (aFactor*self.end.x*self.end.x + cFactor*self.end.y*self.end.y));
        self.end.x = self.end.x*k;
        self.end.y = self.end.y*k;
            
        majorAxis = sqrt(-fFactor/aFactor);
        minorAxis = sqrtf(-fFactor/cFactor);
    }
    else if(curveType == 2)//双曲线
    {
        if((fFactor/aFactor)<0 && (fFactor/cFactor)>0)
        {
            //x轴方向为虚轴,majorAxis为负
            majorAxis = -sqrtf(-fFactor/aFactor);
            minorAxis = sqrtf(fFactor/cFactor);
            if(self.start.y >= 0)
            {
                self.start.y = sqrtf((majorAxis*majorAxis*minorAxis*minorAxis + minorAxis*minorAxis*self.start.x*self.start.x)/
                                (majorAxis*majorAxis));
            }
            else
            {
                self.start.y = -sqrtf((majorAxis*majorAxis*minorAxis*minorAxis + minorAxis*minorAxis*self.start.x*self.start.x)/
                                 (majorAxis*majorAxis));
            }
            if(self.end.y >= 0)
            {
                self.end.y = sqrtf((majorAxis*majorAxis*minorAxis*minorAxis + minorAxis*minorAxis*self.end.x*self.end.x)/
                              (majorAxis*majorAxis));
            }
            else
            {
                self.end.y = -sqrtf((majorAxis*majorAxis*minorAxis*minorAxis + minorAxis*minorAxis*self.end.x*self.end.x)/
                              (majorAxis*majorAxis));
            }
        }
        if((fFactor/cFactor)<0 && (fFactor/aFactor)>0)
        {
            //y轴方向为虚轴,minorAxis为负
            alpha += PI/2;
            majorAxis = -sqrtf(-fFactor/cFactor);
            minorAxis = sqrtf(fFactor/aFactor);
            
            float tempA = aFactor;
            float tempB = bFactor;
            float tempC = cFactor;
            float cos   = cosf(PI/2);
            float sin   = sinf(PI/2);
            aFactor = tempA*cos*cos + tempB*sin*cos + tempC*sin*sin;
            bFactor = (tempC-tempA)*sin*cos + (tempB/2.0)*(cos*cos-sin*sin);
            cFactor = tempA*sin*sin - tempB*sin*cos + tempC*cos*cos;
            
            SCPoint* tempPoint = [[SCPoint alloc]initWithX:self.start.x andY:self.start.y];
            self.start.x = tempPoint.x*cos + tempPoint.y*sin;
            self.start.y = tempPoint.x*(-sin) + tempPoint.y*cos;
            tempPoint.x = self.end.x;
            tempPoint.y = self.end.y;
            self.end.x = tempPoint.x*cos + tempPoint.y*sin;
            self.end.y = tempPoint.x*(-sin) + tempPoint.y*cos;
            
            [tempPoint release];
            tempPoint = NULL;
            
            if(self.start.y >= 0)
            {
                self.start.y = sqrtf((majorAxis*majorAxis*minorAxis*minorAxis + minorAxis*minorAxis*self.start.x*self.start.x)/
                                (majorAxis*majorAxis));
            }
            else
            {
                self.start.y = -sqrtf((majorAxis*majorAxis*minorAxis*minorAxis + minorAxis*minorAxis*self.start.x*self.start.x)/(majorAxis*majorAxis));
            }
            if(self.end.y >= 0)
            {
                self.end.y = sqrtf((majorAxis*majorAxis*minorAxis*minorAxis + minorAxis*minorAxis*self.end.x*self.end.x)/
                              (majorAxis*majorAxis));
            }
            else
            {
                self.end.y = -sqrtf((majorAxis*majorAxis*minorAxis*minorAxis + minorAxis*minorAxis*self.end.x*self.end.x)/
                               (majorAxis*majorAxis));
            }
            
        }
    }
    [self setOriginalMajorAndOriginalMinor];
    [tempPoint release];
    tempPoint = NULL;
}

-(void)setStartTOEndAntiClockWithPointArray:(NSMutableArray *)pointList
{
    //进行判断，使得Start到End为逆时针方向
    int number = pointList.count;
    int countForNoAnti=0,countForAnti=0;
    SCPoint* firstPoint = [pointList objectAtIndex:0];
    SCPoint* lastPoint  = [pointList objectAtIndex:number-1];
    
    int deltaX = lastPoint.x - firstPoint.x;
    int deltaY = lastPoint.y - firstPoint.y;
    int varyDeltaX,varyDeltaY;
    
    SCPoint* tempPoint;
    float compare10,compareLast;
    
    if(number > 10)
    {
        tempPoint   = [pointList objectAtIndex:0];
        float lineK = (tempPoint.y - center.y)/(tempPoint.x - center.x);
        float lineB = (tempPoint.y - lineK*tempPoint.x);
        
        tempPoint = [pointList objectAtIndex:10];
        compare10 = lineK*tempPoint.x - lineB - tempPoint.y;
        tempPoint = [pointList objectAtIndex:number-1];
        compareLast = lineK*tempPoint.x - lineB - tempPoint.y;
    }
    SCPoint* tempPointAt0 = [pointList objectAtIndex:0];
    for(int i=1; i<number-1; i++)
    {
        tempPoint  = [pointList objectAtIndex:i];
        varyDeltaX = tempPoint.x - tempPointAt0.x;
        varyDeltaY = tempPoint.y - tempPointAt0.y;
        if(deltaX*varyDeltaY > deltaY*varyDeltaX)
        {
            countForNoAnti++;
        }
        else
        {
            countForAnti++;
        }
    }
    if(countForNoAnti > countForAnti)
    {
        SCPoint* tempPoint = [[SCPoint alloc]initWithX:self.start.x andY:self.start.y];
        self.start.x = self.end.x;
        self.start.y = self.end.y;
        
        self.end.x = tempPoint.x;
        self.end.y = tempPoint.y;
        
        isAntiClockCurve = NO;
    }
    
    if(![self hasSecondJudge])
        [self secondJudgeIsCompleteCurveWithPointArray:pointList];
    
}

-(void)calculateNewDrawSecCurveTrack
{
    if(self.type == 2 && curveType == 1)
    {
        [newDrawSecCurveTrack removeAllObjects];
        
        int leftFocusX=0,leftFocusY=0;          //左焦点
        int rightFocusX=0,rightFocusY=0;        //右焦点
        bool ellipseBool = YES;                 //默认是椭圆
        float focusLength = sqrtf(abs(majorAxis*majorAxis - minorAxis*minorAxis));
        if(majorAxis > minorAxis)
        {
            leftFocusX  = (int)focusLength;
            rightFocusX = -(int)focusLength;
        }
        else if(minorAxis == majorAxis)
        {
            ellipseBool = NO;
        }
        else if(majorAxis < minorAxis)
        {
            leftFocusY  = (int)focusLength;
            rightFocusY = -(int)focusLength;
        }
        
        float startAngleLocal,endAngleLocal;
        [self calculateStartAndEndAngleWithStartAngle:startAngleLocal EndAngle:endAngleLocal];
        
        float a = fabsf(majorAxis);
        float b = fabsf(minorAxis);
        
        //计算起始点和终止点后先画出椭圆曲线
        float add = 2*PI/draw_circle_increment;
        float x,y;
        x = (a*cosf(startAngle));
        y = (b*sinf(startAngle));
        [self translateAndRotationWithX:&x Y:&y Theta:alpha Point:[[SCPoint alloc]initWithX:move.x andY:move.y]];
        [newDrawSecCurveTrack addObject:[[SCPoint alloc]initWithX:x andY:y]];
        
        for(float i=startAngle; i<=endAngle; i+=add)
        {
            x = a*cosf(i);
            y = b*sinf(i);
            [self translateAndRotationWithX:&x Y:&y Theta:alpha Point:[[SCPoint alloc]initWithX:move.x andY:move.y]];
            [newDrawSecCurveTrack addObject:[[SCPoint alloc]initWithX:x andY:y]];
        }
    }
}

-(void)makeCurveSmoothToLastCurve:(CurveUnit *)lastCurve
{
    if(lastCurve != NULL)
    {
        //旋转部分先不实现
//        float aimAngle;
//        float originAngle;
//        float lastStartAngle = lastCurve.startAngle;
//        float lastEndAngle   = lastCurve.endAngle;
//        float nowStartAngle  = self.startAngle;
//        float nowEndAngle    = self.endAngle;
//        
//        if(lastCurve.isAntiClockCurve)  //上条曲线是顺时针
//        {
//            aimAngle = lastEndAngle;
//        }
//        else
//        {
//            aimAngle = lastStartAngle;
//        }
//        if(isAntiClockCurve)    //这条曲线是顺时针
//        {
//            originAngle = nowStartAngle;
//        }
//        else
//        {
//            originAngle = nowEndAngle;
//        }
//        float rotateAngle = (aimAngle+lastCurve.alpha) - (originAngle+alpha);
//        for(int i=0; i<[newDrawSecCurveTrack count]; i++)
//        {
//            SCPoint* tempPoint = [newDrawSecCurveTrack objectAtIndex:i];
//            [self rotationWithPoint:tempPoint Theta:rotateAngle];
//        }
        
        
        SCPoint* aimPoint    = [[SCPoint alloc]init];
        SCPoint* originPoint = [[SCPoint alloc]init];
        SCPoint* lastStart   = [lastCurve.newDrawSecCurveTrack objectAtIndex:0];
        SCPoint* lastEnd     = [lastCurve.newDrawSecCurveTrack lastObject];
        SCPoint* nowStart    = [newDrawSecCurveTrack objectAtIndex:0];
        SCPoint* nowEnd      = [newDrawSecCurveTrack lastObject];
        
        if(lastCurve.isAntiClockCurve)  //上条曲线是顺时针
        {
            aimPoint.x = lastEnd.x;
            aimPoint.y = lastEnd.y;
        }
        else
        {
            aimPoint.x = lastStart.x;
            aimPoint.y = lastStart.y;
        }
        if(isAntiClockCurve)    //这条曲线是顺时针
        {
            originPoint.x = nowStart.x;
            originPoint.y = nowStart.y;
        }
        else
        {
            originPoint.x = nowEnd.x;
            originPoint.y = nowEnd.y;
        }
        SCPoint* vector = [[SCPoint alloc]initWithX:aimPoint.x-originPoint.x andY:aimPoint.y-originPoint.y];
        [self translateAndRotationWithPoint:center Theta:0 Point:vector];
        [self setMove:center];
        for(int i=0; i<[newDrawSecCurveTrack count]; i++)
        {
            SCPoint* tempPoint = [newDrawSecCurveTrack objectAtIndex:i];
            tempPoint = [self translateWithPoint:tempPoint Vector:vector];
        }
    }
}

-(NSMutableArray*)findSpecialPointWithPointList:(NSMutableArray*)pointListTemp
{
    newSpecialPointList = [[NSMutableArray alloc]init];
    isXIncrease = NO;
    isXDecrease = NO;
    isYIncrease = NO;
    isYDecrease = NO;
    [arcUnitArray removeAllObjects];
    [arcBoolArray removeAllObjects];
    [arcIndexArray removeAllObjects];
    
    
    NSMutableArray* pointList = [[NSMutableArray alloc]init];
    
    [newSpecialPointList removeAllObjects];
    [pointList addObject:[pointListTemp objectAtIndex:0]];
    for(int i=1; i<[pointListTemp count]-1; i++)
    {
        SCPoint* lastPoint = [pointListTemp objectAtIndex:i-1];
        SCPoint* currentPoint = [pointListTemp objectAtIndex:i];
        if(fabs(lastPoint.x - currentPoint.x) > 1.0f && fabs(lastPoint.y - currentPoint.y) > 1.0f)
        {
            [pointList addObject:currentPoint];
        }
    }
    [pointList addObject:[pointListTemp lastObject]];
    
    for(int i=0; i<[pointList count]-1; i++)
    {
        SCPoint* currentPoint = [pointList objectAtIndex:i];
        SCPoint* nextPoint = [pointList objectAtIndex:i+1];
        if(currentPoint.x < nextPoint.x)
        {
            if(!isXDecrease)
            {
                isXIncrease = YES;
            }
            else
            {
                isXIncrease = NO;
                isXDecrease = NO;
                break;
            }
        }
        if(currentPoint.x > nextPoint.x)
        {
            if(!isXIncrease)
            {
                isXDecrease = YES;
            }
            else
            {
                isXIncrease = NO;
                isXDecrease = NO;
                break;
            }
        }
    }
    
    for(int i=0; i<[pointList count]-1; i++)
    {
        SCPoint* currentPoint = [pointList objectAtIndex:i];
        SCPoint* nextPoint = [pointList objectAtIndex:i+1];
        if(currentPoint.y < nextPoint.y)
        {
            if(!isYDecrease)
            {
                isYIncrease = YES;
            }
            else
            {
                isYIncrease = NO;
                isYDecrease = NO;
                break;
            }
        }
        if(currentPoint.y > nextPoint.y)
        {
            if(!isYIncrease)
            {
                isYDecrease = YES;
            }
            else
            {
                isYIncrease = NO;
                isYDecrease = NO;
                break;
            }
        }
    }
    
    if(isXDecrease || isXIncrease)
    {
        [newSpecialPointList addObject:[pointList objectAtIndex:0]];
        //寻找拐点
        for(int i=1; i<[pointList count]-1; i++)
        {
            SCPoint* lastPoint = [pointList objectAtIndex:i-1];
            SCPoint* currentPoint = [pointList objectAtIndex:i];
            SCPoint* nextPoint = [pointList objectAtIndex:i+1];
            
            if((currentPoint.y < lastPoint.y && currentPoint.y < nextPoint.y) || (currentPoint.y > lastPoint.y && currentPoint.y > nextPoint.y))
            {
                [newSpecialPointList addObject:currentPoint];
            }
        }
        [newSpecialPointList addObject:[pointList lastObject]];  
    }
    else if(isYDecrease || isYIncrease)
    {
        [newSpecialPointList addObject:[pointList objectAtIndex:0]];
        //寻找拐点
        for(int i=1; i<[pointList count]-1; i++)
        {
            SCPoint* lastPoint = [pointList objectAtIndex:i-1];
            SCPoint* currentPoint = [pointList objectAtIndex:i];
            SCPoint* nextPoint = [pointList objectAtIndex:i+1];
            
            if((currentPoint.x < lastPoint.x && currentPoint.x < nextPoint.x) || (currentPoint.x > lastPoint.x && currentPoint.x > nextPoint.x))
            {
                [newSpecialPointList addObject:currentPoint];
            }
        }
        [newSpecialPointList addObject:[pointList lastObject]];
    }
    else
    {
        [newSpecialPointList addObject:[pointList objectAtIndex:0]];
        [arcIndexArray addObject:[[NSNumber alloc]initWithInt:0]];
        [arcBoolArray addObject:[[NSNumber alloc]initWithBool:NO]];
        //寻找拐点
        for(int i=1; i<[pointList count]-1; i++)
        {
            SCPoint* lastPoint = [pointList objectAtIndex:i-1];
            SCPoint* currentPoint = [pointList objectAtIndex:i];
            SCPoint* nextPoint = [pointList objectAtIndex:i+1];
            
            if(!isArcGroup)
            {
                if((currentPoint.y < lastPoint.y && currentPoint.y < nextPoint.y) || (currentPoint.y > lastPoint.y && currentPoint.y > nextPoint.y))
                {
                    [newSpecialPointList addObject:currentPoint];
                    [arcIndexArray addObject:[[NSNumber alloc]initWithInt:i]];
                    [arcBoolArray addObject:[[NSNumber alloc]initWithBool:NO]];
                }
            }
            
            if((currentPoint.x < lastPoint.x && currentPoint.x < nextPoint.x) || (currentPoint.x > lastPoint.x && currentPoint.x > nextPoint.x))
            {
                [newSpecialPointList addObject:currentPoint];
                [arcIndexArray addObject:[[NSNumber alloc]initWithInt:i]];
                [arcBoolArray addObject:[[NSNumber alloc]initWithBool:YES]];
            }
            
        }
        [newSpecialPointList addObject:[pointList lastObject]]; 
        [arcIndexArray addObject:[[NSNumber alloc]initWithInt:[pointList count]-1]];
        [arcBoolArray addObject:[[NSNumber alloc]initWithBool:NO]];
    }
    
    return pointList;
}

-(NSMutableArray*)calculateCubicNewDrawPointList:(NSMutableArray*)newPointList
{
    const int len = [newPointList count];
    float x[len];
    float y[len];
    
    for (int i = 0; i < len; i++)
    {   
        SCPoint* p = [newPointList objectAtIndex:i];
        x[i] = p.x;
        y[i] = p.y;
    }
    
    printf("x:\t");
    for (int i = 0; i < len; i++)
    {
        printf("%.3f\t", x[i]);
    }
    
    printf("\ny:\t");
    for (int i = 0; i < len; i++)
    {
        printf("%.3f\t", y[i]);
    }
    
    float h[len];
    float u[len];
    float lam[len];
    for (int i = 0; i < len-1; i++)
    {
        h[i] = x[i+1] - x[i];
    }    
    
    u[0] = 0;
    lam[0] = 1;
    for (int i = 1; i < (len - 1); i++)
    {
        u[i] = h[i-1]/(h[i] + h[i-1]);
        lam[i] = h[i]/(h[i] + h[i-1]);
    }
    
    float a[len];
    float b[len];
    float c[len];
    
    float m[len][len];
    for (int i = 0; i < len; i++)
    {
        for (int j = 0; j < len; j++)
        {
            m[i][j] = 0;
        }
        if (i == 0)
        {
            m[i][0] = 2;
            m[i][1] = 1;
            
            b[0] = 2;
            c[0] = 1;
        }
        else if (i == (len - 1))
        {
            m[i][len - 2] = 1;
            m[i][len - 1] = 2;
            
            a[len-1] = 1;
            b[len-1] = 2;
        }
        else
        {
            m[i][i-1] = lam[i];
            m[i][i] = 2;
            m[i][i+1] = u[i];
            
            a[i] = lam[i];
            b[i] = 2;
            c[i] = u[i];
        }
    }
    
    float g[len];
    g[0] = 3 * (y[1] - y[0])/h[0];
    g[len-1] = 3 * (y[len - 1] - y[len - 2])/h[len - 2];
    for (int i = 1; i < len - 1; i++)
    {
        g[i] = 3 * ((lam[i] * (y[i] - y[i-1])/h[i-1]) + u[i] * (y[i+1] - y[i])/h[i]);
    }
    
    for (int i = 0; i < len; i++)
    {
        printf("a[%d]: %.3f\n", i, a[i]);
    }
    for (int i = 0; i < len; i++)
    {
        printf("b[%d]: %.3f\n", i, b[i]);
    }
    for (int i = 0; i < len; i++)
    {
        printf("c[%d]: %.3f\n", i, c[i]);
    }
    
    //< Solve the Equations
    float p[len];
    float q[len];
    
    p[0] = b[0];
    for (int i = 0; i < len - 1; i++)
    {
        q[i] = c[i]/p[i];
    }
    
    for (int i = 1; i < len; i++)
    {
        p[i] = b[i] - a[i]*q[i-1];
    }
    
    float su[len];
    float sq[len];
    float sx[len];
    
    su[0] = c[0]/b[0];
    sq[0] = g[0]/b[0];
    for (int i = 1; i < len - 1; i++)
    {
        su[i] = c[i]/(b[i] - su[i-1]*a[i]);
    }
    
    for (int i = 1; i < len; i++)
    {
        sq[i] = (g[i] - sq[i-1]*a[i])/(b[i] - su[i-1]*a[i]);
    }
    
    sx[len-1] = sq[len-1];
    for (int i = len - 2; i >= 0; i--)
    {
        sx[i] = sq[i] - su[i]*sx[i+1];
    }
    
    ph = h;
    px = x;
    psx = sx;
    py = y;
    
    printf("h:");
    for (int i = 0; i < len; i++)
    {
        printf("%.3f\t", ph[i]);
    }
    printf("\n");
    
    printf("x:");
    for (int i = 0; i < len; i++)
    {
        printf("%.3f\t", px[i]);
    }
    printf("\n");
    
    printf("y:");
    for (int i = 0; i < len; i++)
    {
        printf("%.3f\t", py[i]);
    }
    printf("\n");
    
    printf("sx:");
    for (int i = 0; i < len; i++)
    {
        printf("%.3f\t", psx[i]);
    }
    printf("\n");
    
    double (^func)(int k, float vX) = ^(int k, float vX) 
    {
        double p1 =  (ph[k] + 2.0 * (vX - px[k])) * ((vX - px[k+1]) * (vX - px[k+1])) * py[k] / (ph[k] *ph[k] * ph[k]);
        double p2 =  (ph[k] - 2 * (vX - px[k+1])) * powf((vX - px[k]), 2.0f) * py[k+1] / powf(ph[k], 3.0f);
        double p3 =  (vX - px[k]) * powf((vX - px[k+1]), 2.0f) * psx[k] / powf(ph[k], 2.0f);
        double p4 =  (vX - px[k+1]) * powf((vX - px[k]), 2.0f) * psx[k+1] / powf(ph[k], 2.0f);
        
        NSLog(@"!!!!");
        
        return p1 + p2 + p3 + p4;
    };
    
    newDrawPointList = [[NSMutableArray alloc]init];
    
    [newDrawPointList addObject:[newPointList objectAtIndex:0]];
    
    for(int i=1; i<[newPointList count]; i++)
    {
        SCPoint* tempPoint = [newPointList objectAtIndex:i];
        SCPoint* currentPoint = [newPointList objectAtIndex:i-1];
        float delta = 1.0f;
        for (float pointX = currentPoint.x; fabs(pointX - tempPoint.x) > 0.5f;)
        {
            float pointY = func(i-1, pointX);
            SCPoint* newPoint = [[SCPoint alloc]initWithX:pointX andY:pointY];
            [newDrawPointList addObject:newPoint];
            (pointX-tempPoint.x)<0 ? (pointX += delta) : (pointX -= delta);
        }
    }
    [newDrawPointList addObject:[newPointList lastObject]];
    
    return newDrawPointList;
}

-(void)calculateCubicSplineWithPointList:(NSMutableArray *)pointList
{    
    NSMutableArray* newPointList = [self findSpecialPointWithPointList:pointList];
    
    if(isXDecrease || isXIncrease)
    {
        [self calculateCubicNewDrawPointList:newPointList];
    }
    else if(isYDecrease || isYIncrease)
    {
        //转换坐标
        for(int i=0; i<[newPointList count]; i++)
        {
            SCPoint* currentPoint = [newPointList objectAtIndex:i];
            float tempCoordinate = currentPoint.x;
            currentPoint.x = currentPoint.y;
            currentPoint.y = tempCoordinate;
        }
        newDrawPointList = [self calculateCubicNewDrawPointList:newPointList];
        //转换坐标
        for(int i=0; i<[newDrawPointList count]; i++)
        {
            SCPoint* currentPoint = [newDrawPointList objectAtIndex:i];
            float tempCoordinate = currentPoint.x;
            currentPoint.x = currentPoint.y;
            currentPoint.y = tempCoordinate;
        }
    }
    else
    {
        NSMutableArray* tempPointList = [[NSMutableArray alloc]init];
        arcUnitArray = [[NSMutableArray alloc]init];
        
        isArcGroup = YES;
        newPointList = [self findSpecialPointWithPointList:pointList];
        //分解圆弧
        for(int i=1; i<[arcIndexArray count]; i++)
        {
            [tempPointList removeAllObjects];
            
            NSNumber* lastNumber = [arcIndexArray objectAtIndex:i-1];
            int lastIndex = [lastNumber intValue];
            
            NSNumber* currentNumber = [arcIndexArray objectAtIndex:i];
            int currentIndex = [currentNumber intValue];
            
            for(int j=lastIndex; j<=currentIndex; j++)
            {
                [tempPointList addObject:[newPointList objectAtIndex:j]];
            }
            
            CurveUnit* tempCurveUnit = [[CurveUnit alloc]init];
            
            if(i == 1)
            {
                tempCurveUnit = [self produceArcUnitWithPointList:tempPointList LastCenter:NULL];
            }
            else
            {
                CurveUnit* lastCurveUnit = [arcUnitArray lastObject];
                tempCurveUnit = [self produceArcUnitWithPointList:tempPointList LastCenter:lastCurveUnit.center];
            }
            
            if(tempCurveUnit != NULL)
            {
                [arcUnitArray addObject:tempCurveUnit];
            }
            else
            {
                isArcGroup = NO;
                [arcUnitArray removeAllObjects];
                break;
            }
        }
        
        if(isArcGroup)
            return;
        
        isSplineGroup = YES;
        newPointList = [self findSpecialPointWithPointList:pointList];
        //分解插值
        for(int i=1; i<[arcIndexArray count]; i++)
        {
            [tempPointList removeAllObjects];
            
            NSNumber* lastNumber = [arcIndexArray objectAtIndex:i-1];
            int lastIndex = [lastNumber intValue];
            
            NSNumber* currentNumber = [arcIndexArray objectAtIndex:i];
            int currentIndex = [currentNumber intValue];
            
            for(int j=lastIndex; j<=currentIndex; j++)
            {
                [tempPointList addObject:[newPointList objectAtIndex:j]];
            }

            CurveUnit* tempCurveUnit = [[CurveUnit alloc]initWithPointArray:tempPointList];
            
            tempCurveUnit.type = 3;
            NSNumber* tempBoolNumber = [arcBoolArray objectAtIndex:i-1];
            bool tempBool = [tempBoolNumber boolValue];
            if(tempBool)
            {
                tempCurveUnit.isYDecrease = YES;
                tempCurveUnit.isYIncrease = YES;
                tempCurveUnit.isXDecrease = NO;
                tempCurveUnit.isXIncrease = NO;
            }
            else
            {
                tempCurveUnit.isXDecrease = YES;
                tempCurveUnit.isXIncrease = YES;
                tempCurveUnit.isYDecrease = NO;
                tempCurveUnit.isYIncrease = NO;
            }
            [tempCurveUnit calculateCubicSplineWithPointList:tempPointList];
            [arcUnitArray addObject:tempCurveUnit];
        }
    }
}

-(float)calculateDistanceWithPoint1:(SCPoint *)point1 Point2:(SCPoint *)point2
{
    return sqrtf((point1.x-point2.x)*(point1.x-point2.x) + (point1.y-point2.y)*(point1.y-point2.y));
}

-(Boolean)isSecondDegreeCurveWithPointArray:(NSMutableArray *)pointList
{
    //需要在进行了二次曲线的初步拟合得到一个普通的二次曲线方程后进行判断
    //二次曲线中心点为
    // y = (2ae-bd)/(b^2-4ac)
    // x = -d/(2a) - by/(2a)
    // d = f - (ax^2+bxy+cy^2)
    // Q(x,y) = a(x-x0)^2+b(x-x0)(y-y0)+c(y-y0)^2 + d;
    //if(bFactor*bFactor - 4*aFactor*cFactor <= equal_to_zero && bFactor*bFactor - 4*aFactor*cFactor >= equal_to_zero)
    //{
    //    curveType = 3;
    //}
    if(bFactor*bFactor > 4*aFactor*cFactor)
    {
        if (curveType!= 5)
        {
            curveType = 2;
        }
    }
    int number = pointList.count;
    float yCenter = (2*aFactor*eFactor - bFactor*dFactor)/(bFactor*bFactor - 4*aFactor*cFactor);
    float xCenter = -(dFactor + bFactor*yCenter)/(2*aFactor);
    float distance = fFactor - (aFactor*xCenter*xCenter + bFactor*yCenter*xCenter + cFactor*yCenter*yCenter);
    float deviation[number];
    
    //标准差
    float sum = 0;
    SCPoint* tempPoint;
    for(int i=0; i<number; i++)
    {
        tempPoint = [pointList objectAtIndex:i];
        deviation[i] = aFactor*(tempPoint.x - xCenter)*(tempPoint.x - xCenter) + bFactor*(tempPoint.x - xCenter)*(tempPoint.y - yCenter) + cFactor*(tempPoint.y - yCenter)*(tempPoint.y - yCenter);
        deviation[i] /= -distance;
        deviation[i] -= 1;
        
        if(deviation[i] < 0)
            sum -= deviation[i];
        else
            sum += deviation[i];
    }
    free(deviation);
    sum /= number;
    if(sum < stander_deviation)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)calculateStartPointAndEndPoint
{
    self.start.x = (majorAxis*cosf(startAngle));
    self.start.y = (minorAxis*sinf(startAngle));
    self.end.x   = (majorAxis*cosf(endAngle));
    self.end.y   = (minorAxis*sinf(endAngle));
}

-(void)calculateStartAndEndAngle
{
    //计算起始角和终止角
    if(self.start.x == 0)
    {
        //计算起始角
        if(self.start.y > 0)
        {
            startAngle = PI/2;
        }
        else
        {
            startAngle = PI*3/2;
        }
    }
    else
    {
        startAngle = atanf((self.start.y*majorAxis)/(self.start.x*minorAxis));
        if(self.start.x<0)//角在二、三象限
        {
            startAngle += PI;
        }
    }
    if(self.start.x == self.end.x && self.start.y == self.end.y)
    {
        isCompleteCurve = YES;
        endAngle = startAngle + 2*PI;
        return;
    }
    if(self.end.x == 0)
    {
        if(self.end.y > 0)
            endAngle = PI/2;
        if(self.end.y < 0)
            endAngle = PI*3/2;
    }
    else
    {
        endAngle = atanf((self.end.y*majorAxis)/(self.end.x*minorAxis));
        if(self.end.x < 0)//角在二、三象限
            endAngle += PI;
    }
    
    if(endAngle < startAngle)
    {
        endAngle += 2*PI;
    }
    if(endAngle - startAngle >= 1.98*PI)
    {
        isCompleteCurve = YES;
        if(endAngle - startAngle < 2*PI)
        {
            endAngle += 2*PI - (endAngle-startAngle);
        }
    }
    
    //判断是否大于半个弧度
    if(endAngle-startAngle >= PI)
    {
        isHalfCurve = YES;
    }
    
}

-(void)calculateStartAndEndAngleWithStartAngle:(float)startAngleLocal EndAngle:(float)endAngleLocal
{
    SCPoint* tempStart = [[SCPoint alloc]initWithX:0 andY:0];
    tempStart.x = self.end.x;
    tempStart.y = self.end.y;
    
    SCPoint* tempEnd = [[SCPoint alloc]initWithX:0 andY:0];
    tempEnd.x = self.start.x;
    tempEnd.y = self.start.y;
    
    //计算起始角
    if(tempStart.x == 0)
    {
        if(tempStart.y > 0)
        {
            startAngleLocal = PI/2;
        }
        else
        {
            startAngleLocal = PI*3/2;
        }
    }
    else
    {
        startAngleLocal = atanf((tempStart.y * majorAxis)/(tempStart.x * minorAxis));
        if(tempStart.x < 0) //角在第二、三象限
        {
            startAngleLocal += PI;
        }
    }
    
    if(tempStart.x == tempEnd.x && tempStart.y == tempEnd.y)
    {
        isCompleteCurve = YES;
        endAngleLocal = startAngleLocal + 2*PI;
        return;
    }
    
    //计算终止角
    if(tempEnd.x == 0)
    {
        if(tempEnd.y > 0)
        {
            endAngleLocal = PI/2;
        }
        if(tempEnd.y < 0)
        {
            endAngleLocal = PI*3/2;
        }
    }
    else
    {
        endAngleLocal = atanf((tempEnd.y * majorAxis)/(tempEnd.x * minorAxis));
        if(tempEnd.x < 0)   //角在第二、三象限
        {
            endAngleLocal += PI;
        }
    }
    
    if(endAngleLocal < startAngleLocal)
    {
        endAngleLocal += 2*PI;
    }
    if(endAngleLocal - startAngleLocal >= 1.98*PI)
    {
        isCompleteCurve = YES;
        if(endAngleLocal - startAngleLocal < 2*PI)
        {
            endAngleLocal += 2*PI - (endAngleLocal-startAngleLocal);
        }
    }
    
    //判断是否大于半个弧度
    if(endAngleLocal - startAngleLocal >= PI)
    {
        isHalfCurve = YES;
    }
}

-(void)calculateStartAndEndAngleWithStartPoint:(SCPoint *)startPoint EndPoint:(SCPoint *)endPoint StartAngle:(float)startAngleLocal EndAngle:(float)endAngleLocal
{
    SCPoint* tempStart = [[SCPoint alloc]initWithX:0 andY:0];
    tempStart.x = endPoint.x;
    tempStart.y = -endPoint.y;
    
    SCPoint* tempEnd = [[SCPoint alloc]initWithX:0 andY:0];
    tempEnd.x = startPoint.x;
    tempEnd.y = -startPoint.y;
    
    //计算起始角
    if(startPoint.x == 0)
    {
        if(startPoint.y > 0)
        {
            startAngleLocal = PI/2;
        }
        else
        {
            startAngleLocal = PI*3/2;
        }
    }
    else
    {
        startAngleLocal = atanf((tempStart.y * majorAxis)/(tempStart.x * minorAxis));
        if(startPoint.x < 0) //角在第二、三象限
        {
            startAngleLocal += PI;
        }
    }
    
    if(startPoint.x == endPoint.x && startPoint.y == endPoint.y)
    {
        isCompleteCurve = YES;
        endAngleLocal = startAngleLocal + 2*PI;
        return;
    }
    
    //计算终止角
    if(endPoint.x == 0)
    {
        if(endPoint.y > 0)
        {
            endAngleLocal = PI/2;
        }
        if(endPoint.y < 0)
        {
            endAngleLocal = PI*3/2;
        }
    }
    else
    {
        endAngleLocal = atanf((tempEnd.y * majorAxis)/(tempEnd.x * minorAxis));
        if(endPoint.x < 0)   //角在第二、三象限
        {
            endAngleLocal += PI;
        }
    }
    
    if(endAngleLocal < startAngleLocal)
    {
        endAngleLocal += 2*PI;
    }
    if(endAngleLocal - startAngleLocal >= 1.98*PI)
    {
        isCompleteCurve = YES;
        if(endAngleLocal - startAngleLocal < 2*PI)
        {
            endAngleLocal += 2*PI - (endAngleLocal-startAngleLocal);
        }
    }
    
//    //判断是否大于半个弧度
//    if(endAngleLocal - startAngleLocal >= PI)
//    {
//        isHalfCurve = YES;
//    }
}

-(float)calculateAngleWithPoint1:(SCPoint *)point1 Point2:(SCPoint *)point2 Center:(SCPoint *)centerPoint PosOrNeg:(float)isPosOrNeg
{
    float tempValue = (point2.x - centerPoint.x)*(point1.x - centerPoint.x) + (point2.y - centerPoint.y)*(point1.y -  centerPoint.y);
    float distance1 = [self calculateDistanceWithPoint1:point1 Point2:centerPoint];
    float distance2 = [self calculateDistanceWithPoint1:point2 Point2:centerPoint];
    float angle     = acosf(tempValue/(distance1*distance2));
    
    isPosOrNeg = (point1.x - centerPoint.x)*(point2.y - centerPoint.y) - (point2.x - centerPoint.x)*(point1.y - centerPoint.y);
    
    return angle;
}

-(float)calculateSlopeWithPoint1:(SCPoint*)point1 Point2:(SCPoint*)point2
{
    return (point2.y-point1.y)/(point2.x-point1.x);
}

-(float)calculateVerticalMiddleLineSlopeWithPoint1:(SCPoint*)point1 Point2:(SCPoint*)point2
{
    return -(point2.x-point1.x)/(point2.y-point1.y);
}

-(SCPoint*)calculateCenterPointWithSlope1:(float)slope1 Slope2:(float)slope2 Point1:(SCPoint*)point1 Point2:(SCPoint*)point2
{
    float x = ((point2.y - slope2*point2.x) - (point1.y-slope1*point1.x))/(slope1 - slope2);
    float y = (point1.y - slope1*point1.x) + slope2*x;
    
    return [[SCPoint alloc]initWithX:x andY:y];
}

-(SCPoint*)calculateMiddlePointWithPoint1:(SCPoint*)point1 Point2:(SCPoint*)point2
{
    return [[SCPoint alloc]initWithX:(point1.x+point2.x)/2 andY:(point1.y+point2.y)/2];
}

-(CurveUnit*)produceArcUnitWithPointList:(NSMutableArray*)pointList LastCenter:(SCPoint*)lastCenterPoint
{
    CurveUnit* curveUnitTemp = [[CurveUnit alloc]initWithPointArray:pointList];
    
    bool isSecondDegreeCurve = [curveUnitTemp isSecondDegreeCurveWithPointArray:pointList];
    
    if(isSecondDegreeCurve && curveUnitTemp.curveType == 1)
    {
        [curveUnitTemp judgeCurveWithPointArray:pointList];
        return curveUnitTemp;
    }
    else
    {
        curveUnitTemp = NULL;
        return curveUnitTemp;
    }
}

-(void)secondJudgeIsCompleteCurveWithPointArray:(NSMutableArray *)pointList
{
    if(pointList.count == 0)
        return;
    SCPoint* listStart = [pointList objectAtIndex:0];
    bool isSecondJudge = NO;
    
    SCPoint* tempPoint;
    
    for(int i=0; i<pointList.count; i++)
    {
        tempPoint = [pointList objectAtIndex:i];
        float tempPosNeg  = 0;
        float angle = [self calculateAngleWithPoint1:listStart Point2:tempPoint Center:center PosOrNeg:tempPosNeg];
        if(angle>170 && !(i>pointList.count-20 && i<pointList.count))
        {
            isSecondJudge = YES;
        }
    }
    
    if(!isSecondJudge)
        return;
    
    SCPoint* listEnd = [pointList objectAtIndex:pointList.count-1];
    
    float isPosOrNeg;
    float angleStartEnd = [self calculateAngleWithPoint1:listStart Point2:listEnd Center:center PosOrNeg:isPosOrNeg];
    float count = 0.0;
    float angle = 0.0;
    float otherIsPosNeg = 0.0;
    
    if(pointList.count < 30)
        return;
    for(int i=1; i<30; i++)
    {
        angle = [self calculateAngleWithPoint1:listStart Point2:listEnd Center:center PosOrNeg:otherIsPosNeg];
        if(otherIsPosNeg*isPosOrNeg > 0 && angle < angleStartEnd)
        {
            count++;
        }
    }
    if(count > 5)
    {
        isCompleteCurve = YES;
        self.end = self.start;
    }
    hasSecondJudge = YES;
    
}

-(void)antiTranslateWithX:(float *)x WithY:(float *)y Theta:(float)theta Point:(SCPoint *)vector
{
    SCPoint* temp = [[SCPoint alloc]init];
    float cos = cosf(theta);
    float sin = sinf(theta);
    //平移变换
    temp.x = *x - vector.x;
    temp.y = *y - vector.y;
    //旋转变换
    *x = (temp.x*cos + temp.y*sin);
    *y = (temp.x*(-sin) + temp.y*cos);
    
    [temp release];
    temp = NULL;
}

-(SCPoint*)antiTranslateWith:(SCPoint *)tempPoint Theta:(float)theta Point:(SCPoint *)vector
{
    SCPoint* temp = [[SCPoint alloc]init];
    float cos = cosf(theta);
    float sin = sinf(theta);
    //平移变换
    temp.x = tempPoint.x - vector.x;
    temp.y = tempPoint.y - vector.y;
    //旋转变换
    tempPoint.x = (temp.x*cos + temp.y*sin);
    tempPoint.y = (temp.x*(-sin) + temp.y*cos);
    
    [temp release];
    temp = NULL;
    
    return tempPoint;
}

-(void)translateAndRotationWithX:(float*)x Y:(float*)y Theta:(float)theta Point:(SCPoint *)vector
{
    SCPoint* temp = [[SCPoint alloc]init];
    float cos = cosf(-theta);
    float sin = sinf(-theta);
    temp.x = *x;
    temp.y = *y;
    //旋转平移变换
    *x = (temp.x*cos + temp.y*sin) + vector.x;
    *y = (temp.x*(-sin) + temp.y*cos) + vector.y;
}

-(SCPoint*)translateAndRotationWithPoint:(SCPoint *)tempPoint Theta:(float)theta Point:(SCPoint *)vector
{
    float cos = cosf(theta);
    float sin = sinf(theta);
    tempPoint.x = ((tempPoint.x-center.x)*cos + (tempPoint.y-center.y)*sin) + center.x + vector.x;
    tempPoint.y = ((tempPoint.x-center.x)*(-sin) + (tempPoint.y-center.y)*cos) + center.y + vector.y;
    return tempPoint;
}

-(SCPoint*)rotationWithPoint:(SCPoint *)tempPoint Theta:(float)theta
{
    float cos = cosf(theta);
    float sin = sinf(theta);
    tempPoint.x = ((tempPoint.x-center.x)*cos + (tempPoint.y-center.y)*sin) + center.x;
    tempPoint.y = ((tempPoint.x-center.x)*(-sin) + (tempPoint.y-center.y)*cos) + center.y;
    return tempPoint;    
}

-(SCPoint*)translateWithPoint:(SCPoint *)tempPoint Vector:(SCPoint *)vector
{
    tempPoint.x = tempPoint.x + vector.x;
    tempPoint.y = tempPoint.y + vector.y;
    return tempPoint;
}

-(void)setCenterWithX:(float)x Y:(float)y
{
    center.x = x;
    center.y = y;
    move.x   = x;
    move.y   = y;
}

-(void)setRadiusWithR:(float)r
{
    majorAxis = r;
    minorAxis = r;
}

-(void)setCompletCurve
{
    isCompleteCurve = YES;
    endAngle = startAngle+2*PI;
}

-(void)drawEllipseWithLastCurve:(CurveUnit*)lastCurve Context:(CGContextRef)context
{
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 5.0f);
    
    CGContextSaveGState(context);
    
    if(isCompleteCurve)
    {
        CGContextTranslateCTM(context, move.x, move.y);
        CGContextRotateCTM(context, alpha);
        CGContextStrokeEllipseInRect(context, CGRectMake(-majorAxis, -minorAxis, 2*majorAxis, 2*minorAxis));
    }
    else
    {
        SCPoint* pointTempAt0 = [newDrawSecCurveTrack objectAtIndex:0];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, pointTempAt0.x, pointTempAt0.y);
        
        for(float i=1; i<[newDrawSecCurveTrack count]; i++)
        {
            SCPoint* pointTemp = [newDrawSecCurveTrack objectAtIndex:i];
            CGPathAddLineToPoint(path, NULL, pointTemp.x, pointTemp.y);
        }
        CGContextSetLineWidth(context, 5.0f);
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CGPathRelease(path);
        
        //画弧线，为把处理和绘画分开
//        CGContextTranslateCTM(context, move.x, move.y);
//        CGContextRotateCTM(context, alpha);
//        [self drawEllipseArcWithContext:context];
    }
    
    if(isCompleteCurve)
    {
        //省略掉画焦点或圆心
    }
    
    CGContextRestoreGState(context);
    
}

-(void)drawEllipseArcWithContext:(CGContextRef)context
{
    float a = fabsf(majorAxis);
    float b = fabsf(minorAxis);
    
    //计算起始点和终止点后先画出椭圆曲线
    float add = 2*PI/draw_circle_increment;
    float x,y;
    x = (a*cosf(startAngle));
    y = (b*sinf(startAngle));
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x, y);
    
    
    for(float i=startAngle; i<=endAngle; i+=add)
    {
        x = a*cosf(i);
        y = b*sinf(i);
        CGPathAddLineToPoint(path, NULL, x, y);
    }
    CGContextSetLineWidth(context, 5.0f);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);
}

-(void)drawHyperbolicWithContext:(CGContextRef)context
{
    float a = fabsf(majorAxis);
    float b = fabsf(minorAxis);
    float c = sqrtf(a*a+b*b);
    //计算出起始角度和终止角度
    startAngle = atanf(self.start.y/b);
    endAngle   = atanf(self.end.y/b);
    if(minorAxis < 0)
    {
        if(self.start.x < 0)
        {
            startAngle = PI - startAngle;
        }
        if(self.end.x < 0)
        {
            endAngle = PI - endAngle;
        }
        f1.x = 0;
        f1.y = c;
        f2.x = 0;
        f2.y = -c;
    }
    else if(majorAxis < 0)
    {
        if(self.start.x < 0)
        {
            startAngle = PI - startAngle;
        }
        if(self.end.x < 0)
        {
            endAngle = PI - endAngle;
        }
        f1.x = c;
        f1.y = 0;
        f2.x = -c;
        f2.y = 0;
    }
    //计算出起始点和终止点后画出二次曲线（双曲线的一半）
    float add = 2*PI/draw_circle_increment;
    float x,y;
    x = (a/cosf(startAngle));
    y = (b*tanf(startAngle));
    [self translateAndRotationWithX:&x Y:&y Theta:alpha Point:move];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x, y);
    for(float i=startAngle; i>=endAngle; i-=add)
    {
        x = a/cosf(i);
        y = b*tanf(i);
        [self translateAndRotationWithX:&x Y:&y Theta:alpha Point:move];
        CGPathAddLineToPoint(path, NULL, x, y);
    }
    CGContextSetLineWidth(context, 5.0f);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CGPathRelease(path);
//    [self translateAndRotationWithX:&(f1.x) Y:&f1.y Theta:alpha Point:move];
//    [self translateAndRotationWithX:&(f2.x) Y:&f2.y Theta:alpha Point:move];
    
}

-(void)drawCubicSplineWithPointList:(NSMutableArray *)pointList Context:(CGContextRef)context
{
    if(!isArcGroup && !isSplineGroup)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        for(int i=0; i<[newDrawPointList count]; i++)
        {
            SCPoint* tempPoint = [newDrawPointList objectAtIndex:i];
            if (i == 0)
            {
                CGPathMoveToPoint(path, NULL, tempPoint.x, tempPoint.y);
            }
            else
            {
                CGPathAddLineToPoint(path, NULL, tempPoint.x, tempPoint.y);
            }
        }
        CGContextSetLineWidth(context, 5.0f);
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CGPathRelease(path);
        
        //画拐点
//        SCPoint* lastPoint = [newDrawPointList lastObject];
//        CGContextAddEllipseInRect(context, CGRectMake(lastPoint.x-2.0f, lastPoint.y-2.0f, 4.0f, 4.0f));
//        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//        CGContextStrokePath(context);
//        
//        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        
    }
    else if(isArcGroup)
    {
        for(int i=0; i<[arcUnitArray count]; i++)
        {
            if(i == 0)
            {
                CurveUnit* curveUnitTemp = [arcUnitArray objectAtIndex:i];
                [curveUnitTemp drawEllipseWithLastCurve:NULL Context:context];
            }
            else
            {
                CurveUnit* lastCurveUnit = [arcUnitArray objectAtIndex:i-1];
                CurveUnit* curveUnitTemp = [arcUnitArray objectAtIndex:i];
                [curveUnitTemp makeCurveSmoothToLastCurve:lastCurveUnit];
                [curveUnitTemp drawEllipseWithLastCurve:lastCurveUnit Context:context];
            }
        } 
    }
    else if(isSplineGroup)
    {
        for(int i=0; i<[arcUnitArray count]; i++)
        {
            CurveUnit* curveUnitTemp = [arcUnitArray objectAtIndex:i];
            [curveUnitTemp drawWithContext:context];
        }   
    }
}

-(void)drawBezierWithPointList:(NSMutableArray *)poitList Context:(CGContextRef)context
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    poitList = [self findSpecialPointWithPointList:poitList];
    
//    [poitList removeAllObjects];
//    SCPoint* pt1 = [[SCPoint alloc]initWithX:200 andY:200];
//    SCPoint* pt2 = [[SCPoint alloc]initWithX:400 andY:500];
//    SCPoint* pt3 = [[SCPoint alloc]initWithX:600 andY:200];
//    //SCPoint* pt4 = [[SCPoint alloc]initWithX:200 andY:500];
//    //SCPoint* pt5 = [[SCPoint alloc]initWithX:200 andY:200];
//    
//    [poitList addObject:pt1];
//    [poitList addObject:pt2];
//    [poitList addObject:pt3];
//    //[poitList addObject:pt4];
//    //[poitList addObject:pt5];
    
    //< Start and End Point
    SCPoint* startPt = [poitList objectAtIndex:0];
    SCPoint* endPt   = [poitList lastObject];
    
    float amount = endPt.x - startPt.x;
    
    int (^factorial)(int k) = ^(int k) {
        if (k == 0)
        {
            return 1;
        }
        int m = 1;
        for (int i = 1; i <= k; i++)
        {
            m *= i;
        }
        return m;
    };
    
    
    //< Curve Equation
    float (^bezierSpline)(int rank, float ux) = ^(int rank, float ux) {
        
        float p = 0.0f;
        
        for (int i = 0; i < rank; i++)
        {
            SCPoint* pt = [poitList objectAtIndex:i];
            
            float p1 = powf((1-ux), (rank-i-1));
            float p2 = powf(ux, i);
            float p3 = factorial(i)*factorial(rank-i-1);
            float p4 = factorial(rank-1);
            
            p+= pt.y * p1 * p2 * p4 / p3;

        }
        
        return p;
    };
    
    CGPoint startPoint = CGPointMake(startPt.x, startPt.y);
    [path moveToPoint:startPoint];
    
    for (float curX = startPt.x+1.0f; (curX - endPt.x) < 1.0f; curX += 1.0f)
    {
        float u = (curX - startPt.x) / amount;
        [path addLineToPoint:CGPointMake(curX, bezierSpline([poitList count], u))];
    }
    
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextAddPath(context, path.CGPath);
    CGContextStrokePath(context);
}

-(void)drawCircleArcWithContext:(CGContextRef)context
{
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 5.0f);
    CGContextAddArc(context, center.x, center.y, (majorAxis+minorAxis)/2, startAngle, endAngle, 0);
    CGContextStrokePath(context);
}

-(void)drawPathWithContext:(CGContextRef)context
{
    //如果识别出来是非二次曲线，就按照点轨迹一一画出
}

-(void)drawWithContext:(CGContextRef)context
{
    if(majorAxis<0 && minorAxis<0)
    {
        self.type = 3;           //非二次曲线
        curveType = 3;      //非二次曲线
    }
    
    if(self.type==2 && curveType==2)
    {
        //双曲线
        [self drawHyperbolicWithContext:context];
        NSLog(@"双曲线啊！！！！");
    }
    else if(self.type == 2 && curveType == 1)
    {
        //椭圆
        [self drawEllipseWithLastCurve:NULL Context:context];
        NSLog(@"椭圆啊！！！！");
    }    
    else if(self.type == 3)
    {
        [self drawCubicSplineWithPointList:newDrawPointList Context:context];
//        [self drawBezierWithPointList:curveTrack Context:context];
    }
    
}

@end
