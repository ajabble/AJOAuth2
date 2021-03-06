//
//  ChangePasswordViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 06/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "MCLocalization.h"
#import "Helper.h"
#import "SVProgressHUD.h"
#import "AJOauth2ApiClient.h"

NSInteger const kOldPasswordTextfieldTag = 345;
NSInteger const kNewPasswordTextfieldTag = 346;
NSInteger const kConfirmPasswordTextfieldTag = 347;

@interface ChangePasswordViewController ()

@end

@implementation ChangePasswordViewController

#pragma mark View-Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation title
    self.navigationItem.title = [MCLocalization stringForKey:@"change_password_section_header_name"];
    
    // View BG Color
    self.view.backgroundColor = VIEW_BG_COLOR;
    
    // Old Password Textfield
    _oldPasswordTextfield.placeholder = [MCLocalization stringForKey:@"old_password_placeholder"];
    _oldPasswordTextfield.tag = kOldPasswordTextfieldTag;
    
    // New Password Textfield
    _newPasswordTextfield.placeholder = [MCLocalization stringForKey:@"new_password_placeholder"];
    _newPasswordTextfield.tag = kNewPasswordTextfieldTag;
    [_newPasswordTextfield addRegex:REGEX_PASSWORD withMessage:[MCLocalization stringForKey:@"show_error_password_policy"]];
    
    // Confirm Password Textfield
    _confirmPasswordTextfield.placeholder = [MCLocalization stringForKey:@"confirm_password_placeholder"];
    _confirmPasswordTextfield.tag = kConfirmPasswordTextfieldTag;
    
    [_confirmPasswordTextfield addConfirmValidationTo:_newPasswordTextfield withMessage:[MCLocalization stringForKey:@"passwords_donot_match_error"]];
    
    _oldPasswordTextfield.presentInView = _newPasswordTextfield.presentInView = _confirmPasswordTextfield.presentInView = self.view;
    _oldPasswordTextfield.textColor = _newPasswordTextfield.textColor = _confirmPasswordTextfield.textColor = TEXT_LABEL_COLOR;
    _oldPasswordTextfield.errorColor = _newPasswordTextfield.errorColor = _confirmPasswordTextfield.errorColor = ERROR_LINE_COLOR;
    _oldPasswordTextfield.delegate = _newPasswordTextfield.delegate = _confirmPasswordTextfield.delegate = self;
    // _oldPasswordTextfield.lineColor = _newPasswordTextfield.lineColor = _confirmPasswordTextfield.lineColor = THEME_BG_COLOR;
    _oldPasswordTextfield.enableMaterialPlaceHolder = _newPasswordTextfield.enableMaterialPlaceHolder = _confirmPasswordTextfield.enableMaterialPlaceHolder = YES;
    _oldPasswordTextfield.returnKeyType = _newPasswordTextfield.returnKeyType = UIReturnKeyNext;
    _confirmPasswordTextfield.returnKeyType = UIReturnKeyDone;
    
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


#pragma mark AJTextfield

- (void)textFieldDidEndEditing:(AJTextField *)textField {
    ([textField isValid]) ? [textField hideError] : [textField showError];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UIView *view = [self.view viewWithTag:textField.tag + 1];
    (!view) ? [textField resignFirstResponder] : [view becomeFirstResponder];
    
    return YES;
}

- (BOOL)textField:(AJTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    return YES;
}

- (void)textFieldDidChange:(AJTextField *)textField {
    ([textField isValid]) ? [textField hideError] : [textField showError];
}

#pragma mark IBActions

- (IBAction)updatePassword:(id)sender {
    if ([_oldPasswordTextfield isValid] & [_newPasswordTextfield isValid] & [_confirmPasswordTextfield isValid]) {
        if ([Helper isConnected])
            [self changePassword];
        else
            [SVProgressHUD showErrorWithStatus:[MCLocalization stringForKey:@"no_internet_connectivity"]];
    }
}

#pragma mark API

- (void)changePassword {
    [SVProgressHUD show];
    AJOauth2ApiClient *client = [AJOauth2ApiClient sharedClient];
    [client changePassword:_newPasswordTextfield.text oldPassword:_oldPasswordTextfield.text success:^(NSURLSessionDataTask *task, id responseObject) {
        if (![Helper checkResponseObject:responseObject])
            return ;
        
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        if (statusCode == SUCCESS_CODE) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:SVProgressHUDWillDisappearNotification object:nil];
                [SVProgressHUD showSuccessWithStatus:jsonDict[@"show_message"]];
            });
        } else {
            [SVProgressHUD dismiss];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        
        id errorJson = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
        if (![Helper checkResponseObject:errorJson])
            return ;
        NSDictionary *errorJsonDict = (NSDictionary *)errorJson;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"%zd", httpResponse.statusCode);
        
        if (httpResponse.statusCode == UNAUTHORIZED_CODE) {
            [client refreshTokenWithSuccess:^(AFOAuthCredential *newCredential) {
                [self changePassword];
            } failure:^(NSError *error) {
                [SVProgressHUD dismiss];
                if (![Helper isWebUrlValid:error])
                    return;
                
                id errorJson = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
                
                if (![Helper checkResponseObject:errorJson])
                    return ;
                NSDictionary *errorJsonDict = (NSDictionary *)errorJson;
                NSLog(@"Error Code: %@; ErrorDescription: %@", errorJsonDict[@"code"], errorJsonDict[@"error_description"]);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:SVProgressHUDWillAppearNotification object:nil];
                    [SVProgressHUD showSuccessWithStatus:[MCLocalization stringForKey:@"sign_out_message"]];
                });
            }];
        } else if (httpResponse.statusCode == BAD_REQUEST_CODE) {
            [SVProgressHUD showSuccessWithStatus:errorJsonDict[@"show_message"]];
        }else if (httpResponse.statusCode == INTERNAL_SERVER_ERROR_CODE) {
            NSLog(@"Error Code: %@; ErrorDescription: %@", errorJsonDict[@"code"], errorJsonDict[@"error_description"]);
        }
    }];
}

#pragma mark SVProgressHUD

- (void)handleNotification:(NSNotification *)notification {
    NSLog(@"Notification received: %@", notification.name);
    NSLog(@"Status user info key: %@", notification.userInfo[SVProgressHUDStatusUserInfoKey]);
    
    if ([notification.name isEqualToString:SVProgressHUDWillDisappearNotification]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDWillDisappearNotification object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }else if ([notification.name isEqualToString:SVProgressHUDWillAppearNotification]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDWillAppearNotification object:nil];
        [Helper removeUserPrefs];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
