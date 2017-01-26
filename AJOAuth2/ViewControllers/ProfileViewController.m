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
#import "User.h"
#import "Helper.h"
#import "SVProgressHUD.h"


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
    
//    // Get user info from NSUserDefaults
//    NSData *myObject = [PREFS objectForKey:USER_INFORMATION];
//    User *user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData: myObject];
//    NSLog(@"%@", user.description);
//    
//    // Username
//    _userName.text = user.userName;
//    
//    // Email
//    _emailAddress.text = user.emailAddress;
    
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
    NSData *myObject = [PREFS objectForKey:USER_INFORMATION];
    User *user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData: myObject];
    NSLog(@"%@", user.description);
    
    // TODO: Refresh token/ Expiration time handling later on
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [manager.requestSerializer setAuthorizationHeaderFieldWithCredential:[AFOAuthCredential credentialWithOAuthToken:user.accessToken tokenType:user.tokenType]];
    [manager POST:SHOW_PROFILE_URI
       parameters:@{}
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSLog(@"Success: %@", responseObject);
              [SVProgressHUD dismiss];
              NSDictionary *jsonDict = (NSDictionary *)responseObject;
              if (!jsonDict)
                  return;
              if ([jsonDict isKindOfClass:[NSDictionary class]] == NO)
                  NSAssert(NO, @"Expected an Dictionary, got %@", NSStringFromClass([jsonDict class]));
              
              // Adding user credential dict into response dict
              NSDictionary *dict = @{@"accessToken":user.accessToken, @"refreshToken":user.refreshToken, @"tokenType":user.tokenType};
              NSMutableDictionary * mutableDict = [NSMutableDictionary dictionary];
              [mutableDict addEntriesFromDictionary:dict];
              [mutableDict addEntriesFromDictionary:jsonDict];
              NSLog(@"Mutable Dict: %@", mutableDict);
              
              // User information updated with username, email address, first name, last name, dob
              User *user = [[User alloc] initWithAttributes:mutableDict];
              NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
              [PREFS setObject:myEncodedObject forKey:USER_INFORMATION];
              [PREFS synchronize];
              NSLog(@"%@", user.description);
              
              // Get user info
              NSData *myObject = [PREFS objectForKey:USER_INFORMATION];
              user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData: myObject];
              
              // Username
              _userNameLabel.text = [NSString stringWithFormat:@"@%@", user.userName];
              
              // Email Address
              _emailAddressLabel.text = user.emailAddress;
              
              // Full Name
              _fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
              
              // DOB
              // TODO: DOB format should fix from API side
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Failure: %@", error);
          }];
}

#pragma mark Sign out

- (void)signOut {
    // Remove credentials from userdefaults as well as from AFOAuthCredential
    [AFOAuthCredential deleteCredentialWithIdentifier:SERVICE_PROVIDER_IDENTIFIER];
    [PREFS removeObjectForKey:USER_INFORMATION];
    [PREFS synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
