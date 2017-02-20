//
//  AJTextField.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 16/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "AJTextField.h"
#import "MCLocalization.h"

NSString *const REGEX = @"regex"; // Key for regex
NSString *const MESSAGE = @"message"; // key for regex message, when invalid
NSString *const imageName = @"error.png"; // Image name for showing error on textfield
NSInteger const fontSize = 15; // Font size of the message
NSInteger const paddingInErrorPopUp = 8; // Padding in pixels for the popup
NSString *const fontName = @"Helvetica"; // Font style name of the message

#define messageValidateLength [MCLocalization stringForKey:@"field_cannot_be_blank"] // Default message for validating length, you can also assign message separately using method 'updateLengthValidationMsg:' for textfields.
#define popUpBgColor [UIColor colorWithWhite:1.0 alpha:1.0] // Background color of message popup
#define fontColor [UIColor colorWithRed:0.702 green:0.000 blue:0.000 alpha:1.000]  // Font color of the message

/**
 * AJPopUp interface for ErrorPopup when validate with regex.
 *
 */
@interface AJPopUp : UIView

@property (nonatomic, assign) CGRect showOnRect;
@property (nonatomic, assign) NSInteger popWidth;
@property (nonatomic, assign) CGRect fieldFrame;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) UIColor *popUpColor;

@end

@implementation AJPopUp
@synthesize showOnRect, popWidth, message, fieldFrame, popUpColor;

#pragma mark AJPopUp methods

- (void)drawRect:(CGRect)rect {
    const CGFloat *color = CGColorGetComponents(popUpColor.CGColor);
    UIGraphicsBeginImageContext(CGSizeMake(30, 20));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, color[0], color[1], color[2], 1);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 7.0, [UIColor blackColor].CGColor);
    CGPoint points[3] = { CGPointMake(15, 5), CGPointMake(25, 25),
        CGPointMake(5,25)};
    CGContextAddLines(ctx, points, 3);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGRect imgframe = CGRectMake((showOnRect.origin.x+((showOnRect.size.width-30)/2)), ((showOnRect.size.height/2)+showOnRect.origin.y), 30, 13);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:viewImage highlightedImage:nil];
    [self addSubview:imageView];
    NSDictionary *dict = NSDictionaryOfVariableBindings(imageView);
    //    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    //    [imageView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[imageView(%f)]", imgframe.origin.x, imgframe.size.width] options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    //    [imageView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[imageView(%f)]", imgframe.origin.y, imgframe.size.height] options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    CGSize size = [self.message boundingRectWithSize:CGSizeMake(fieldFrame.size.width-(paddingInErrorPopUp*2), 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    size = CGSizeMake(ceilf(size.width), ceilf(size.height));
    
    // View on which label appears
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    [self insertSubview:view belowSubview:imageView];
    view.backgroundColor = popUpColor;
    view.layer.cornerRadius = 5.0;
    view.layer.shadowColor = [[UIColor blackColor] CGColor];
    view.layer.shadowRadius = 5.0;
    view.layer.shadowOpacity = 1.0;
    view.layer.shadowOffset = CGSizeMake(0, 0);
    view.translatesAutoresizingMaskIntoConstraints = NO;
    dict = NSDictionaryOfVariableBindings(view);
    [view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[view(%f)]",fieldFrame.origin.x+(fieldFrame.size.width-(size.width+(paddingInErrorPopUp*2))),size.width+(paddingInErrorPopUp*2)] options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    [view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[view(%f)]",imgframe.origin.y+imgframe.size.height,size.height+(paddingInErrorPopUp*2)] options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    
    // Label message
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    messageLabel.font = font;
    messageLabel.numberOfLines = 0;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.text = self.message;
    messageLabel.textColor = fontColor;
    [view addSubview:messageLabel];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    dict = NSDictionaryOfVariableBindings(messageLabel);
    [messageLabel.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[messageLabel(%f)]",(float)paddingInErrorPopUp,size.width] options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    [messageLabel.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[messageLabel(%f)]",(float)paddingInErrorPopUp,size.height] options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    [self removeFromSuperview];
    return NO;
}

@end


/**
 * AJTextFieldValidatorDelegate interface for handling delegates
 *
 */
@interface AJTextFieldValidatorDelegate : NSObject<UITextFieldDelegate>

@property (retain, nonatomic) id <UITextFieldDelegate> delegate;
@property (assign, nonatomic) BOOL isValidOnCharacterChanged;
@property (assign, nonatomic) BOOL isValidOnResign;
@property (strong, nonatomic) AJPopUp *popUp;
@end

@implementation AJTextFieldValidatorDelegate

#pragma mark - AJTextFieldValidatorDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if([_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
        return [_delegate textFieldShouldBeginEditing:textField];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if([_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
        return [_delegate textFieldShouldEndEditing:textField];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if([_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
        [_delegate textFieldDidBeginEditing:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([_delegate respondsToSelector:@selector(textFieldDidEndEditing:)])
        [_delegate textFieldDidEndEditing:textField];
    [_popUp removeFromSuperview];
    
    if(_isValidOnResign)
        [(AJTextField *)textField isValid];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [(AJTextField *)textField dismissPopup];
    if(_isValidOnCharacterChanged)
        [(AJTextField *)textField performSelector:@selector(isValid) withObject:nil afterDelay:0.1];
    else
        [(AJTextField *)textField setRightView:nil];
    if([_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
        return [_delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if([_delegate respondsToSelector:@selector(textFieldShouldClear:)])
        return [_delegate textFieldShouldClear:textField];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([_delegate respondsToSelector:@selector(textFieldShouldReturn:)])
        return [_delegate textFieldShouldReturn:textField];
    
    return YES;
}

- (void)setDelegate:(id<UITextFieldDelegate>)aDelegate {
    _delegate = aDelegate;
}

@end

/**
 * AJTextField interface for handling error message with regular expressions.
 *
 */
@interface AJTextField()

@property (strong, nonatomic) NSMutableArray *regexArray;
@property (strong, nonatomic) NSString *stringLengthValidationMessage;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) AJPopUp *popUp;
@property (strong, nonatomic) AJTextFieldValidatorDelegate *fieldValidatorDelegate;

@end

@implementation AJTextField

#pragma mark setup methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (void)setDelegate:(id<UITextFieldDelegate>)aDelegate{
    _fieldValidatorDelegate.delegate = aDelegate;
    super.delegate = _fieldValidatorDelegate;
}

- (void)setup {
    _isRequired = YES;
    _isValidOnResign = YES;
    _isValidOnCharacterChanged = YES;
    
    _regexArray = [[NSMutableArray alloc] init];
    _stringLengthValidationMessage = [messageValidateLength copy];
    _fieldValidatorDelegate = [[AJTextFieldValidatorDelegate alloc] init];
    _fieldValidatorDelegate.isValidOnCharacterChanged = _isValidOnCharacterChanged;
    _fieldValidatorDelegate.isValidOnResign = _isValidOnResign;
}

#pragma mark AJTextField methods

- (void)addRegex:(NSString *)stringRegex withMessage:(NSString *)message {
    NSDictionary *regexDict = @{REGEX:stringRegex, MESSAGE: message};
    [_regexArray addObject:regexDict];
}

- (void)updateLengthValidationMessage:(NSString *)message {
    _stringLengthValidationMessage = [message copy];
}

- (BOOL)isValidRegex {
    for (NSDictionary* regexDictionary in _regexArray) {
        NSLog(@"%@",regexDictionary.description);
        NSString* regexPattern = [regexDictionary objectForKey:REGEX];
        if(self.text.length !=0 && regexPattern.length != 0 && ![self validateString:self.text withRegex:regexPattern]) {
            [self showErrorIconForMessage:[regexDictionary objectForKey:MESSAGE]];
            return NO;
        }
    }
    self.rightView=nil;
    
    return YES;
}

- (BOOL)isValid {
    if(_isRequired) {
        if([self.text length] == 0){
            [self showErrorIconForMessage:_stringLengthValidationMessage];
            return NO;
        }
    }
    return ([self isValidRegex]) ? YES : NO;
}

- (void)clickOnError {
    [self showErrorWithMessage];
}

- (void)dismissPopup {
    [_popUp removeFromSuperview];
}

- (BOOL)validateString:(NSString*)stringToSearch withRegex:(NSString*)regexString {
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexString];
    return [regex evaluateWithObject:stringToSearch];
}

- (void)showErrorIconForMessage:(NSString *)message {
    UIButton *errorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [errorButton addTarget:self action:@selector(clickOnError) forControlEvents:UIControlEventTouchUpInside];
    [errorButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    self.rightView = errorButton;
    self.rightViewMode = UITextFieldViewModeAlways;
    self.message = [message copy];
}

- (void)showErrorWithMessage {
    _popUp = [[AJPopUp alloc] initWithFrame:CGRectZero];
    _popUp.message = self.message;
    _popUp.popUpColor = popUpBgColor;
    _popUp.showOnRect = [self convertRect:self.rightView.frame toView:_presentInView];
    _popUp.fieldFrame = [self.superview convertRect:self.frame toView:_presentInView];
    _popUp.backgroundColor = [UIColor clearColor];
    [_presentInView addSubview:_popUp];
    
    _popUp.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *dict = NSDictionaryOfVariableBindings(_popUp);
    [_popUp.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_popUp]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    [_popUp.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_popUp]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing  metrics:nil views:dict]];
    
    _fieldValidatorDelegate.popUp = _popUp;
}

@end
