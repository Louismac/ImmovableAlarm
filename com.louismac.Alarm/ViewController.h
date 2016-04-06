//
//  ViewController.h
//  com.louismac.Alarm
//
//  Created by LouisMcCallumOld on 04/03/2016.
//  Copyright © 2016 LouisMcCallum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *lblAlarm;
@property (weak, nonatomic) IBOutlet UIDatePicker *picker;
@property (weak, nonatomic) IBOutlet UIButton *btnStop;
@property (weak, nonatomic) IBOutlet UIButton *screenSaverView;
- (IBAction)btnStopUp:(id)sender;
- (IBAction)pickerAction:(id)sender;
- (IBAction)btnStopDown:(id)sender;
- (IBAction)screenSaverPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblCountDown;

@end

