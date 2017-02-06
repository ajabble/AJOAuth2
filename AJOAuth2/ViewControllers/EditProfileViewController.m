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
#import "OAuth.h"
#import "AFOAuth2Manager.h"

#define firstNamefieldTag 1234
#define lastNameTextfieldTag 1235
#define dobTextfieldTag 1237

@interface EditProfileViewController () {
    UIDatePicker *datePicker;
}
@end

@implementation EditProfileViewController

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
    _firstNameTextfield.tag = firstNamefieldTag;
    _firstNameTextfield.text = user.firstName;
    
    // Last Name Textfield
    _lastNameTextfield.placeholder = [MCLocalization stringForKey:@"last_name_placeholder"];
    _lastNameTextfield.tag = lastNameTextfieldTag;
    _lastNameTextfield.text = user.lastName;
    
    _firstNameTextfield.errorColor = _lastNameTextfield.errorColor = ERROR_COLOR;
    _firstNameTextfield.lineColor = _lastNameTextfield.lineColor  = _dobTextfield.lineColor  =  LINE_COLOR;
    _firstNameTextfield.enableMaterialPlaceHolder = _lastNameTextfield.enableMaterialPlaceHolder = YES;
    _firstNameTextfield.autocorrectionType = _lastNameTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _firstNameTextfield.returnKeyType = UIReturnKeyNext;
    _lastNameTextfield.returnKeyType = UIReturnKeyDone;
    _firstNameTextfield.clearButtonMode = _lastNameTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    _firstNameTextfield.delegate = _lastNameTextfield.delegate = _dobTextfield.delegate = self;
    
    // DOB - UIPickerView added as input view of UITextfield
    _dobTextfield.placeholder = [MCLocalization stringForKey:@"dob_placeholder"];
    _dobTextfield.tag = dobTextfieldTag;
    
    // Convert string to date object
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [dateFormatter dateFromString:user.dob];
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.date = date;
    [datePicker addTarget:self action:@selector(updateTextField:)
         forControlEvents:UIControlEventValueChanged];
    [_dobTextfield setInputView:datePicker];
    
    _dobTextfield.text = [dateFormatter stringFromDate:datePicker.date];
    
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

- (BOOL)textFieldShouldReturn:(JJMaterialTextfield *)textField {
    UIView *view = [self.view viewWithTag:textField.tag + 1];
    if (!view)
        [textField resignFirstResponder];
    else
        [view becomeFirstResponder];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(JJMaterialTextfield *)textField {
    if(textField.tag == dobTextfieldTag) {
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
    
    [SVProgressHUD show];
    
    NSData *myObject = [PREFS objectForKey:OAUTH_INFO];
    OAuth *auth = (OAuth *)[NSKeyedUnarchiver unarchiveObjectWithData: myObject];
    NSLog(@"%@", auth.description);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithCredential:[AFOAuthCredential credentialWithOAuthToken:auth.accessToken tokenType:auth.tokenType]];
    [manager POST:EDIT_PROFILE_URI
       parameters:@{@"firstname": _firstNameTextfield.text, @"lastname": _lastNameTextfield.text, @"dob": _dobTextfield.text}
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
              
              id errorJson = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
              
              NSDictionary *errorJsonDict = (NSDictionary *)errorJson;
              if (!errorJsonDict)
                  return;
              if ([errorJsonDict isKindOfClass:[NSDictionary class]] == NO)
                  NSAssert(NO, @"Expected an Dictionary, got %@", NSStringFromClass([errorJsonDict class]));
              
              // TODO: handling later on with refresh token
              if (httpResponse.statusCode == UNAUTHORIZED_CODE) {
                  NSLog(@"%@",errorJsonDict.description);
              }else if (httpResponse.statusCode == INTERNAL_SERVER_ERROR_CODE) {
                  NSLog(@"Error Code: %@; ErrorDescription: %@", errorJsonDict[@"code"], errorJsonDict[@"error_description"]);
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
