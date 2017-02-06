//
//  ChangePasswordViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 06/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "MCLocalization.h"
#import "Constants.h"
#import "Helper.h"
#import "SVProgressHUD.h"
#import "OAuth.h"
#import "AFOAuth2Manager.h"

#define kNewPasswordTextfieldTag 345
#define kConfirmPasswordTextfieldTag 346

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation title
    self.navigationItem.title = [MCLocalization stringForKey:@"change_password_section_header_name"];
    
    // View BG Color
    self.view.backgroundColor = VIEW_BG_COLOR;
    
    
    // New Password Textfield
    _newPasswordTextfield.placeholder = [MCLocalization stringForKey:@"new_password_placeholder"];
    _newPasswordTextfield.tag = kNewPasswordTextfieldTag;
    
    // Confirm Password Textfield
    _confirmPasswordTextfield.placeholder = [MCLocalization stringForKey:@"confirm_password_placeholder"];
    _confirmPasswordTextfield.tag = kConfirmPasswordTextfieldTag;
    
    // Update Password Button
    [_updatePasswordButton setTitle:[MCLocalization stringForKey:@"update_password_btn_title"] forState:UIControlStateNormal];
    _updatePasswordButton.layer.cornerRadius = BTN_CORNER_RADIUS;
    _updatePasswordButton.layer.borderWidth = BTN_BORDER_WIDTH;
    _updatePasswordButton.layer.borderColor = BTN_BORDER_COLOR;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UIView *view = [self.view viewWithTag:textField.tag + 1];
    if (!view)
        [textField resignFirstResponder];
    else
        [view becomeFirstResponder];
    
    return YES;
}

#pragma mark IBActions

- (IBAction)updatePassword:(id)sender {
    if (_newPasswordTextfield.text.length == 0) {
        [_newPasswordTextfield showError];
        return;
    }
    if (_confirmPasswordTextfield.text.length == 0) {
        [_confirmPasswordTextfield showError];
        return;
    }
    if ([_newPasswordTextfield.text isEqualToString:_confirmPasswordTextfield.text]) {
        if ([Helper isConnected])
            [self changePassword];
        else
            [SVProgressHUD showErrorWithStatus:[MCLocalization stringForKey:@"no_internet_connectivity"]];
    }else {
        [SVProgressHUD showErrorWithStatus:[MCLocalization stringForKey:@"passwords_donot_match_error"]];
    }
}

#pragma mark API

- (void)changePassword {
    [SVProgressHUD show];
    
    NSData *myObject = [PREFS objectForKey:OAUTH_INFO];
    OAuth *auth = (OAuth *)[NSKeyedUnarchiver unarchiveObjectWithData: myObject];
    NSLog(@"%@", auth.description);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithCredential:[AFOAuthCredential credentialWithOAuthToken:auth.accessToken tokenType:auth.tokenType]];
    [manager POST:CHANGE_PASSWORD_URI
       parameters:@{@"password": _newPasswordTextfield.text}
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSLog(@"Success: %@", responseObject);
              NSDictionary *jsonDict = (NSDictionary *)responseObject;
              if (!jsonDict)
                  return;
              if ([jsonDict isKindOfClass:[NSDictionary class]] == NO)
                  NSAssert(NO, @"Expected an Dictionary, got %@", NSStringFromClass([jsonDict class]));
              
              NSInteger statusCode = [jsonDict[@"code"] integerValue];
              if (statusCode == SUCCESS_CODE) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:SVProgressHUDWillAppearNotification object:nil];
                      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:SVProgressHUDWillDisappearNotification object:nil];
                      [SVProgressHUD showSuccessWithStatus:jsonDict[@"show_message"]];
                  });
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Failure: %@", error);
              
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
              NSLog(@"%zd", httpResponse.statusCode);
              [SVProgressHUD dismiss];
              
              // TODO: handling later on with refresh token
              if (httpResponse.statusCode == UNAUTHORIZED_CODE) {
                  id errorJson = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
                  
                  NSDictionary *errorJsonDict = (NSDictionary *)errorJson;
                  if (!errorJsonDict)
                      return;
                  if ([errorJsonDict isKindOfClass:[NSDictionary class]] == NO)
                      NSAssert(NO, @"Expected an Dictionary, got %@", NSStringFromClass([errorJsonDict class]));
                  
                  NSLog(@"%@",errorJsonDict.description);
              }
              
          }];
}

#pragma mark SVProgressHUD Notification methods

- (void)handleNotification:(NSNotification *)notification {
    NSLog(@"Notification received: %@", notification.name);
    NSLog(@"Status user info key: %@", notification.userInfo[SVProgressHUDStatusUserInfoKey]);
    
    if([notification.name isEqualToString:SVProgressHUDWillDisappearNotification]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDWillDisappearNotification object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
