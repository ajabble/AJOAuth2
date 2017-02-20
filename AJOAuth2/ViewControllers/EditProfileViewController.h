//
//  EditProfileViewController.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 06/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AJTextField.h"

@interface EditProfileViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet AJTextField *firstNameTextfield;
@property (weak, nonatomic) IBOutlet AJTextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet AJTextField *dobTextfield;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;

- (IBAction)update:(id)sender;

@end
