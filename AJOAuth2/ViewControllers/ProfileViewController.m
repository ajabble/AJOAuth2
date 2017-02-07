//
//  ProfileViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 24/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "ProfileViewController.h"
#import "MCLocalization.h"
#import "AFOAuth2Manager.h"
#import "Constants.h"
#import "Helper.h"
#import "SVProgressHUD.h"
#import "OAuth.h"
#import "User.h"
#import "ChangePasswordViewController.h"
#import "EditProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

#pragma mark View-Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    // Navigation title
    self.title = [MCLocalization stringForKey:@"profile_navigation_title"];
    
    // Back bar button item title
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[MCLocalization stringForKey:@"back_bar_button_item_title"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    // Right Bar Button Item image
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sign-out"] style:UIBarButtonItemStylePlain target:self action:@selector(showAlertBeforeLogOut)];
    
    // image
    _imageView.image = [UIImage imageNamed:@"circle-user"];
    
    // Basic Infoview
    self.basicInfoView.backgroundColor = THEME_BG_COLOR;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([Helper isConnected])
        [self showProfile];
    else
        [MCLocalization stringForKey:@"no_internet_connectivity"];
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
#pragma mark /ME - API

- (void)showProfile {
    [SVProgressHUD show];
    
    NSData *myObject = [PREFS objectForKey:OAUTH_INFO];
    OAuth *auth = (OAuth *)[NSKeyedUnarchiver unarchiveObjectWithData: myObject];
    NSLog(@"%@", auth.description);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithCredential:[AFOAuthCredential credentialWithOAuthToken:auth.accessToken tokenType:auth.tokenType]];
    [manager POST:SHOW_PROFILE_URI
       parameters:@{}
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
                  
                  // User information updated with username, email address, first name, last name, dob
                  User *user = [[User alloc] initWithAttributes:[jsonDict mutableCopy]];
                  NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
                  [PREFS setObject:myEncodedObject forKey:USER_INFO];
                  [PREFS synchronize];
                  NSLog(@"%@", user.description);
                  
                  // Get user info
                  NSData *myObject = [PREFS objectForKey:USER_INFO];
                  user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData: myObject];
                  
                  // Username
                  _userNameLabel.text = [NSString stringWithFormat:@"@%@", user.userName];
                  
                  // Email Address
                  _emailAddressLabel.text = user.emailAddress;
                  
                  // Full Name
                  _fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
                  
                  // DOB
                  _dobLabel.text = user.dob;
                  
                  [SVProgressHUD showSuccessWithStatus:jsonDict[@"show_message"]];
              }
              
              [SVProgressHUD dismiss];
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
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:SVProgressHUDWillAppearNotification object:nil];
                      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:SVProgressHUDWillDisappearNotification object:nil];
                      [SVProgressHUD showSuccessWithStatus:[MCLocalization stringForKey:@"sign_out_message"]];
                  });
              }else if (httpResponse.statusCode == INTERNAL_SERVER_ERROR_CODE) {
                  NSLog(@"Error Code: %@; ErrorDescription: %@", errorJsonDict[@"code"], errorJsonDict[@"error_description"]);
              }
          }];
}

#pragma mark methods

- (void)signOut {
    // Remove credentials from userdefaults as well as from AFOAuthCredential
    [AFOAuthCredential deleteCredentialWithIdentifier:SERVICE_PROVIDER_IDENTIFIER];
    [PREFS removeObjectForKey:USER_INFO];
    [PREFS removeObjectForKey:OAUTH_INFO];
    [PREFS synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertBeforeLogOut {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:[MCLocalization stringForKey:@"sign_out_prompt_title"]
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:[MCLocalization stringForKey:@"sign_out"]
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction * action) {
                                    // Handle your yes button action here
                                    [self signOut];
                                }];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:[MCLocalization stringForKey:@"cancel_button_title"]
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       // Handle cancelButton button
                                   }];
    
    [alert addAction:cancelButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark SVProgressHUD

- (void)handleNotification:(NSNotification *)notification {
    NSLog(@"Notification received: %@", notification.name);
    NSLog(@"Status user info key: %@", notification.userInfo[SVProgressHUDStatusUserInfoKey]);
    
    if([notification.name isEqualToString:SVProgressHUDWillDisappearNotification]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDWillDisappearNotification object:nil];
        [self signOut];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    if (indexPath.section == 0)
        cell.textLabel.text = [MCLocalization stringForKey:@"profile_edit_section_header_name"];
    else if (indexPath.section == 1)
        cell.textLabel.text = [MCLocalization stringForKey:@"change_password_section_header_name"];
    else
        cell.textLabel.text = [MCLocalization stringForKey:@"sign_out"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {
        [self showAlertBeforeLogOut];
        return;
    }
    
    UIViewController *vc = nil;
    if (indexPath.section == 0)
        vc = [[EditProfileViewController alloc] initWithNibName:@"EditProfileViewController" bundle:[NSBundle mainBundle]];
    else if (indexPath.section == 1)
        vc = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:[NSBundle mainBundle]];
        
    [self.navigationController pushViewController:vc animated:YES];
}

@end
