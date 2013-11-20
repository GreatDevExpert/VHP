//
//  FormViewController.m
//  VHP_Project
//
//  Created by Steve on 4/7/15.
//  Copyright (c) 2015 Wei. All rights reserved.
//

#import "FormViewController.h"
#import <UIImageView+AFNetworking.h>
#import "VHPBiographyFormViewController.h"
#import "AppDelegate.h"

@interface FormViewController ()

@property UIDatePicker* datePicker;
@property UIPickerView* statePicker;
@property UIPickerView* customPicker;
@property UIView* datePickerContainerView;
@property UIToolbar *toolbar;
@property NSArray* stateData;
@property UITapGestureRecognizer* gestureRecognizer;
@property NSArray* phoneTexts, *zipCodes, *emailList;

@end

@implementation FormViewController

@synthesize datePicker, gestureRecognizer;

- (void)viewDidLoad {
    
    [super viewDidLoad];

    _phoneTexts = @[];
    _zipCodes = @[];
    _emailList = @[];
    _app = [[UIApplication sharedApplication]delegate];
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    NSDateComponents* components=[[NSDateComponents alloc] init];
    [components setYear:1900];
    NSDate* _minDate=[[NSCalendar currentCalendar] dateFromComponents:components];
    [datePicker setMinimumDate:_minDate];
    
    _statePicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)];
    _statePicker.delegate = self;
    _statePicker.dataSource = self;
    
    _customPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)];
    _customPicker.delegate = self;
    _customPicker.dataSource = self;
    _customPicker.tag = CUSTOM_PICKER_TAG_ID;
    
    _toolbar =[[UIToolbar alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width,44)];
    _toolbar.barStyle =UIBarStyleDefault;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"Clear" style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(cancelButtonPressed:)];
    
    UIBarButtonItem *flexibleSpace =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:self
                                                                                 action:nil];
    
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                               target:self
                                                                               action:@selector(doneButtonPressed:)];
    
    [_toolbar setItems:@[cancelButton,flexibleSpace, doneButton]];
    
    _stateData = @[@"AL",
@"AK",@"AZ",@"AR",@"CA",@"CO",@"CT",@"DE",@"FL",@"GA",@"HI",@"ID",@"IL",@"IN",@"IA",@"KS",@"KY",@"LA",@"ME",@"MD",@"MA",@"MI",@"MN",@"MS",@"MO",@"MT",@"NE",@"NV",@"NH",@"NJ",@"NM",@"NY",@"NC",@"ND",@"OH",@"OK",@"OR",@"PA",@"RI",@"SC",@"SD",@"TN",@"TX",@"UT",@"VT",@"VA",@"WA",@"WV",@"WI",@"WY",@"AS",@"DC",@"FM",@"GU",@"MH",@"MP",@"PW",@"PR",@"VI",@"AE",@"AA",@"AE",@"AE",@"AE",@"AP"];
   
    gestureRecognizer= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickerViewTapGestureRecognized:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.numberOfTouchesRequired = 2;
    [_statePicker addGestureRecognizer:gestureRecognizer];

    if (self.readOnly)
        [((UIButton*)[self.view viewWithTag:191910]) setTitle:@"Back" forState:UIControlStateNormal];

//    [self writeTag:self.view];
    
}

//For showing the tag of all the text fields and form fields
-(void)writeTag:(UIView*)view
{
    if (view.tag > 0) {
        CATextLayer *label = [[CATextLayer alloc] init];
        [label setFont:@"Helvetica-Bold"];
        [label setFontSize:10];
        [label setFrame:CGRectMake(0, 0, 70, 20)];
        [label setString:[NSString stringWithFormat:@"%d", view.tag]];
        [label setAlignmentMode:kCAAlignmentCenter];
        [label setBackgroundColor:[UIColor grayColor].CGColor];
        [label setForegroundColor:[[UIColor blackColor] CGColor]];
        [view.layer addSublayer:label];
    }
    
    for (UIView* v in [view subviews])
        [self writeTag:v];
}

-(BOOL)isNumericString:(NSString*)text includingSigns:(NSArray*)array
{
    NSMutableArray* arr;
    
    if (array != nil)
        arr = [[NSMutableArray alloc]initWithArray:array];
    
    [arr addObjectsFromArray:[@"0,1,2,3,4,5,6,7,8,9" componentsSeparatedByString:@","]];
    
    for (int i = 0; i < [text length]; i++)
    {
        NSRange range;
        range.location = i; range.length = 1;
        NSString* t = [text substringWithRange:range];
        
        if ([arr indexOfObject:t] == NSNotFound) return NO;
    }
    
    return YES;
}

-(void)pickerViewTapGestureRecognized:(UITapGestureRecognizer*)gestureRecognizer
{
    //Do nothing
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Do nothing
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == CUSTOM_PICKER_TAG_ID) {
        NSArray* views = [self.contentView subviews];
        if (views == nil)
            views = [self.view subviews];
        for (UIView* view in views)
        {
            if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder])
            {
                return [_customData[[NSString stringWithFormat:@"%d", view.tag]] count];
            }
        }
        return 0;
    }
    return [_stateData count];
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == CUSTOM_PICKER_TAG_ID) {
        NSArray* views = [self.contentView subviews];
        if (views == nil)
            views = [self.view subviews];
        for (UIView* view in views)
        {
            if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder])
            {
                return _customData[[NSString stringWithFormat:@"%d", view.tag]][row];
            }
        }
        return 0;
    }
    return _stateData[row];
}

- (void)cancelButtonPressed:(id)sender
{
    NSArray* views = [self.contentView subviews];
    
    for (UIView* view in views)
    {
        if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder])
        {
            ((UITextField*)view).text = @"";
            [self.view endEditing:YES];
            return;
        }
    }
    
    [self.view endEditing:YES];
}

- (void)doneButtonPressed:(id)sender
{
    NSString *birthdayText;
    UITextField* currentTextField = nil;;
    NSArray* views = [self.contentView subviews];
    
    if (views == nil)
        views = [self.view subviews];
    
    for (UIView* view in views)
    {
        if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder])
        {
            int flag = 0;
            for (NSString* c in _dateFieldTagsArray)
                if ([c intValue] == view.tag) {flag = 1; break; }

            if (!flag)
                for (NSString* c in _stateFieldTagsArray)
                    if ([c intValue] == view.tag) {flag = 2; break; }

            if (!flag)
                for (NSString* c in _customFieldTagsArray)
                    if ([c intValue] == view.tag) {flag = 3; break; }

            if (flag == 1) {
                currentTextField = ((UITextField*)view);
                NSDate *birthdayDate = datePicker.date;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateStyle = NSDateFormatterMediumStyle;
                
                birthdayText = [dateFormatter stringFromDate:birthdayDate];
            }
            else if (flag == 2)
            {
                currentTextField = ((UITextField*)view);                
                birthdayText = _stateData[[_statePicker selectedRowInComponent:0]];
            }
            
            else if (flag == 3)
            {
                currentTextField = ((UITextField*)view);
                birthdayText = _customData[[NSString stringWithFormat:@"%d", view.tag]][[_customPicker selectedRowInComponent:0]];
                
                NSInteger row = [_customPicker selectedRowInComponent:0];
                
                if (_customPicker.tag == CUSTOM_PICKER_TAG_ID) {
                    
                    NSArray* views = [self.contentView subviews];
                    if (views == nil)
                        views = [self.view subviews];
                    for (UIView* view in views)
                    {
                        if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder])
                        {
                            if (view.tag == 24 && row != 10 && [self isKindOfClass:[VHPBiographyFormViewController class]])
                            {
                                ((UITextField*)[self.contentView viewWithTag:16]).enabled= NO;
                                ((UITextField*)[self.contentView viewWithTag:16]).text = @"";
                            }
                            else if (view.tag == 24 && row == 10 && [self isKindOfClass:[VHPBiographyFormViewController class]])
                            {
                                ((UITextField*)[self.contentView viewWithTag:16]).enabled= YES;
                                ((UITextField*)[self.contentView viewWithTag:16]).text = @"";
                            }
                        }
                    }
                    
                }
            }
            
            break;
        }
    }
    
    if (currentTextField)
        currentTextField.text = birthdayText;
    
    [self.view endEditing:YES];
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

- (NSString *)encodeToBase64String:(UIImage *)image {
    if (image == nil) image = [[UIImage alloc]init];
    NSString* retVal = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    if (retVal == nil) return @"";
    return retVal;

}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    UIImage* retVal = [UIImage imageWithData:data];
    
    if (retVal == nil) retVal = [[UIImage alloc]init];
    return retVal;
}

- (UIImage *) convertToGreyscale:(UIImage *)i {
    
    int kRed = 1;
    int kGreen = 2;
    int kBlue = 4;
    
    int colors = kGreen | kBlue | kRed;
    int m_width = i.size.width;
    int m_height = i.size.height;
    
    uint32_t *rgbImage = (uint32_t *) malloc(m_width * m_height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImage, m_width, m_height, 8, m_width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, m_width, m_height), [i CGImage]);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // now convert to grayscale
    uint8_t *m_imageData = (uint8_t *) malloc(m_width * m_height);
    for(int y = 0; y < m_height; y++) {
        for(int x = 0; x < m_width; x++) {
            uint32_t rgbPixel=rgbImage[y*m_width+x];
            uint32_t sum=0,count=0;
            if (colors & kRed) {sum += (rgbPixel>>24)&255; count++;}
            if (colors & kGreen) {sum += (rgbPixel>>16)&255; count++;}
            if (colors & kBlue) {sum += (rgbPixel>>8)&255; count++;}
            m_imageData[y*m_width+x]=sum/count;
        }
    }
    free(rgbImage);
    
    // convert from a gray scale image back into a UIImage
    uint8_t *result = (uint8_t *) calloc(m_width * m_height *sizeof(uint32_t), 1);
    
    // process the image back to rgb
    for(int i = 0; i < m_height * m_width; i++) {
        result[i*4]=0;
        int val=m_imageData[i];
        result[i*4+1]=val;
        result[i*4+2]=val;
        result[i*4+3]=val;
    }
    
    // create a UIImage
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate(result, m_width, m_height, 8, m_width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    
    free(m_imageData);
    
    // make sure the data will be released by giving it to an autoreleased NSData
    [NSData dataWithBytesNoCopy:result length:m_width * m_height];
    
    return resultUIImage;
}

-(BOOL) isValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

-(BOOL)save:(NSString*)key
{
    if (self.readOnly)
        return YES;
    
    if (_app.tempData == nil)
        _app.tempData = [[NSMutableDictionary alloc]init];
    
    [_app.tempData setObject:[[NSMutableDictionary alloc]init] forKey:key];
    
    NSArray* subviews = [_contentView subviews];
    
    int invalidField = 1000000;
    for (UIView* view in subviews)
    {
        if (_zipCodes != nil && [_zipCodes indexOfObject:[NSString stringWithFormat:@"%d", view.tag]] != NSNotFound)
        {
            if (((UITextField*)view).text.length > 0 && !(([self isNumericString:((UITextField*)view).text includingSigns:@[]] && ((UITextField*)view).text.length == 5)))
            {
                ((UITextField*)view).layer.borderColor = [UIColor redColor].CGColor;
                ((UITextField*)view).layer.borderWidth = 1;
                if (invalidField > view.tag) invalidField = view.tag;
            }
                
        }
        if (_phoneTexts != nil && [_phoneTexts indexOfObject:[NSString stringWithFormat:@"%d", view.tag]] != NSNotFound)
        {
            
            if (((UITextField*)view).text.length > 0 && !(([self isNumericString:((UITextField*)view).text includingSigns:@[@"-"]] && ((UITextField*)view).text.length == 12)))
            {
                if ([self isNumericString:((UITextField*)view).text includingSigns:@[@"-"]] && ((UITextField*)view).text.length == 10)
                {
                    NSRange range1, range2;
                    range1.length = 3; range1.location = 0;
                    range2.length = 3; range2.location = 3;
                    NSString* text = ((UITextField*)view).text;
                    
                    text = [NSString stringWithFormat:@"%@-%@-%@", [text substringWithRange:range1], [text substringWithRange:range2], [text substringFromIndex:6]];
                    
                    ((UITextField*)view).text = text;
                }
                else {
                    ((UITextField*)view).layer.borderColor = [UIColor redColor].CGColor;
                    ((UITextField*)view).layer.borderWidth = 1;
                    if (invalidField > view.tag) invalidField = view.tag;
                }
            }
            
        }
        
        if (_emailList != nil && [_emailList indexOfObject:[NSString stringWithFormat:@"%d", view.tag]] != NSNotFound)
        {
            if (((UITextField*)view).text.length > 0 && !(([self isValidEmail:((UITextField*)view).text])))
            {
                ((UITextField*)view).layer.borderColor = [UIColor redColor].CGColor;
                ((UITextField*)view).layer.borderWidth = 1;
                if (invalidField > view.tag) invalidField = view.tag;
            }
            
        }
    }
    
    if (invalidField != 1000000)
    {
        [self.view viewWithTag:invalidField].layer.borderWidth = 1;
        [self.view viewWithTag:invalidField].layer.borderColor = [UIColor redColor].CGColor;
        
        CGPoint cp = [self.view viewWithTag:invalidField].frame.origin;
        cp.x = 0;
        cp.y = MAX(0, cp.y - 20);
        UIView* parentView = [self.view viewWithTag:invalidField];
        
        while (![parentView isKindOfClass:[UIScrollView class]] && parentView != nil)
            parentView = parentView.superview;
        
        if (parentView)
            ((UIScrollView*)parentView).contentOffset = cp;
//        [(UIView*)[self.view viewWithTag:invalidField] becomeFirstResponder];
        return NO;
    }
    
    for (UIView* view in subviews)
    {
        NSString* data;
        int tag = view.tag;
        NSLog(@"%d", tag);
        if (view.tag >= 1 && view.tag < 200)
        {
            if( [view isKindOfClass:[UITextField class]])
                data = ((UITextField*)view).text;
            else
                data = ((UITextView*)view).text;
        }
        else if (view.tag >= 201 && view.tag < 300)
        {
            data = [NSString stringWithFormat:@"%d", (int)((PJRCheckBox*)view).checkState];
        }
        else if (view.tag >= 300 && view.tag < 400)
        {
            data = [self encodeToBase64String:[self convertToGreyscale:((UIImageView*)view).image]];
        }
        else continue;
        
        [[_app.tempData objectForKey:key] setObject:data forKey:[NSString stringWithFormat:@"%d", (int)view.tag]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_app.tempData forKey:Draft_Interview_Data];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return  YES;
}

-(void)load:(NSString*)value
{ //191910
    NSArray* subviews = [_contentView subviews];
    NSMutableDictionary* dict = [_app.tempData objectForKey:value];
    if (dict == nil) return;
    
    for (UIView* view in subviews)
    {
        NSString* data = [dict objectForKey:[NSString stringWithFormat:@"%d", (int)view.tag]];
        
        if (view.tag >= 1 && view.tag < 200)
        {
            if( [view isKindOfClass:[UITextField class]])
                ((UITextField*)view).text = data;
            else
                ((UITextView*)view).text = data;
        }
        else if (view.tag >= 201 && view.tag < 300)
        {
            [((PJRCheckBox*)view) setCheckState:(PJRCheckboxState)[data intValue]];
        }
        else if (view.tag > 300 && view.tag < 400)
        {
            if ([data hasPrefix:@"http://"] || [data hasPrefix:@"https://"])
            {
                [((UIImageView*)view) setImageWithURL:[NSURL URLWithString:data]];
            }
            else ((UIImageView*)view).image = [self decodeBase64ToImage:data];
        }
    }
}

-(void)refreshInterface
{
    if ([_contentView isKindOfClass:[UIScrollView class]])
    {
        [(UIScrollView*)_contentView setShowsVerticalScrollIndicator:NO];
        [((UIScrollView*)_contentView) setBounces:NO];
    }
    
    NSArray* subviews = [_contentView subviews];
    
    for (UIView* view in subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            if ([((UIButton*)view).currentTitle isEqualToString:@"Draw Signature"])
            {
                [view setHidden:_readOnly];
            }
        }
        if ([view isKindOfClass:[UITextField class]])
        {
            
            ((UITextField*)view).spellCheckingType = UITextSpellCheckingTypeNo;
            ((UITextField*)view).delegate = self;
            
        }
        
        if ([view isKindOfClass:[UITextView class]])
        {
            ((UITextView*)view).spellCheckingType = UITextSpellCheckingTypeNo;
            ((UITextView*)view).delegate = self;
            view.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:1] CGColor];
            view.layer.borderWidth = 0.5;
            view.layer.cornerRadius = 5;
        }
        
        if ([view isKindOfClass:[UIImageView class]])
        {
            view.layer.borderWidth = 0.5;
            view.layer.borderColor = [[UIColor colorWithWhite:0.8 alpha:1] CGColor];
        }
        
        if (view.tag > 200 && view.tag <= 300)
        {
            ((PJRCheckBox*)view).type = PJRCheckboxOPTION;
            ((PJRCheckBox*)view).parentVC = self;
            ((PJRCheckBox*)view).userInteractionEnabled = !_readOnly;
        }
    }
    
    for (NSString* c in _dateFieldTagsArray)
    {
        ((UITextField*)[self.view viewWithTag:[c intValue]]).inputAccessoryView = _toolbar;
        ((UITextField*)[self.view viewWithTag:[c intValue]]).inputView = datePicker;
    }
    
    for (NSString* c in _stateFieldTagsArray)
    {
        ((UITextField*)[self.view viewWithTag:[c intValue]]).inputAccessoryView = _toolbar;
        ((UITextField*)[self.view viewWithTag:[c intValue]]).inputView = _statePicker;
    }
    
    for (NSString* c in _customFieldTagsArray)
    {
        ((UITextField*)[self.view viewWithTag:[c intValue]]).inputAccessoryView = _toolbar;
        ((UITextField*)[self.view viewWithTag:[c intValue]]).inputView = _customPicker;
    }
}

-(void)onCheckBoxSelected:(id)object1
{
    PJRCheckBox* object = (PJRCheckBox*)object1;
    
    int grouptag = object.tag;
    while (grouptag > 0 && [_contentView viewWithTag:grouptag] != nil)
        grouptag --;
    
    for (int i = grouptag + 1; [_contentView viewWithTag:i] != nil; i++) {
        NSLog(@"%d", i);
        [((PJRCheckBox*)([_contentView viewWithTag:i])) setStrokeColor:[UIColor blackColor]];
        [((PJRCheckBox*)([_contentView viewWithTag:i])) setCheckState:((PJRCheckBox*)([_contentView viewWithTag:i])).checkState];
    }
    
    if (object.type == PJRCheckboxCHECKBOX) return;
    
    for (int i = grouptag + 1; [_contentView viewWithTag:i] != nil; i++) {
        if (i == object.tag)
            continue;
        else
            [((PJRCheckBox*)([_contentView viewWithTag:i])) setCheckState:PJRCheckboxStateUnchecked];
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return !_readOnly;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return !_readOnly;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* tag = [NSString stringWithFormat:@"%d", textField.tag];
    NSString* text;
    
    textField.layer.borderWidth = 0;
    
    if ([_phoneTexts indexOfObject:tag] == NSNotFound)
        return YES;
    
    text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    text = [text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    if ([text length] > 6)
    {
        NSRange range1, range2;
        range1.length = 3; range1.location = 0;
        range2.length = 3; range2.location = 3;
        
        text = [NSString stringWithFormat:@"%@-%@-%@", [text substringWithRange:range1], [text substringWithRange:range2], [text substringFromIndex:6]];
    }
    else if ([text length] > 3)
    {
        NSRange range1;
        range1.length = 3; range1.location = 0;
        text = [NSString stringWithFormat:@"%@-%@", [text substringWithRange:range1], [text substringFromIndex:3]];
    }
    
    textField.text = text;
    return NO;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return  YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger tag = textField.tag + 1;
    UIView* view= ([self.contentView viewWithTag:tag]);
    
    if (view != nil &&  ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])) {
        if (((UITextField*)view).enabled == YES && view.hidden == NO)
            [view becomeFirstResponder];
        else
            return [self textFieldShouldReturn:(UITextField *)view];
    }
    else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(void)addPhoneTexts:(NSArray*)array
{
    _phoneTexts = [[NSArray alloc]initWithArray:array];
    for (NSString* str in self.phoneTexts)
    {
        [((UITextField*)[self.view viewWithTag:[str intValue]]) setKeyboardType:UIKeyboardTypeNumberPad];
    }
}

-(void)writeZipCodes:(NSArray *)zipCodes
{
    self.zipCodes = [[NSArray alloc]initWithArray:zipCodes];
    
    for (NSString* str in self.zipCodes)
    {
        [((UITextField*)[self.view viewWithTag:[str intValue]]) setKeyboardType:UIKeyboardTypeNumberPad];
    }
}

-(void)writeEmailList:(NSArray *)emailList
{
    self.emailList = [[NSArray alloc]initWithArray:emailList];
    
    for (NSString* str in self.emailList)
    {
        [((UITextField*)[self.view viewWithTag:[str intValue]]) setKeyboardType:UIKeyboardTypeEmailAddress];
    }
}

- (BOOL) checkIfImage:(UIImage *)someImage {
    CGImageRef image = someImage.CGImage;
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    GLubyte * imageData = malloc(width * height * 4);
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * width;
    int bitsPerComponent = 8;
    CGContextRef imageContext =
    CGBitmapContextCreate(
                          imageData, width, height, bitsPerComponent, bytesPerRow, CGImageGetColorSpace(image),
                          kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big
                          );
    
    CGContextSetBlendMode(imageContext, kCGBlendModeCopy);
    CGContextDrawImage(imageContext, CGRectMake(0, 0, width, height), image);
    CGContextRelease(imageContext);
    
    int byteIndex = 0;
    
    BOOL imageExist = YES;
    for ( ; byteIndex < width*height*4; byteIndex += 4) {
        CGFloat red = ((GLubyte *)imageData)[byteIndex]/255.0f;
        CGFloat green = ((GLubyte *)imageData)[byteIndex + 1]/255.0f;
        CGFloat blue = ((GLubyte *)imageData)[byteIndex + 2]/255.0f;
        CGFloat alpha = ((GLubyte *)imageData)[byteIndex + 3]/255.0f;
        if( red * green * blue * alpha < 0.8 ){
            imageExist = NO;
            return imageExist;
        }
    }
    
    return imageExist;
}
@end
