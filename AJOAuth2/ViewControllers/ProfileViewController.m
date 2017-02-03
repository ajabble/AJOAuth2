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

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = [MCLocalization stringForKey:@"profile_navigation_title"];
    
    // Right Bar Button Item image
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sign-out"] style:UIBarButtonItemStylePlain target:self action:@selector(signOut)];
    
    // image
    _imageView.image = [UIImage imageNamed:@"circle-user"];
    
    if ([Helper isConnected])
        [self showProfile];
    else
        [MCLocalization stringForKey:@"NO_INTERNET_CONNECTIVITY"];
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
    
    // TODO: Refresh token/ Expiration time handling later on
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
              
              // TODO: handling later on
              
          }];
}

#pragma mark Sign out

- (void)signOut {
    // Remove credentials from userdefaults as well as from AFOAuthCredential
    [AFOAuthCredential deleteCredentialWithIdentifier:SERVICE_PROVIDER_IDENTIFIER];
    [PREFS removeObjectForKey:USER_INFO];
    [PREFS removeObjectForKey:OAUTH_INFO];
    [PREFS synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
