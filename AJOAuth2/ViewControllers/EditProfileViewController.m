//
//  EditProfileViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 06/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "EditProfileViewController.h"
#import "Constants.h"
#import "MCLocalization.h"
#import "User.h"
#import "Helper.h"
#import "SVProgressHUD.h"
#import "AJOauth2ApiClient.h"

#define kFirstNamefieldTag 1234
#define kLastNameTextfieldTag 1235
#define kDobTextfieldTag 1237

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
    NSData *myObject = [PREFS objectForKey:USER_INFO];
    User *user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData: myObject];
    
    // First Name Textfield
    _firstNameTextfield.placeholder = [MCLocalization stringForKey:@"first_name_placeholder"];
    _firstNameTextfield.tag = kFirstNamefieldTag;
    _firstNameTextfield.text = user.firstName;
    
    // Last Name Textfield
    _lastNameTextfield.placeholder = [MCLocalization stringForKey:@"last_name_placeholder"];
    _lastNameTextfield.tag = kLastNameTextfieldTag;
    _lastNameTextfield.text = user.lastName;
    
    // DOB Textfield
    _dobTextfield.placeholder = [MCLocalization stringForKey:@"dob_placeholder"];
    _dobTextfield.tag = kDobTextfieldTag;
    
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

#pragma mark UITextfield

- (BOOL)textFieldShouldReturn:(JJMaterialTextfield *)textField {
    UIView *view = [self.view viewWithTag:textField.tag + 1];
    (!view) ? [textField resignFirstResponder] : [view becomeFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(JJMaterialTextfield *)textField {
    if(textField.tag == kDobTextfieldTag) {
        NSData *myObject = [PREFS objectForKey:USER_INFO];
        User *user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData: myObject];
        
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

- (void)textFieldDidEndEditing:(JJMaterialTextfield *)textField {
    (textField.text.length == 0) ? [textField showError] : [textField hideError];
}

#pragma mark IBActions

- (IBAction)update:(id)sender {
    if (_firstNameTextfield.text.length == 0) {
        [_firstNameTextfield showError];
        return;
    }
    if (_lastNameTextfield.text.length == 0) {
        [_lastNameTextfield showError];
        return;
    }
    if (_dobTextfield.text.length == 0){
        [_dobTextfield showError];
        return;
    }
    
    if ([Helper isConnected])
        [self updateProfile];
    else
        [SVProgressHUD showErrorWithStatus:[MCLocalization stringForKey:@"no_internet_connectivity"]];
}

#pragma mark API

- (void)updateProfile {
    [datePicker removeFromSuperview];
    [_firstNameTextfield hideError];
    [_lastNameTextfield hideError];
    [_dobTextfield hideError];
    
    [SVProgressHUD show];
    AJOauth2ApiClient *client = [AJOauth2ApiClient sharedClient];
    [client updateProfile:_firstNameTextfield.text lastName:_lastNameTextfield.text dob:_dobTextfield.text success:^(NSURLSessionDataTask *task, id responseObject) {
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
