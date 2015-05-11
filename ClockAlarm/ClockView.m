//
//  ClockView.m
//  AnalogClock
//
//  Created by Douglas Voss on 4/9/15.
//  Copyright (c) 2015 Doug. All rights reserved.
//

#import "ClockView.h"

@interface ClockView ()

@property (nonatomic) NSTimer *timer;

@end


@implementation ClockView

- (id)initWithColor:(UIColor *)color frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    // fire the timerHandler every second
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(timerHandler)
                                            userInfo:nil
                                             repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    _color = color;
    _rotationInDegrees = 0.0;
    _seconds = 0.0;
    _minutes = 0.0;
    _hours = 0.0;
    _orientation = 0.0;
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithColor:[UIColor redColor] frame:frame];
}

- (id)init
{
    return [self initWithColor:[UIColor redColor] frame:[[UIScreen mainScreen] bounds]];
}

- (void)timerHandler
{
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    int seconds = [[dateFormatter stringFromDate:now] intValue];
    dateFormatter.dateFormat = @"mm";
    int minutes = [[dateFormatter stringFromDate:now] intValue];
    dateFormatter.dateFormat = @"hh";
    int hours = [[dateFormatter stringFromDate:now] intValue];
    //NSLog(@"The Current Time is hour: %d, min: %d, sec: %d", hours, minutes, seconds);
    
    self.seconds = seconds;
    self.minutes = minutes;
    self.hours   = hours;
    [self setNeedsDisplay];
}

- (void)drawHand:(CGContextRef)context rect:(CGRect)rect radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth value:(int)value thresh:(int)thresh color:(UIColor *)color
{
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, lineWidth);
    UIColor *handColor = color;
    CGContextSetStrokeColorWithColor(context, handColor.CGColor);
    CGContextBeginPath(context);
    CGPoint center;
    center.x = CGRectGetMidX(rect);
    center.y = CGRectGetMidY(rect);
    CGContextMoveToPoint(context, center.x, center.y);
    CGFloat angle = ((2*M_PI)/thresh)*value;
    CGPoint handPoint;
    handPoint.x = center.x + sin(angle)*radius;
    handPoint.y = center.y + -cos(angle)*radius;
    CGContextAddLineToPoint(context, handPoint.x, handPoint.y);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    self.backgroundColor = [UIColor clearColor];
    
    
    CGRect clockRect;
    CGFloat outerLineWidth = 5.0;
    CGFloat diameter = MIN(rect.size.width, rect.size.height) - (outerLineWidth*2.0);
    CGFloat radius = diameter / 2.0;
    clockRect.size.width = diameter;
    clockRect.size.height = diameter;
    clockRect.origin.x = rect.origin.x - radius;
    clockRect.origin.y = rect.origin.y - radius;


    CGContextSaveGState(context);
    CGContextTranslateCTM (context, rect.size.width/2.0, rect.size.height/2.0);
    CGContextRotateCTM (context, self.rotationInDegrees*((2*M_PI)/360.0));
    
    
    CGFloat hue, saturation, brightness, alpha;
    UIColor *color = self.color;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    //NSLog(@"hue=%f saturation=%f brightness=%f alpha=%f", hue, saturation, brightness, alpha);
    
    UIColor *topColor1 = [UIColor whiteColor];
    UIColor *topColor2 = [UIColor colorWithHue:hue saturation:(1.0*saturation) brightness:(1.0*brightness) alpha:alpha];
    
    CGFloat topColor1Red, topColor1Green, topColor1Blue, topColor1Alpha;
    [topColor1 getRed:&topColor1Red green:&topColor1Green blue:&topColor1Blue alpha:&topColor1Alpha];
    
    CGFloat topColor2Red, topColor2Green, topColor2Blue, topColor2Alpha;
    [topColor2 getRed:&topColor2Red green:&topColor2Green blue:&topColor2Blue alpha:&topColor2Alpha];
    
    CGGradientRef topGradient;
    CGFloat topLocations[2] = { 0.0, 1.0 };
    CGFloat topComponents[4*2] = {
        topColor1Red, topColor1Green, topColor1Blue, topColor1Alpha,  // Start color
        topColor2Red, topColor2Green, topColor2Blue, topColor2Alpha   // End color
    };
    topGradient = CGGradientCreateWithColorComponents (colorspace, topComponents,
                                                       topLocations, 2);
    CGContextSaveGState(context);
    CGPoint startPoint = clockRect.origin;
    startPoint.x += radius/2.0;
    startPoint.y += radius/2.0;
    CGPoint endPoint = clockRect.origin;
    endPoint.x += radius;
    endPoint.y += radius;
    CGContextSetLineWidth(context, outerLineWidth);
    CGContextAddEllipseInRect(context, clockRect);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawRadialGradient(context, topGradient, startPoint, 0.0, endPoint, radius, NULL);
    CGGradientRelease (topGradient);
    CGContextRestoreGState(context);
    

    CGContextSaveGState(context);
    CGContextSetLineWidth(context, outerLineWidth);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextAddEllipseInRect(context, clockRect);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    
    [self drawHand:context rect:clockRect radius:radius lineWidth:1.0 value:self.seconds thresh:60.0 color:[UIColor blackColor]];
    [self drawHand:context rect:clockRect radius:radius lineWidth:5.0 value:self.minutes thresh:60.0 color:[UIColor blackColor]];
    [self drawHand:context rect:clockRect radius:(radius/2.0) lineWidth:10.0 value:self.hours thresh:12.0 color:[UIColor blackColor]];

    CGColorSpaceRelease (colorspace);
    CGContextRestoreGState(context);
    
    [super drawRect:rect];

}


@end
