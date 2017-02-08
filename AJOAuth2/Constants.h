//
//  Constants.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 19/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define DEV_ENV 1

#define BASE_URL @"http://localhost/auth/web/api/"
#define CLIENT_ID @"1_2f2y20gltutcw8oo0cwwo0ogcgso880o048g4c40go0w0cosw8"
#define SECRET_KEY @"60pcfpi2ig4k0408g4w0k40os44w0ows0gs0ggwsc4kwgs4g00"
#define SCOPE @"API"
#define EMAIL_CONFIRMATION @"0"
#define API_VERSION @"1.0"
#define ACCEPT_VERSION_HEADER_FIELD_KEY @"X-Accept-Version" 
#define SERVICE_PROVIDER_IDENTIFIER [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#define USER_INFO @"UserInformation"
#define OAUTH_INFO @"OAuthInformation"

#define FETCH_ACCESS_TOKEN_URI @"user/access/token"
#define CHANGE_PASSWORD_URI @"user/change/password"
#define SHOW_PROFILE_URI @"user/profile/show"
#define USER_REGISTER_URI @"user/register"
#define REQUEST_PASSWORD_URI @"user/resetting/request/email"
#define CHANGE_PASSWORD_URI @"user/change/password"
#define EDIT_PROFILE_URI @"user/profile/edit"


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

#endif /* Constants_h */
