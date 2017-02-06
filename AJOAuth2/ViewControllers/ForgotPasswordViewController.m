//
//  ForgotPasswordViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 20/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "AFOAuth2Manager.h"
#import "MCLocalization.h"
#import "Constants.h"
#import "Helper.h"
#import "SVProgressHUD.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

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
    _emailTextfield.enableMaterialPlaceHolder = YES;
    _emailTextfield.placeholder = [MCLocalization stringForKey:@"email_placeholder"];
    _emailTextfield.returnKeyType = UIReturnKeyNext;
    _emailTextfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailTextfield.errorColor = ERROR_COLOR;
    _emailTextfield.lineColor = LINE_COLOR;
    _emailTextfield.enableMaterialPlaceHolder = YES;
    _emailTextfield.delegate = self;
    _emailTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    
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
    
    if ([Helper isConnected])
        [self requestPassword];
    else
        [SVProgressHUD showErrorWithStatus:[MCLocalization stringForKey:@"no_internet_connectivity"]];
    
    //    if ([Helper validateEmail:_emailTextfield.text]) {
    //        [_emailTextfield hideError];
    //        NSLog(@"Proceed to next!!");
    //    } else {
    //        [_emailTextfield showError];
    //    }
}

#pragma mark Request Password API method

- (void)requestPassword {
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [manager GET:REQUEST_PASSWORD_URI parameters:@{@"username": _emailTextfield.text}
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
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDWillDisappearNotification object:nil];
    }
}

@end
