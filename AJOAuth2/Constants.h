//
//  Constants.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 19/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define USER_INFO @"UserInformation"
#define appDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define LEFT_DRAWER_WIDTH 280
#define ERROR_LINE_COLOR [UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]
#define THEME_BG_COLOR [UIColor colorWithRed:0.113 green:0.792 blue:1.000 alpha:1.000]
#define TEXT_LABEL_COLOR [UIColor colorWithRed:0.113 green:0.792 blue:1.000 alpha:1.000]

#define BTN_CORNER_RADIUS 3.0f
#define BTN_BORDER_COLOR [UIColor lightGrayColor].CGColor
#define BTN_BORDER_WIDTH 1.0f

#define PREFS [NSUserDefaults standardUserDefaults]
#define VIEW_BG_COLOR [UIColor whiteColor]

#define BAD_REQUEST_CODE 400
#define UNAUTHORIZED_CODE 401
#define SUCCESS_CODE 201
#define INTERNAL_SERVER_ERROR_CODE 500

#define REGEX_PASSWORD @"^[A-Za-z0-9_!@#]{8,15}$"
#define HOST_URL @"(http|https)/YOUR_WEB_SERVER_URL"
#define PLACEHOLDER_IMAGE [UIImage imageNamed:@"placeholder"]
#define SCALED_WIDTH_SIZE 200
#define SCALED_HEIGHT_SIZE 200

#endif /* Constants_h */
