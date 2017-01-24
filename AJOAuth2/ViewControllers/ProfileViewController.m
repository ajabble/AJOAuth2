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
    
    // Get user info from NSUserDefaults
    NSData *myObject = [PREFS objectForKey:USER_INFORMATION];
    User *user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData: myObject];
    NSLog(@"%@", user.description);
    
    // Username
    _userName.text = user.userName;
    
    // Email
    _emailAddress.text = user.emailAddress;
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

#pragma mark Sign out

- (void)signOut {
    // Remove credentials from userdefaults as well as from AFOAuthCredential
    [AFOAuthCredential deleteCredentialWithIdentifier:SERVICE_PROVIDER_IDENTIFIER];
    [PREFS removeObjectForKey:USER_INFORMATION];
    [PREFS synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
