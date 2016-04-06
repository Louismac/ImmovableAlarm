//
//  ViewController.m
//  com.louismac.Alarm
//
//  Created by LouisMcCallumOld on 04/03/2016.
//  Copyright © 2016 LouisMcCallum. All rights reserved.
//

#import "ViewController.h"
@import AVFoundation;
@import AudioToolbox;

static const NSInteger kADayInSecs = 60*60*24;

static const NSInteger kHoldDownTime = 120;

static const NSInteger kScreenSaverTime = 10;

@interface ViewController ()

@property(nonatomic, strong) NSDate *alarmTime;
@property(nonatomic, strong) NSDate *btnReleaseTime;
@property(nonatomic, assign) NSTimeInterval holdButtonTime;
@property(nonatomic, assign) BOOL isHaltingAlarm;
@property(nonatomic, assign) BOOL alarmIsSounding;
@property(nonatomic, strong) NSTimer *alarmTimer;
@property(nonatomic, strong) NSTimer *alarmPlayerTimer;
@property(nonatomic, strong) NSTimer *countDownTimer;
@property(nonatomic, strong) NSTimer *screenSaverTimer;
@property(nonatomic, assign) NSInteger timeLeft;
@property(nonatomic, strong) AVAudioPlayer *wakeupPlayer;
@property(nonatomic, strong) AVPlayerItem *playerItem;


@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.picker.datePickerMode = UIDatePickerModeTime;

    [self resetCountDownTimer];
    [self setLabelFromPicker];
    //[self debugAlarm];
    [self resetScreenSaverTimer];
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"doc1" ofType: @"aif"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
    self.wakeupPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    self.wakeupPlayer.numberOfLoops = -1; //infinite loop
    
}

-(void) beginScreenSaverTimer
{
    self.screenSaverTimer = [NSTimer scheduledTimerWithTimeInterval:kScreenSaverTime target:self selector:@selector(enableScreenSaver) userInfo:nil repeats:NO];
}

-(void) enableScreenSaver
{
    [self.screenSaverView setHidden:NO];
}

-(void) resetScreenSaverTimer
{
    [self.screenSaverView setHidden:YES];
    [self.screenSaverTimer invalidate];
    self.screenSaverTimer=nil;
    if(!self.isHaltingAlarm && !self.alarmIsSounding) {
        [self beginScreenSaverTimer];
    }
}

-(void) debugAlarm
{
    self.alarmTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(alarmSelector) userInfo:nil repeats:NO];
}

-(void) setLabelFromPicker
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd:MM:yy HH:mm"];
    NSString *formatedDate = [dateFormatter stringFromDate:self.alarmTime];
    NSString *msg = [NSString stringWithFormat:@"alarm set for %@",formatedDate];
    NSLog(@"%@",msg);
    self.lblAlarm.text = msg;
}

- (IBAction)pickerAction:(id)sender
{
    [self resetScreenSaverTimer];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:[NSDate date]];
    
    [self setAlarm:[components hour]>12];
    
}

-(void) setAlarm:(BOOL)forTomorrow
{
    if(forTomorrow) {
        self.alarmTime = [NSDate dateWithTimeInterval:kADayInSecs sinceDate:self.picker.date];
    } else {
        self.alarmTime = self.picker.date;
    }
    
    [self setLabelFromPicker];
    
    [self.alarmTimer invalidate];
    self.alarmTimer=nil;
    
    NSTimeInterval timeUntilAlarm = [self.alarmTime timeIntervalSinceNow];
        
    self.alarmTimer = [NSTimer scheduledTimerWithTimeInterval:timeUntilAlarm target:self selector:@selector(alarmSelector) userInfo:nil repeats:NO];
}

- (IBAction)btnStopDown:(id)sender
{
    [self resetScreenSaverTimer];
    if(self.alarmIsSounding) {
        self.isHaltingAlarm=YES;
        self.btnReleaseTime = [NSDate dateWithTimeInterval:self.holdButtonTime sinceDate:[NSDate new]];
        [self endAlarmSound];
        [self.wakeupPlayer play];
        NSLog(@"alarm stopped");
        [self resetCountDownTimer];
        self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(decrementCountdownTimer) userInfo:nil repeats:YES];
    }
}

- (IBAction)screenSaverPressed:(id)sender
{
    [self resetScreenSaverTimer];
}

-(void) resetCountDownTimer
{
    self.timeLeft=kHoldDownTime;
    [self.lblCountDown setText:[NSString stringWithFormat:@"%ld",(long)self.timeLeft]];
}

-(void) decrementCountdownTimer
{
    self.timeLeft--;
    if(self.timeLeft>0){
        [self.lblCountDown setText:[NSString stringWithFormat:@"%ld",(long)self.timeLeft]];
    } else {
        [self.lblCountDown setText:@"I WILL BE RELEASED"];
    }
}

- (IBAction)btnStopUp:(id)sender
{
    if(self.isHaltingAlarm) {
        [self.wakeupPlayer pause];
        NSTimeInterval since = [self.btnReleaseTime timeIntervalSinceNow];
        if(since>0) {
            NSLog(@"alarm reset");
            self.btnReleaseTime = [NSDate dateWithTimeInterval:self.holdButtonTime sinceDate:[NSDate new]];
            [self resetCountDownTimer];
            [self alarmSelector];
        } else {
            NSLog(@"alarm released");
            self.isHaltingAlarm = NO;
            [self setAlarm:YES];
            [self.countDownTimer invalidate];
            self.countDownTimer = nil;
            [self resetCountDownTimer];
        }
        
    }
    [self resetScreenSaverTimer];

    
}

-(void) alarmSelector
{
    [self startAlarmSound];
    NSLog(@"alarm started");
    self.alarmIsSounding=YES;
    [self resetScreenSaverTimer];
}

-(void) startAlarmSound
{
    self.alarmPlayerTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(triggerAlarmSound) userInfo:nil repeats:YES];
}

-(void) endAlarmSound
{
    self.alarmIsSounding=NO;

    [self.alarmPlayerTimer invalidate];
    self.alarmPlayerTimer = nil;

}

-(void) triggerAlarmSound
{
    SystemSoundID soundID;
    
    soundID=1007;
    AudioServicesPlaySystemSound(soundID);
}


@end
