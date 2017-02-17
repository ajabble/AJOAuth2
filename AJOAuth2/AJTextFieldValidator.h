//
//  AJTextFieldValidator.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 16/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <Foundation/Foundation.h>
@import JJMaterialTextField;

@interface AJTextFieldValidator : JJMaterialTextfield

@property (nonatomic,assign) BOOL isRequired; // < Default is YES, required field
@property (strong, nonatomic) UIView *presentInView; // Assign view on which you want to show popup
@property (nonatomic,assign) BOOL isValidOnCharacterChanged; // Default is YES, Use it whether you want to validate text on character change or not.
@property (nonatomic,assign) BOOL isValidOnResign; // Default is YES, Use it whether you want to validate text on resign or not.

/**
 * Use to add regex for validating textfield text, you need to specify all your regex in queue 
 * that you want to validate and their messages respectively that will show when any regex validation will fail.
 
 @param stringRegex Regex string
 @param message Message string to be displayed when given regex will fail.
 **/
- (void)addRegex:(NSString *)stringRegex withMessage:(NSString *)message;

/**
 * By default the message will be shown which is given in the macro "messageValidateLength", but you can change message for each textfield as well.
 
 @param message Message string to be displayed when length validation will fail.
 */
- (void)updateLengthValidationMessage:(NSString *)message;


/**
 * Use to perform validation
 
 @return Bool It will return YES if all provided regex validation will pass else return NO
 
 **/
- (BOOL)isValidRegex;

/**
 * Use to perform validation
 
 @return Bool It will return YES if required else return NO
 
 **/
- (BOOL)isValid;

/**
 * Use to dismiss error popup.
 
 */
- (void)dismissPopup;

@end
