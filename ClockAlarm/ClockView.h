//
//  ClockView.h
//  AnalogClock
//
//  Created by Douglas Voss on 4/9/15.
//  Copyright (c) 2015 Doug. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClockView : UIView

@property (nonatomic) UIColor *color;
@property (nonatomic) CGFloat rotationInDegrees;
@property (nonatomic) int seconds;
@property (nonatomic) int minutes;
@property (nonatomic) int hours;
@property (nonatomic) int orientation;

@end
