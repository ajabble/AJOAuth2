//
//  ChangePasswordViewController.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 06/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AJTextField.h"

@interface ChangePasswordViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet AJTextField *oldPasswordTextfield;
@property (weak, nonatomic, getter=theNewPasswordTextfield) IBOutlet AJTextField *newPasswordTextfield;
@property (weak, nonatomic) IBOutlet AJTextField *confirmPasswordTextfield;
@property (weak, nonatomic) IBOutlet UIButton *updatePasswordButton;

@end
