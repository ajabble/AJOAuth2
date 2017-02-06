//
//  LoginViewController.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 20/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <UIKit/UIKit.h>
@import JJMaterialTextField;

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *emailTextfield;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *passwordTextfield;

- (IBAction)signin:(id)sender;
- (IBAction)forgotPassword:(id)sender;

@end
