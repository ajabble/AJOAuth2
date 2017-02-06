//
//  SignupViewController.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 20/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <UIKit/UIKit.h>
@import JJMaterialTextField;

@interface SignupViewController : UIViewController <UITextFieldDelegate> {
    UIDatePicker *datePicker;
}

@property (weak, nonatomic) IBOutlet JJMaterialTextfield *firstNameTextfield;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *lastNameTextfield;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *emailTextfield;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *passwordTextfield;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *displayNameTextfield;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *dobTextfield;

@property (weak, nonatomic) IBOutlet UIButton *signupButton;
- (IBAction)signup:(id)sender;

@end
