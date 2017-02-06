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
#import "OAuth.h"
#import "User.h"

#define emailTextfieldTag 1234
#define passwordTextfieldTag 1235

@interface LoginViewController ()

@end

@implementation LoginViewController

#pragma mark View-Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // View BG Color
    self.view.backgroundColor = VIEW_BG_COLOR;
    
    // Navigation title
    self.navigationItem.title = [MCLocalization stringForKey:@"login_nav_title"];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[MCLocalization stringForKey:@"back_bar_button_item_title"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
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
    _emailTextfield.clearButtonMode = _passwordTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    // Sign In button
    [_signinButton setTitle:[MCLocalization stringForKey:@"signin_btn_title"] forState:UIControlStateNormal];
    _signinButton.layer.cornerRadius = BTN_CORNER_RADIUS;
    _signinButton.layer.borderWidth = BTN_BORDER_WIDTH;
    _signinButton.layer.borderColor = BTN_BORDER_COLOR;
    
    // Forgot Password button title
    [_forgotPasswordButton setTitle:[MCLocalization stringForKey:@"forgot_password_btn_title"] forState:UIControlStateNormal];
    
    if(DEV_ENV) {
        _emailTextfield.text = @"ajabble";
        _passwordTextfield.text = @"aj123";
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
    [SVProgressHUD showErrorWithStatus:[MCLocalization stringForKey:@"no_internet_connectivity"]];
    
    
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

#pragma mark - Access Token with API
- (void)getAccessToken {
    [SVProgressHUD show];
    // get access token, refresh token, expiration time
    AFOAuth2Manager *OAuth2Manager = [[AFOAuth2Manager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL] clientID:CLIENT_ID secret:SECRET_KEY];
    OAuth2Manager.useHTTPBasicAuthentication = NO;
    [OAuth2Manager authenticateUsingOAuthWithURLString:FETCH_ACCESS_TOKEN_URI username:_emailTextfield.text password:_passwordTextfield.text scope:SCOPE success:^(AFOAuthCredential *credential) {
        NSLog(@"Token: %@", credential.description);
       
        // Store credential
        [AFOAuthCredential storeCredential:credential withIdentifier:SERVICE_PROVIDER_IDENTIFIER];
        
        // TODO: Expiration time (Pending) and reponse it actually not parse by an API
        
        // Oauth info stored in NSUserDefaults
        NSDictionary *oAuthInfoDict = @{@"access_token":credential.accessToken, @"refresh_token":credential.refreshToken, @"token_type":credential.tokenType, @"scope": SCOPE};
        [Helper oAuthInfoSaveInDefaults:oAuthInfoDict];
        
        // User info stored in NSUserDefaults
        NSDictionary *userInfoDict = @{@"username": _emailTextfield.text};
        [Helper userInfoSaveInDefaults:userInfoDict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:SVProgressHUDWillAppearNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:SVProgressHUDWillDisappearNotification object:nil];
            [SVProgressHUD showSuccessWithStatus:[MCLocalization stringForKey:@"login_success_message"]];
        });
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error.description);
        
        id errorJson = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
        
        NSDictionary *errorJsonDict = (NSDictionary *)errorJson;
        if (!errorJsonDict)
            return;
        if ([errorJsonDict isKindOfClass:[NSDictionary class]] == NO)
            NSAssert(NO, @"Expected an Dictionary, got %@", NSStringFromClass([errorJsonDict class]));
        
        NSLog(@"%@",errorJsonDict.description);
        
        NSInteger statusCode = [errorJsonDict[@"code"] integerValue];
        if (statusCode == BAD_REQUEST_CODE) {
            [SVProgressHUD showErrorWithStatus:errorJsonDict[@"show_message"]];
            return;
        }else if (statusCode == INTERNAL_SERVER_ERROR_CODE) {
            NSLog(@"Error Code: %zd; ErrorDescription: %@", statusCode, errorJsonDict[@"error_description"]);
        }
        [SVProgressHUD showErrorWithStatus:[MCLocalization stringForKey:@"error_message"]];
    }];
}

- (void)handleNotification:(NSNotification *)notification {
    NSLog(@"Notification received: %@", notification.name);
    NSLog(@"Status user info key: %@", notification.userInfo[SVProgressHUDStatusUserInfoKey]);
    
    if([notification.name isEqualToString:SVProgressHUDWillDisappearNotification]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDWillDisappearNotification object:nil];
    }
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
