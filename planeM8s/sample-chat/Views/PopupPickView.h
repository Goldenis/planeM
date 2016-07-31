//
//  PopupPickView.h
//  planeM8s
//
//  Created by Erik on 11/20/15.
//  Copyright © 2015 bb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopupPickView;

@protocol PopupPickViewDelegate <NSObject>

@optional

-(void)doneBtnClick:(PopupPickView *)popupPickView;

@end

@interface PopupPickView : UIView

@property (nonatomic, weak) id<PopupPickViewDelegate> delegate;
@property (nonatomic,copy) NSString *name;

-(instancetype)initPickviewWithName:(NSString *)name selectedRow:(int)selectedRow;
-(instancetype)initDatePickWithDate:(NSDate *)defaulDate datePickerMode:(UIDatePickerMode)datePickerMode;

-(void)show;
-(void)remove;

-(NSObject*)getSelectedValue;
-(NSString*)getSelectedString;

+(NSString*)getValueToString:(NSString*)name value:(int)value;
+(NSString*)getDateToString:(NSDate*)date;
+(NSString*)getTimeToString:(NSDate*)date;

@end
