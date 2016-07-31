//
//  PopupPickView.m
//  planeM8s
//
//  Created by Erik on 11/20/15.
//  Copyright © 2015 bb. All rights reserved.
//

#define ToobarHeight 40

#import "PopupPickView.h"

@interface PopupPickView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@end

@implementation PopupPickView {
    
    NSArray *_arrData;
    UIPickerView *_pickerView;
    UIDatePicker *_datePicker;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9f];
        
        UIBarButtonItem *lefttem=[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(remove)];
        UIBarButtonItem *centerSpace=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *right=[[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
        
        UIToolbar *toolbar=[[UIToolbar alloc] init];
        toolbar.items=@[lefttem, centerSpace, right];
        toolbar.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, ToobarHeight);
        toolbar.barTintColor = [UIColor blackColor];
        toolbar.tintColor = [UIColor orangeColor];
        //toolbar.alpha = 0.8f;
        [self addSubview:toolbar];
    }
    return self;
}

-(instancetype)initDatePickWithDate:(NSDate *)defaultDate datePickerMode:(UIDatePickerMode)datePickerMode {
    
    self=[super init];
    if (self) {
        _datePicker=[[UIDatePicker alloc] init];
        _datePicker.datePickerMode = datePickerMode;
        [_datePicker setDate:defaultDate];
        [self addPicker:_datePicker];
    }
    return self;
}

-(instancetype)initPickviewWithName:(NSString *)name selectedRow:(int)selectedRow{
    
    self=[super init];
    if (self) {
    
        self.name = name;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:_name ofType:@"plist"];
        NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
        [self setUpPickView:array];
        [_pickerView selectRow:(NSInteger)selectedRow inComponent:(NSInteger)0 animated:NO];
    }
    
    return self;
}

-(void)setUpPickView:(NSArray*)array {
    
    _arrData = array;
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.delegate=self;
    _pickerView.dataSource=self;
    [self addPicker:_pickerView];
}

-(void)addPicker:(UIView*)picker{
    
    CGSize screensize = [UIScreen mainScreen].bounds.size;
    CGFloat h = picker.frame.size.height+ToobarHeight;
    self.frame = CGRectMake(0, screensize.height-h, screensize.width, h);
    picker.frame=CGRectMake(0, ToobarHeight, screensize.width, picker.frame.size.height);
    [self addSubview:picker];
}

#pragma mark piackView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _arrData.count;
}

#pragma mark UIPickerViewdelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _arrData[row];
}

-(void)done {
    [self.delegate doneBtnClick:self];
    [self removeFromSuperview];
}

-(void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

-(void)remove {
    [self removeFromSuperview];
}

-(NSObject*)getSelectedValue {
    
    if (_datePicker) {
        return _datePicker.date;
    } else {
        int selectedIndex = (int)[_pickerView selectedRowInComponent:(NSInteger)0];
        return [NSNumber numberWithInt:selectedIndex];
    }
}

-(NSString*)getSelectedString {
    if (_datePicker) {
        if (_datePicker.datePickerMode == UIDatePickerModeDate)
            return [PopupPickView getDateToString:_datePicker.date];
        else
            return [PopupPickView getTimeToString:_datePicker.date];
    } else {
        return _arrData[(int)[_pickerView selectedRowInComponent:(NSInteger)0]];
    }
}

+(NSString*)getValueToString:(NSString*)name value:(int)value {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:path];
    return array[value];
}

+(NSString*)getDateToString:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:date];
}

+(NSString*)getTimeToString:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mma"];
    return [dateFormatter stringFromDate:date];
}

@end
