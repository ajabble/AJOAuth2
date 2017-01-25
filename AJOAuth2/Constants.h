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

#define BASE_URL @"http://192.168.1.167/Asinha-oauth2/authoauth/web/api/"
#define CLIENT_ID @"1_3l9u3nrrlbk0oogkokos8wog84ok0w4owwoo0cgwocck8owow0"
#define SECRET_KEY @"4n1hjpvoe2asg08gw4c8kcso0ogwo8g8scs8ow4o4o84o44co4"
#define SERVICE_PROVIDER_IDENTIFIER [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#define USER_INFORMATION @"UserInformation"

#define FETCH_ACCESS_TOKEN_URI @"user/access/token"
#define CHANGE_PASSWORD_URI @"user/change/password"
#define SHOW_PROFILE_URI @"user/profile/show"
#define USER_REGISTER_URI @"user/register"
#define RESET_PASSWORD_URI @"user/resetting/check/email"

#define LEFT_SIDE_RESTORATION_KEY @"LeftSideViewControllerRestorationKey"
#define CENTER_NAVIGATION_RESTORATION_KEY @"CenterNavigationControllerRestorationKey"
#define LEFT_NAVIGATION_RESTORATION_KEY @"LeftNavigationControllerRestorationKey"
#define MM_DRAWER_RESTORATION_KEY @"MMDrawerRestorationKey"

#define LEFT_DRAWER_WIDTH 240

#define ERROR_COLOR [UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]
#define LINE_COLOR [UIColor colorWithRed:0.482 green:0.800 blue:1.000 alpha:1.000]
#define BTN_CORNER_RADIUS 3.0

#define PREFS [NSUserDefaults standardUserDefaults]


#endif /* Constants_h */
