//
//  Helper.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 23/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Helper : NSObject

/**
 * Used to check internet connectivity
 */
+ (BOOL)isConnected;

/**
 * Used to check response object type
 
 @param responseObject id type of reponse object
 */
+ (BOOL)checkResponseObject:(id)responseObject;

/**
 * Used to validate web url address
 
 @param error NSError
 */
+ (BOOL)isWebUrlValid:(NSError *)error;

/**
 * Used to get User preferences from NSUserDefault class
 */
+ (User *)getUserPrefs;

/**
 * Used to remove User preferences from NSUserDefault class
 */
+ (void)removeUserPrefs;

/**
 * Used to save User Object in NSUserDefault class
 
 @param userInfo user information expect dictionary type
 */
+ (void)saveUserInfoInDefaults:(NSDictionary *)userInfo;

/**
 * Used to get support languages with their internal and display names
 */
+ (NSDictionary *)getLanguages;

/**
 * Used to Load support languages with their JSON files
 */
+ (NSDictionary *)loadLanguagesFromUrl;

/**
 * Used to display languages with their internal and display names on the view itself
 */
+ (NSDictionary *)displayLanguages;

/**
 * Used to scale image with newSize
 
 @param image image name
 @param newSize new frame width and height size
 */
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize;

/**
 * Used to load image url
 
 @param avatarImageURLString image url string
 */
+ (NSData *)avatarImageUrl:(NSString *)avatarImageURLString;

@end
