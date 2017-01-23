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

#define LEFT_SIDE_RESTORATION_KEY @"LeftSideViewControllerRestorationKey"
#define CENTER_NAVIGATION_RESTORATION_KEY @"CenterNavigationControllerRestorationKey"
#define LEFT_NAVIGATION_RESTORATION_KEY @"LeftNavigationControllerRestorationKey"
#define MM_DRAWER_RESTORATION_KEY @"MMDrawerRestorationKey"

#define LEFT_DRAWER_WIDTH 240

#define ERROR_COLOR [UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]
#define LINE_COLOR [UIColor colorWithRed:0.482 green:0.800 blue:1.000 alpha:1.000]
#define BTN_CORNER_RADIUS 3.0

#define BASE_URI @"http://127.0.0.1:8000"
#define CLIENT_ID @"2_2s4ujt4hg9s0sossks08cs0oks84kow0gkwcckocw4ccskwo4o"
#define SECRET_KEY @"5iyuqbnubvokg800c8008s4k4ww8w88kw4sw8s4o4o000gc4wc"
#define SERVICE_PROVIDER_IDENTIFIER [[[UIDevice currentDevice] identifierForVendor] UUIDString]


#define GET_TOKEN_API_NAME @"/oauth/v2/token"
#define GET_USERS_API_NAME @"/users"

#endif /* Constants_h */
