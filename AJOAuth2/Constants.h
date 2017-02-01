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

#define BASE_URL @"http://localhost/Asinha-oauth2/authoauth/web/api/"
#define CLIENT_ID @"1_1mgfw7skldxc44040wcocg40kowo04ss84k0sco80w88kswg8s"
#define SECRET_KEY @"4ym9cg6dckg08ccoccc4og8o0k8wowcgc0sk8gckwwgw0gk0oo"
#define SERVICE_PROVIDER_IDENTIFIER [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#define USER_INFORMATION @"UserInformation"

#define FETCH_ACCESS_TOKEN_URI @"user/access/token"
#define CHANGE_PASSWORD_URI @"user/change/password"
#define SHOW_PROFILE_URI @"user/profile/show"
#define USER_REGISTER_URI @"user/register"
#define REQUEST_PASSWORD_URI @"user/resetting/request/email"

#define LEFT_SIDE_RESTORATION_KEY @"LeftSideViewControllerRestorationKey"
#define CENTER_NAVIGATION_RESTORATION_KEY @"CenterNavigationControllerRestorationKey"
#define LEFT_NAVIGATION_RESTORATION_KEY @"LeftNavigationControllerRestorationKey"
#define MM_DRAWER_RESTORATION_KEY @"MMDrawerRestorationKey"

#define LEFT_DRAWER_WIDTH 240

#define ERROR_COLOR [UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]
#define LINE_COLOR [UIColor colorWithRed:0.482 green:0.800 blue:1.000 alpha:1.000]
#define BTN_CORNER_RADIUS 3.0f
#define BTN_BORDER_COLOR [UIColor whiteColor].CGColor
#define BTN_BORDER_WIDTH 1.0f

#define PREFS [NSUserDefaults standardUserDefaults]
#define VIEW_BG_COLOR [UIColor colorWithRed:0.211 green:0.658 blue:0.913 alpha:1.000]

#endif /* Constants_h */
