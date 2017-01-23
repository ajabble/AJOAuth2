//
//  SignupViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 20/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "SignupViewController.h"
#import "MCLocalization.h"
#import "Constants.h"
#import "Helper.h"

#define firstNamefieldTag 1234
#define lastNameTextfieldTag 1235
#define emailTextfieldTag 1236
#define passwordTextfieldTag 1237
#define displayNameTextfieldTag 1238
#define dobTextfieldTag 1239

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation title
    self.navigationItem.title = [MCLocalization stringForKey:@"signup_nav_title"];
    
    // First Name Textfield
    _firstNameTextfield.placeholder = [MCLocalization stringForKey:@"first_name_placeholder"];
    _firstNameTextfield.tag = firstNamefieldTag;
    
    // Last Name Textfield
    _lastNameTextfield.placeholder = [MCLocalization stringForKey:@"last_name_placeholder"];
    _lastNameTextfield.tag = lastNameTextfieldTag;
    
    // Email Textfield
    _emailTextfield.placeholder = [MCLocalization stringForKey:@"email_placeholder"];
    _emailTextfield.tag = emailTextfieldTag;
    
    // Password Textfield
    _passwordTextfield.placeholder = [MCLocalization stringForKey:@"password_placeholder"];
    _passwordTextfield.secureTextEntry = YES;
    _passwordTextfield.tag = passwordTextfieldTag;
    
    // Display name Textfield
    _displayNameTextfield.placeholder = [MCLocalization stringForKey:@"display_name_placeholder"];
    _displayNameTextfield.tag = displayNameTextfieldTag;
    
    _firstNameTextfield.errorColor = _lastNameTextfield.errorColor = _emailTextfield.errorColor = _passwordTextfield.errorColor = _displayNameTextfield.errorColor = ERROR_COLOR;
    _firstNameTextfield.lineColor = _lastNameTextfield.lineColor = _emailTextfield.lineColor = _passwordTextfield.lineColor = _displayNameTextfield.lineColor =  LINE_COLOR;
    _firstNameTextfield.enableMaterialPlaceHolder = _lastNameTextfield.enableMaterialPlaceHolder = _emailTextfield.enableMaterialPlaceHolder = _passwordTextfield.enableMaterialPlaceHolder = _displayNameTextfield.enableMaterialPlaceHolder = YES;
    _firstNameTextfield.delegate = _lastNameTextfield.delegate = _emailTextfield.delegate = _passwordTextfield.delegate = _displayNameTextfield.delegate = self;
    _firstNameTextfield.autocorrectionType = _lastNameTextfield.autocorrectionType = _emailTextfield.autocorrectionType = _passwordTextfield.autocorrectionType = _displayNameTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _firstNameTextfield.returnKeyType = _lastNameTextfield.returnKeyType = _emailTextfield.returnKeyType = _passwordTextfield.returnKeyType = UIReturnKeyNext;
    _displayNameTextfield.returnKeyType = UIReturnKeyDone;
    
    
    // DOB - UIPickerView added as input view of UITextfield
    _dobTextfield.placeholder = [MCLocalization stringForKey:@"dob_placeholder"];
    _dobTextfield.tag = dobTextfieldTag;
    
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(updateTextField:)
         forControlEvents:UIControlEventValueChanged];
    [_dobTextfield setInputView:datePicker];
    
    // Sign up button title
    [_signupButton setTitle:[MCLocalization stringForKey:@"signup_btn_title"] forState:UIControlStateNormal];
    _signupButton.layer.cornerRadius = BTN_CORNER_RADIUS;
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

#pragma mark IBAction

- (IBAction)signup:(id)sender {
    if (_firstNameTextfield.text.length == 0) {
        [_firstNameTextfield showError];
        return;
    }
    if (_lastNameTextfield.text.length == 0) {
        [_lastNameTextfield showError];
        return;
    }
    if (_emailTextfield.text.length == 0) {
        [_emailTextfield showError];
        return;
    }
    if (_passwordTextfield.text.length == 0) {
        [_passwordTextfield showError];
        return;
    }
    if (_displayNameTextfield.text.length == 0) {
        [_displayNameTextfield showError];
        return;
    }
    if (_dobTextfield.text.length == 0){
        [_dobTextfield showError];
        return;
    }
    if ([Helper validateEmail:_emailTextfield.text]) {
        [_emailTextfield hideError];
        NSLog(@"Proceed to next!!");
    }else {
        [_emailTextfield showError];
    }
}

#pragma mark UITextfield

- (void)textFieldDidEndEditing:(JJMaterialTextfield *)textField {
    if (textField.text.length == 0) {
        [textField showError];
    }
    else {
        [textField hideError];
        if (_firstNameTextfield.text.length > 0 && _lastNameTextfield.text.length > 0){
            if (_displayNameTextfield.text.length == 0)
            _displayNameTextfield.text = [NSString stringWithFormat:@"%@.%@", _firstNameTextfield.text, _lastNameTextfield.text];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UIView *view = [self.view viewWithTag:textField.tag + 1];
    if (!view)
    [textField resignFirstResponder];
    else
    [view becomeFirstResponder];
    
    return YES;
}

- (void)updateTextField:(UIDatePicker *)sender {
    NSDateFormatter *objDateFormatter = [[NSDateFormatter alloc] init];
    [objDateFormatter setDateFormat:@"yyyy-MM-dd"];
    _dobTextfield.text = [objDateFormatter stringFromDate:sender.date];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [datePicker removeFromSuperview];
}

@end
