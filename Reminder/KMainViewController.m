//
//  KMainViewController.m
//  Reminder
//
//  Created by corptest on 13-9-30.
//  Copyright (c) 2013年 klaus. All rights reserved.
//

#import "KMainViewController.h"
#import <EventKit/EventKit.h>

@interface KMainViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) EKEventStore *eventStore;

@end

@implementation KMainViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if (self.eventStore == nil) {
        self.eventStore = [[EKEventStore alloc] init];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.0) {
            // 6.0以后的系统需要申请权限
            [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    NSLog(@"用户允许使用“日历”！！！");
                } else {
                    NSLog(@"用户不允许使用“日历”！！！");
                }
                if (error) {
                    NSLog(@"申请“日历”权限error:%@", error);
                }
            }];
            [self.eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    NSLog(@"用户允许使用“提醒事项”！！！");
                } else {
                    NSLog(@"用户不允许使用“提醒事项”！！！");
                }
                if (error) {
                    NSLog(@"申请“提醒事项”权限error:%@", error);
                }
            }];
        }
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction) createReminder:(id)sender
{
    EKReminder *reminder = [EKReminder reminderWithEventStore:self.eventStore];
    reminder.calendar = self.eventStore.defaultCalendarForNewReminders;
    reminder.title = self.textField.text;
    [reminder addAlarm:[EKAlarm alarmWithAbsoluteDate:self.datePicker.date]];
    NSError *error = nil;
    [self.eventStore saveReminder:reminder commit:YES error:&error];
    if (error) {
        NSLog(@"saveReminder error:%@", error);
    }
}

- (IBAction) createCalendarReminder:(id)sender
{
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    event.calendar = self.eventStore.defaultCalendarForNewEvents;
    event.allDay = NO;
    event.title = self.textField.text;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
    oneDayAgoComponents.minute = 2;
    NSDate *startDate = [calendar dateByAddingComponents:oneDayAgoComponents
                                                  toDate:[NSDate date]
                                                 options:0];
    
    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
    oneYearFromNowComponents.minute = 10;
    NSDate *endDate = [calendar dateByAddingComponents:oneYearFromNowComponents
                                                       toDate:[NSDate date]
                                                      options:0];
    
    event.startDate = startDate;
    event.endDate = endDate;
    
    // 加入提醒时间
    [event addAlarm:[EKAlarm alarmWithAbsoluteDate:startDate]];
    
    NSError *error = nil;
    [self.eventStore saveEvent:event span:EKSpanFutureEvents commit:YES error:&error];
    if (error) {
        NSLog(@"error!!! \n%@", error);
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
