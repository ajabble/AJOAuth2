//
//  EditProfileViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 06/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "EditProfileViewController.h"
#import "MCLocalization.h"
#import "User.h"
#import "Helper.h"
#import "SVProgressHUD.h"
#import "AJOauth2ApiClient.h"

NSInteger const kFirstNameTag = 1234;
NSInteger const kLastNameTag = 1235;
NSInteger const kDobTag = 1237;

@interface EditProfileViewController () {
    UIDatePicker *datePicker;
}
@end

@implementation EditProfileViewController

#pragma mark View-Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation title
    self.navigationItem.title = [MCLocalization stringForKey:@"profile_edit_section_header_name"];
    
    // View BG Color
    self.view.backgroundColor = VIEW_BG_COLOR;
    
    // Get user info
    User *user = [Helper getUserPrefs];
    
    // First Name Textfield
    _firstNameTextfield.placeholder = [MCLocalization stringForKey:@"first_name_placeholder"];
    _firstNameTextfield.tag = kFirstNameTag;
    _firstNameTextfield.text = user.firstName;
    
    // Last Name Textfield
    _lastNameTextfield.placeholder = [MCLocalization stringForKey:@"last_name_placeholder"];
    _lastNameTextfield.tag = kLastNameTag;
    _lastNameTextfield.text = user.lastName;
    
    // DOB Textfield
    _dobTextfield.placeholder = [MCLocalization stringForKey:@"dob_placeholder"];
    _dobTextfield.tag = kDobTag;
    
    // Convert string to date object
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [dateFormatter dateFromString:user.dob];
    
    // DOB - UIPickerView added as input view of UITextfield
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.date = date;
    [datePicker addTarget:self action:@selector(updateTextField:)
         forControlEvents:UIControlEventValueChanged];
    [_dobTextfield setInputView:datePicker];
    
    _dobTextfield.text = [dateFormatter stringFromDate:datePicker.date];
    
    _firstNameTextfield.errorColor = _lastNameTextfield.errorColor = ERROR_LINE_COLOR;
    //_firstNameTextfield.lineColor = _lastNameTextfield.lineColor = _dobTextfield.lineColor = THEME_BG_COLOR;
    _firstNameTextfield.enableMaterialPlaceHolder = _lastNameTextfield.enableMaterialPlaceHolder = YES;
    _firstNameTextfield.autocorrectionType = _lastNameTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _firstNameTextfield.returnKeyType = UIReturnKeyNext;
    _lastNameTextfield.returnKeyType = UIReturnKeyDone;
    _firstNameTextfield.clearButtonMode = _lastNameTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    _firstNameTextfield.delegate = _lastNameTextfield.delegate = _dobTextfield.delegate = self;
    _firstNameTextfield.textColor = _lastNameTextfield.textColor = _dobTextfield.textColor = TEXT_LABEL_COLOR;
    _firstNameTextfield.presentInView = _lastNameTextfield.presentInView = _dobTextfield.presentInView = self.view;
    
    // Update button title
    [_updateButton setTitle:[MCLocalization stringForKey:@"update_btn_title"] forState:UIControlStateNormal];
    _updateButton.layer.cornerRadius = BTN_CORNER_RADIUS;
    _updateButton.layer.borderWidth = BTN_BORDER_WIDTH;
    _updateButton.layer.borderColor = BTN_BORDER_COLOR;
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

#pragma mark DateTimePicker

- (void)updateTextField:(UIDatePicker *)sender {
    NSDateFormatter *objDateFormatter = [[NSDateFormatter alloc] init];
    [objDateFormatter setDateFormat:@"MM/dd/yyyy"];
    _dobTextfield.text = [objDateFormatter stringFromDate:sender.date];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [datePicker removeFromSuperview];
}

#pragma mark AJTextfield

- (BOOL)textFieldShouldReturn:(AJTextField *)textField {
    UIView *view = [self.view viewWithTag:textField.tag + 1];
    (!view) ? [textField resignFirstResponder] : [view becomeFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(AJTextField *)textField {
    if(textField.tag == kDobTag) {
        User *user = [Helper getUserPrefs];
        
        // Convert string to date object
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSDate *date = [dateFormatter dateFromString:user.dob];
        datePicker.date = date;
        [datePicker addTarget:self action:@selector(updateTextField:)
             forControlEvents:UIControlEventValueChanged];
        [_dobTextfield setInputView:datePicker];
    }
}

- (void)textFieldDidEndEditing:(AJTextField *)textField {
    ([textField isValid]) ? [textField hideError] : [textField showError];
}

- (BOOL)textField:(AJTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    return YES;
}

- (void)textFieldDidChange:(AJTextField *)textField {
    ([textField isValid]) ? [textField hideError] : [textField showError];
}

#pragma mark IBActions

- (IBAction)update:(id)sender {
    if ([_firstNameTextfield isValid] & [_lastNameTextfield isValid] & [_dobTextfield isValid]) {
        if ([Helper isConnected])
            [self updateProfile];
        else
            [SVProgressHUD showErrorWithStatus:[MCLocalization stringForKey:@"no_internet_connectivity"]];
    }
}

#pragma mark API

- (void)updateProfile {
    [datePicker removeFromSuperview];
    [SVProgressHUD show];
    AJOauth2ApiClient *client = [AJOauth2ApiClient sharedClient];
    [client updateProfile:_firstNameTextfield.text lastName:_lastNameTextfield.text dob:_dobTextfield.text success:^(NSURLSessionDataTask *task, id responseObject) {
        if (![Helper checkResponseObject:responseObject])
            return ;
        
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        if (statusCode == SUCCESS_CODE) {
            // Username and email fields used as old one as they are non-editable fields; this is only to show local info items
            User *user = [Helper getUserPrefs];
            // User info  stored in prefs
            NSDictionary *userDict = @{@"firstname": _firstNameTextfield.text, @"lastname": _lastNameTextfield.text, @"dob": _dobTextfield.text, @"username": user.userName, @"email":user.emailAddress};
            [Helper saveUserInfoInDefaults:userDict];
            
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
                [self updateProfile];
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
        }else if (httpResponse.statusCode == BAD_REQUEST_CODE) {
            [SVProgressHUD showSuccessWithStatus:errorJsonDict[@"show_message"]];
        }
        else if (httpResponse.statusCode == INTERNAL_SERVER_ERROR_CODE) {
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
