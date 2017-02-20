//
//  SignupViewController.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 20/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AJTextField.h"

@interface SignupViewController : UIViewController <UITextFieldDelegate> {
    UIDatePicker *datePicker;
}

@property (weak, nonatomic) IBOutlet AJTextField *firstNameTextfield;
@property (weak, nonatomic) IBOutlet AJTextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet AJTextField *emailTextfield;
@property (weak, nonatomic) IBOutlet AJTextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet AJTextField *displayNameTextfield;
@property (weak, nonatomic) IBOutlet AJTextField *dobTextfield;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

- (IBAction)signup:(id)sender;

@end
