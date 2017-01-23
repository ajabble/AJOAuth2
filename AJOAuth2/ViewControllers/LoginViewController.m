//
//  LoginViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 20/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "LoginViewController.h"
#import "ForgotPasswordViewController.h"
#import "MCLocalization.h"
#import "Constants.h"
#import "AFOAuth2Manager.h"
#import "SVProgressHUD.h"
#import "Helper.h"
#import "User.h"

#define emailTextfieldTag 1234
#define passwordTextfieldTag 1235

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation title
    self.navigationItem.title = [MCLocalization stringForKey:@"login_nav_title"];
    
    // Email textfield
    _emailTextfield.placeholder = [MCLocalization stringForKey:@"email_placeholder"];
    _emailTextfield.returnKeyType = UIReturnKeyNext;
    _emailTextfield.tag = emailTextfieldTag;
    _emailTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
    
    // Password textfield
    _passwordTextfield.placeholder = [MCLocalization stringForKey:@"password_placeholder"];
    _passwordTextfield.secureTextEntry = YES;
    _passwordTextfield.returnKeyType = UIReturnKeyDone;
    _passwordTextfield.tag = passwordTextfieldTag;
    
    _emailTextfield.errorColor = _passwordTextfield.errorColor = ERROR_COLOR;
    _emailTextfield.lineColor = _passwordTextfield.lineColor = LINE_COLOR;
    _emailTextfield.enableMaterialPlaceHolder = _passwordTextfield.enableMaterialPlaceHolder = YES;
    _emailTextfield.delegate = _passwordTextfield.delegate = self;
    
    
    // Sign In button title
    [_signinButton setTitle:[MCLocalization stringForKey:@"signin_btn_title"] forState:UIControlStateNormal];
    _signinButton.layer.cornerRadius = BTN_CORNER_RADIUS;
    
    // Forgot Password button title
    [_forgotPasswordButton setTitle:[MCLocalization stringForKey:@"forgot_password_btn_title"] forState:UIControlStateNormal];
    
    if(DEV_ENV) {
        _emailTextfield.text = @"aUser";
        _passwordTextfield.text = @"test1test1";
    }
    
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

#pragma mark IBActions

- (IBAction)signin:(id)sender {
    if (_emailTextfield.text.length == 0) {
        [_emailTextfield showError];
        return;
    }
    if (_passwordTextfield.text.length == 0) {
        [_passwordTextfield showError];
        return;
    }
    
    if ([Helper isConnected])
        [self getAccessToken];
    else
       [SVProgressHUD showErrorWithStatus:@"No internet connectivity"];
    
    
    //    if ([Helper validateEmail:_emailTextfield.text]) {
    //        [_emailTextfield hideError];
    //        NSLog(@"Proceed to next!!");
    //        [self getAccessToken];
    //    }else {
    //        [_emailTextfield showError];
    //    }
}

- (IBAction)forgotPassword:(id)sender {
    ForgotPasswordViewController *forgotPasswordVC = [[ForgotPasswordViewController alloc] initWithNibName:@"ForgotPasswordViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:forgotPasswordVC animated:YES];
}

- (void)getAccessToken {
    [SVProgressHUD show];
    // get access token, refresh token, expiration time
    AFOAuth2Manager *OAuth2Manager = [[AFOAuth2Manager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URI] clientID:CLIENT_ID secret:SECRET_KEY];
    [OAuth2Manager authenticateUsingOAuthWithURLString:GET_TOKEN_API_NAME username:_emailTextfield.text password:_passwordTextfield.text scope:@""success:^(AFOAuthCredential *credential) {
        NSLog(@"Token: %@", credential.description);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"Login successfully!"];
            [SVProgressHUD dismiss];
        });
        
        // Store credential
        [AFOAuthCredential storeCredential:credential withIdentifier:SERVICE_PROVIDER_IDENTIFIER];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Failed with Error"];
            NSLog(@"Error: %@", error.description);
    }];
}

#pragma mark UITextfield

- (void)textFieldDidEndEditing:(JJMaterialTextfield *)textField {
    if (textField.text.length == 0)
      [textField showError];
    else
       [textField hideError];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UIView *view = [self.view viewWithTag:textField.tag + 1];
    if (!view)
       [textField resignFirstResponder];
    else
       [view becomeFirstResponder];
    return YES;
}

@end
