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
#import "AJOauth2ApiClient.h"

#define kOldPasswordTextfieldTag 345
#define kNewPasswordTextfieldTag 346
#define kConfirmPasswordTextfieldTag 347

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
    
    // Confirm Password Textfield
    _confirmPasswordTextfield.placeholder = [MCLocalization stringForKey:@"confirm_password_placeholder"];
    _confirmPasswordTextfield.tag = kConfirmPasswordTextfieldTag;
    
    _oldPasswordTextfield.textColor = _newPasswordTextfield.textColor = _confirmPasswordTextfield.textColor = TEXT_LABEL_COLOR;
    _oldPasswordTextfield.errorColor = _newPasswordTextfield.errorColor = _confirmPasswordTextfield.errorColor = ERROR_LINE_COLOR;
    _oldPasswordTextfield.delegate = _newPasswordTextfield.delegate = _confirmPasswordTextfield.delegate = self;
    // _oldPasswordTextfield.lineColor = _newPasswordTextfield.lineColor = _confirmPasswordTextfield.lineColor = THEME_BG_COLOR;
    _oldPasswordTextfield.enableMaterialPlaceHolder = _newPasswordTextfield.enableMaterialPlaceHolder = _confirmPasswordTextfield.enableMaterialPlaceHolder = YES;
    
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
    (textField.text.length == 0) ? [textField showError] : [textField hideError];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UIView *view = [self.view viewWithTag:textField.tag + 1];
    (!view) ? [textField resignFirstResponder] : [view becomeFirstResponder];
    
    return YES;
}

#pragma mark IBActions

- (IBAction)updatePassword:(id)sender {
    if (_oldPasswordTextfield.text.length == 0) {
        [_oldPasswordTextfield showError];
        return;
    }
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
    [_oldPasswordTextfield hideError];
    [_newPasswordTextfield hideError];
    [_confirmPasswordTextfield hideError];
    
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
        
        // TODO: handling later on with refresh token
        if (httpResponse.statusCode == UNAUTHORIZED_CODE) {
            NSLog(@"%@",errorJsonDict.description);
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
    }
}

@end
