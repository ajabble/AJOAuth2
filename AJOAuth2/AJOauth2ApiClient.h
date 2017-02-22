//
//  AJOauth2ApiClient.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 08/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//


#import "AFOAuth2Manager.h"

@interface AJOauth2ApiClient : AFOAuth2Manager

typedef void (^AJOauth2ApiClientSuccess)(NSURLSessionDataTask *task, id responseObject);
typedef void (^AJOauth2ApiClientFailure)(NSURLSessionDataTask *task, NSError *error);
typedef void (^AJOauth2ApiClientRetryBlock)(NSURLSessionDataTask *task, NSError *error);
typedef NSURLSessionDataTask *(^AJOauth2ApiClientCreateTask)(AJOauth2ApiClientRetryBlock retryBlock);

+ (AJOauth2ApiClient *)sharedClient;
- (AFOAuthCredential *)retrieveCredential;

- (void)signInWithUsernameAndPassword:(NSString *)username
                             password:(NSString *)password
                              success:(void (^)(AFOAuthCredential *credential))success
                              failure:(void (^)(NSError *error))failure;

- (void)registerMe:(NSString *)username
          password: (NSString *)password
             email: (NSString *)email
         firstName: (NSString *)firstName
          lastName: (NSString *)lastName
               dob: (NSString *)dob
           success:(AJOauth2ApiClientSuccess)success
           failure:(AJOauth2ApiClientFailure)failure;

- (void)requestPassword:(NSString *)username
                success:(AJOauth2ApiClientSuccess)success
                failure:(AJOauth2ApiClientFailure)failure;

- (void)showProfile:(AJOauth2ApiClientSuccess)success
            failure:(AJOauth2ApiClientFailure)failure;

- (void)changePassword:(NSString *)newPassword
       oldPassword: (NSString *)oldPassword
               success:(AJOauth2ApiClientSuccess)success
               failure:(AJOauth2ApiClientFailure)failure;

- (void)updateProfile:(NSString *)firstName
             lastName:(NSString *)lastName
                  dob:(NSString *)dob
              success:(AJOauth2ApiClientSuccess)success
              failure:(AJOauth2ApiClientFailure)failure;

- (void)updateProfileImage:(UIImage *)image success:(AJOauth2ApiClientSuccess)success
                   failure:(AJOauth2ApiClientFailure)failure;

- (void)refreshTokenWithSuccess:(void (^)(AFOAuthCredential *newCredential))success
                        failure:(void (^)(NSError *error))failure;

@end
