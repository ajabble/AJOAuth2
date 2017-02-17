//
//  SignupViewController.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 20/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AJTextFieldValidator.h"

@interface SignupViewController : UIViewController <UITextFieldDelegate> {
    UIDatePicker *datePicker;
}

@property (weak, nonatomic) IBOutlet AJTextFieldValidator *firstNameTextfield;
@property (weak, nonatomic) IBOutlet AJTextFieldValidator *lastNameTextfield;
@property (weak, nonatomic) IBOutlet AJTextFieldValidator *emailTextfield;
@property (weak, nonatomic) IBOutlet AJTextFieldValidator *passwordTextfield;
@property (weak, nonatomic) IBOutlet AJTextFieldValidator *displayNameTextfield;
@property (weak, nonatomic) IBOutlet AJTextFieldValidator *dobTextfield;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

- (IBAction)signup:(id)sender;

@end
