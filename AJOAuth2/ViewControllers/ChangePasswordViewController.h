//
//  ChangePasswordViewController.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 06/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJMaterialTextfield.h"

@interface ChangePasswordViewController : UIViewController
@property (weak, nonatomic, getter=theNewPasswordTextfield) IBOutlet JJMaterialTextfield *newPasswordTextfield;
@property (weak, nonatomic) IBOutlet JJMaterialTextfield *confirmPasswordTextfield;
@property (weak, nonatomic) IBOutlet UIButton *updatePasswordButton;

@end
