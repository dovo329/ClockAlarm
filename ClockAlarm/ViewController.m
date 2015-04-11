//
//  ViewController.m
//  ScrollTest
//
//  Created by Douglas Voss on 4/10/15.
//  Copyright (c) 2015 Doug. All rights reserved.
//

#import "ViewController.h"
#import "ClockView.h"
#import <AudioToolbox/AudioToolbox.h>


@interface ViewController ()
{
    SystemSoundID _yaySound;
}
@end


@implementation ViewController


UIScrollView *topScrollView;
ClockView *clockView;
UIDatePicker *datePicker;
UIButton *setAlarmButton;


- (void)setFrameSizeByOrientation:(UIDeviceOrientation)orientation
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect firstScreenRect = screenRect;
    CGRect secondScreenRect = screenRect;
    CGRect thirdScreenRect = screenRect;
    
    if(orientation==UIDeviceOrientationLandscapeLeft || orientation==UIDeviceOrientationLandscapeRight)
    {
        firstScreenRect.size.width /= 3.0;
        secondScreenRect.size.width /= 2.0;
        secondScreenRect.origin.x += firstScreenRect.size.width;
        secondScreenRect.origin.y += (secondScreenRect.size.height-datePicker.frame.size.height)/2.0;
        thirdScreenRect.origin.x = secondScreenRect.origin.x;
        thirdScreenRect.size.height = screenRect.size.height/3.0;
        thirdScreenRect.size.width = screenRect.size.width/3.0;
        
        clockView.frame = firstScreenRect;
        datePicker.frame = secondScreenRect;
        setAlarmButton.frame = thirdScreenRect;
    }
    else if(orientation==UIDeviceOrientationPortrait)
    {
        firstScreenRect.size.height /= 3.0;
        secondScreenRect.size.height /= 3.0;
        /*if (secondScreenRect.size.width > datePicker.frame.size.width) {
            NSLog(@"w1=%f w2=%f", secondScreenRect.size.width, datePicker.frame.size.width);
            secondScreenRect.origin.x += (secondScreenRect.size.width-datePicker.frame.size.width)/3.0;
        }*/
        secondScreenRect.origin.y += secondScreenRect.size.height;
        thirdScreenRect.size.height /= 3.0;
        thirdScreenRect.origin.y += screenRect.size.height*(2.0/3.0);
        
        clockView.frame = firstScreenRect;
        datePicker.frame = secondScreenRect;
        setAlarmButton.frame = thirdScreenRect;
    }
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

-(void)OrientationDidChange:(NSNotification*)notification
{
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
    
    [self setFrameSizeByOrientation:Orientation];
    if(Orientation==UIDeviceOrientationLandscapeLeft)
    {
        NSLog(@"Orientation changed to LandscapeLeft");
    }
    else if(Orientation==UIDeviceOrientationLandscapeRight)
    {
        NSLog(@"Orientation changed to LandscapeRight");
    }
    else if(Orientation==UIDeviceOrientationPortrait)
    {
        NSLog(@"Orientation changed to LandscapePortrait");
    }
    else if (Orientation==UIDeviceOrientationPortraitUpsideDown)
    {
        NSLog(@"Orientation changed to LandscapePortraitUpsideDown");
    }
    [self.view setNeedsDisplay];
    [clockView setNeedsDisplay];
    [datePicker setNeedsDisplay];
    [setAlarmButton setNeedsDisplay];
}

- (void)printRect:(CGRect)rect name:(NSString *)name
{
    NSLog(@"%@ x=%f, y=%f, width=%f, height=%f", name, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)setAlarmButtonHandler
{
    NSDate *date = datePicker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeStyle:NSDateFormatterFullStyle];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSLog(@"Set Alarm For: %@", dateString);
    
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.alertBody = @"Party Alarm!";
    note.fireDate = date;
    note.soundName = @"yay.wav";
    
    AudioServicesPlaySystemSound(_yaySound);
    
    [[UIApplication sharedApplication] scheduleLocalNotification:note];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    clockView = [[ClockView alloc] init];
    datePicker = [[UIDatePicker alloc] init];
    datePicker.backgroundColor = [UIColor clearColor];
    setAlarmButton = [[UIButton alloc] init];
    [setAlarmButton setTitle:@"Set Alarm" forState:UIControlStateNormal];
    [setAlarmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [setAlarmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [setAlarmButton setBackgroundColor:[UIColor clearColor]];
    [setAlarmButton addTarget:self
                       action:@selector(setAlarmButtonHandler)
             forControlEvents:UIControlEventTouchUpInside];
    
    NSString *yaySoundPath = [[NSBundle mainBundle]
                              pathForResource:@"yay" ofType:@"wav"];
    NSURL *yaySoundURL = [NSURL fileURLWithPath:yaySoundPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)yaySoundURL, &_yaySound);
    
    [self.view addSubview:datePicker];
    [self.view addSubview:clockView];
    [self.view addSubview:setAlarmButton];
    
    [self setFrameSizeByOrientation:UIDeviceOrientationPortrait];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:60];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
