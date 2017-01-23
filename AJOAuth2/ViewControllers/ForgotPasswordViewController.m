//
//  ForgotPasswordViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 20/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "MCLocalization.h"
#import "Constants.h"
#import "Helper.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    // Navigation title
    self.navigationItem.title = [MCLocalization stringForKey:@"forgot_password_nav_title"];
    
    // Email Textfield
    _emailTextfield.enableMaterialPlaceHolder = YES;
    _emailTextfield.placeholder = [MCLocalization stringForKey:@"email_placeholder"];
    _emailTextfield.returnKeyType = UIReturnKeyNext;
    _emailTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailTextfield.errorColor = ERROR_COLOR;
    _emailTextfield.lineColor = LINE_COLOR;
    _emailTextfield.enableMaterialPlaceHolder = YES;
    _emailTextfield.delegate = self;
    
    // Reset Password Button title
    [_resetPasswordButton setTitle:[MCLocalization stringForKey:@"reset_password_btn_title"] forState:UIControlStateNormal];
    _resetPasswordButton.layer.cornerRadius = BTN_CORNER_RADIUS;
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
#pragma mark UITextfield

- (void)textFieldDidEndEditing:(JJMaterialTextfield *)textField {
    if (textField.text.length == 0)
        [textField showError];
    else
        [textField hideError];
    
}

#pragma mark IBActions

- (IBAction)reset:(id)sender {
    if (_emailTextfield.text.length == 0) {
        [_emailTextfield showError];
        return;
    }
    if ([Helper validateEmail:_emailTextfield.text]) {
        [_emailTextfield hideError];
        NSLog(@"Proceed to next!!");
    } else {
        [_emailTextfield showError];
    }
}

@end
