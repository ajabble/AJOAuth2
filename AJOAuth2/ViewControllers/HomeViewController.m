//
//  RightSideViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 19/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"
#import "MCLocalization.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "UIViewController+LGSideMenuController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

#pragma mark View- Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navigation title
    self.navigationItem.title = [MCLocalization stringForKey:@"login_sign_up_nav_title"];
    
    // Sign up Button title
    [_signupButton setTitle:[MCLocalization stringForKey:@"signup_btn_title"] forState:UIControlStateNormal];
    
    // Login Button title
    [_loginButton setTitle:[MCLocalization stringForKey:@"login_btn_title"] forState:UIControlStateNormal];
    
    // Buttons corner radius
    _signupButton.layer.cornerRadius = _loginButton.layer.cornerRadius = BTN_CORNER_RADIUS;
}

#pragma mark methods

- (IBAction)login:(id)sender {
    // Go to LoginVC
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (IBAction)signup:(id)sender {
    // Go to Sign Up VC
    SignupViewController *signupVC = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:signupVC animated:YES];
}

@end