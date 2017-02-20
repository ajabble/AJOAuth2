//
//  ForgotPasswordViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 20/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "MCLocalization.h"
#import "Helper.h"
#import "SVProgressHUD.h"
#import "AJOauth2ApiClient.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

#pragma mark View-Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    // Navigation title
    self.navigationItem.title = [MCLocalization stringForKey:@"forgot_password_nav_title"];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[MCLocalization stringForKey:@"back_bar_button_item_title"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    // View BG Color
    self.view.backgroundColor = VIEW_BG_COLOR;
    
    // Email Textfield
    _emailOrUsernameTextfield.placeholder = [NSString stringWithFormat:@"%@ %@ %@", [MCLocalization stringForKey:@"email_placeholder"], [MCLocalization stringForKey:@"or_keyword"], [MCLocalization stringForKey:@"user_name_placeholder"]];
    _emailOrUsernameTextfield.returnKeyType = UIReturnKeySend;
    _emailOrUsernameTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailOrUsernameTextfield.errorColor = ERROR_LINE_COLOR;
    //_emailOrUsernameTextfield.lineColor = TEXT_LABEL_COLOR;
    _emailOrUsernameTextfield.enableMaterialPlaceHolder = YES;
    _emailOrUsernameTextfield.delegate = self;
    _emailOrUsernameTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailOrUsernameTextfield.keyboardType = UIKeyboardTypeEmailAddress;
    _emailOrUsernameTextfield.textColor = TEXT_LABEL_COLOR;
    _emailOrUsernameTextfield.presentInView = self.view;
    
    // Reset Password Button title
    [_resetPasswordButton setTitle:[MCLocalization stringForKey:@"reset_password_btn_title"] forState:UIControlStateNormal];
    _resetPasswordButton.layer.cornerRadius = BTN_CORNER_RADIUS;
    _resetPasswordButton.layer.borderWidth = BTN_BORDER_WIDTH;
    _resetPasswordButton.layer.borderColor = BTN_BORDER_COLOR;
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

- (void)textFieldDidEndEditing:(AJTextField *)textField {
    (textField.text.length == 0) ? [textField showError] : [textField hideError];
}

- (BOOL)textFieldShouldReturn:(AJTextField *)textField {
    (textField.text.length == 0) ? [textField becomeFirstResponder] : [textField resignFirstResponder];
    
    if (textField.text.length > 0) {
        [textField hideError];
        [self requestPassword];
    }else {
        [textField showError];
    }
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

- (IBAction)reset:(id)sender {
    if ([_emailOrUsernameTextfield isValid]) {
        if ([Helper isConnected])
            [self requestPassword];
        else
            [SVProgressHUD showErrorWithStatus:[MCLocalization stringForKey:@"no_internet_connectivity"]];
    }
}

#pragma mark Request Password API method

- (void)requestPassword {
    [SVProgressHUD show];
    AJOauth2ApiClient *client = [AJOauth2ApiClient sharedClient];
    [client requestPassword:_emailOrUsernameTextfield.text success:^(NSURLSessionDataTask *task, id responseObject) {
        if (![Helper checkResponseObject:responseObject])
            return ;
        
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        if (statusCode == SUCCESS_CODE) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:SVProgressHUDWillDisappearNotification object:nil];
                [SVProgressHUD showSuccessWithStatus:jsonDict[@"show_message"]];
            });
        }else {
            [SVProgressHUD dismiss];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD dismiss];
        if (![Helper isWebUrlValid:error])
            return;
        
        id errorJson = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
        
        if (![Helper checkResponseObject:errorJson])
            return ;
        
        NSDictionary *errorJsonDict = (NSDictionary *)errorJson;
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

#pragma mark SVProgressHUD

- (void)handleNotification:(NSNotification *)notification {
    NSLog(@"Notification received: %@", notification.name);
    NSLog(@"Status user info key: %@", notification.userInfo[SVProgressHUDStatusUserInfoKey]);
    
    if ([notification.name isEqualToString:SVProgressHUDWillDisappearNotification]) {
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDWillDisappearNotification object:nil];
    }
}

@end
