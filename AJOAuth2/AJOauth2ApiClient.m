//
//  AJOauth2ApiClient.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 08/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "AJOauth2ApiClient.h"
#import "Constants.h"


#define BASE_URL @"http://localhost/auth/web/api/"
#define CLIENT_ID @"1_2f2y20gltutcw8oo0cwwo0ogcgso880o048g4c40go0w0cosw8"
#define SECRET_KEY @"60pcfpi2ig4k0408g4w0k40os44w0ows0gs0ggwsc4kwgs4g00"
#define SCOPE @"API"
#define EMAIL_CONFIRMATION @"0"
#define API_VERSION @"1.0"
#define ACCEPT_VERSION_HEADER_FIELD_KEY @"X-Accept-Version"

#define FETCH_ACCESS_TOKEN_URI @"user/access/token"
#define REFRESH_TOKEN_URI @"user/refresh/token"
#define SHOW_PROFILE_URI @"user/profile/show"
#define USER_REGISTER_URI @"user/register"
#define REQUEST_PASSWORD_URI @"user/resetting/request/email"
#define CHANGE_PASSWORD_URI @"user/change/password"
#define UPDATE_PROFILE_URI @"user/profile/edit"

@implementation AJOauth2ApiClient

+ (AJOauth2ApiClient *)sharedClient {
    static AJOauth2ApiClient *_sharedClient = nil;
    static dispatch_once_t _onceToken;
    
    dispatch_once(&_onceToken, ^{
        NSURL *url = [NSURL URLWithString:BASE_URL];
        _sharedClient = [AJOauth2ApiClient managerWithBaseURL:url clientID:CLIENT_ID secret:SECRET_KEY];
        [_sharedClient.requestSerializer setValue:API_VERSION forHTTPHeaderField:ACCEPT_VERSION_HEADER_FIELD_KEY];
    });
    
    return _sharedClient;
}

#pragma mark AFOAuthCredential

- (AFOAuthCredential *)retrieveCredential {
    return [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
}

#pragma mark API
#pragma mark FETCH_ACCESS_TOKEN_URI
- (void)signInWithUsernameAndPassword:(NSString *)username
                             password:(NSString *)password
                              success:(void (^)(AFOAuthCredential *credential))success
                              failure:(void (^)(NSError *error))failure {
    [AJOauth2ApiClient sharedClient].useHTTPBasicAuthentication = NO;
    NSLog(@"[%@ %@]", [self class], FETCH_ACCESS_TOKEN_URI);
     
    [self authenticateUsingOAuthWithURLString:FETCH_ACCESS_TOKEN_URI username:username password:password scope:SCOPE success:^(AFOAuthCredential *credential) {
        NSLog(@"Token: %@", credential.description);
        
        // Store credential
        [AFOAuthCredential storeCredential:credential withIdentifier:self.serviceProviderIdentifier];
        
        if (success) {
            success(credential);
        }
        
    } failure:^(NSError *error) {
        NSLog(@"Error: %@", error.description);
        failure(error);
    }];
}

#pragma mark USER_REGISTER_URI
- (void)registerMe:(NSString *)username
          password: (NSString *)password
             email: (NSString *)email
         firstName: (NSString *)firstName
          lastName: (NSString *)lastName
               dob: (NSString *)dob
           success:(AJOauth2ApiClientSuccess)success
           failure:(AJOauth2ApiClientFailure)failure {
    NSLog(@"[%@ %@]", [self class], USER_REGISTER_URI);
    
    [self POST:USER_REGISTER_URI
    parameters:@{@"client_id": CLIENT_ID, @"client_secret": SECRET_KEY, @"scope": SCOPE, @"email_confirmation": EMAIL_CONFIRMATION, @"username": username, @"password": password, @"email": email, @"firstname": firstName, @"lastname": lastName, @"dob": dob}
      progress:nil
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           NSLog(@"Success: %@", responseObject);
           success(task, responseObject);
       }
       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSLog(@"Failure: %@", error);
           failure(task, error);
       }];
}

#pragma mark REQUEST_PASSWORD_URI
- (void)requestPassword:(NSString *)username
                success:(AJOauth2ApiClientSuccess)success
                failure:(AJOauth2ApiClientFailure)failure {
    NSLog(@"[%@ %@]", [self class], REQUEST_PASSWORD_URI);
    
    [self GET:REQUEST_PASSWORD_URI parameters:@{@"username": username}
     progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          NSLog(@"Success: %@", responseObject);
          success(task, responseObject);
      }
      failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"Failure: %@", error);
          failure(task, error);
      }];
}

#pragma mark SHOW_PROFILE_URI
- (void)showProfile:(AJOauth2ApiClientSuccess)success
            failure:(AJOauth2ApiClientFailure)failure {
    NSLog(@"[%@ %@]", [self class], SHOW_PROFILE_URI);
    
    [[AJOauth2ApiClient sharedClient].requestSerializer setAuthorizationHeaderFieldWithCredential:[self retrieveCredential]];
    [self POST:SHOW_PROFILE_URI
    parameters:@{}
      progress:nil
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           NSLog(@"Success: %@", responseObject);
           success(task, responseObject);
       }
       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           failure(task, error);
       }];
}

#pragma mark CHANGE_PASSWORD_URI
- (void)changePassword:(NSString *)newPassword
           oldPassword: (NSString *)oldPassword
               success:(AJOauth2ApiClientSuccess)success
               failure:(AJOauth2ApiClientFailure)failure {
    NSLog(@"[%@ %@]", [self class], CHANGE_PASSWORD_URI);
    
    [[AJOauth2ApiClient sharedClient].requestSerializer setAuthorizationHeaderFieldWithCredential:[self retrieveCredential]];
    [self POST:CHANGE_PASSWORD_URI
    parameters:@{@"old_password": oldPassword, @"password": newPassword}
      progress:nil
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           NSLog(@"Success: %@", responseObject);
           success(task, responseObject);
       }
       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSLog(@"Failure: %@", error);
           failure(task, error);
       }];
}

#pragma mark UPDATE_PROFILE_URI
- (void)updateProfile:(NSString *)firstName
             lastName:(NSString *)lastName
                  dob:(NSString *)dob
              success:(AJOauth2ApiClientSuccess)success
              failure:(AJOauth2ApiClientFailure)failure {
    NSLog(@"[%@ %@]", [self class], UPDATE_PROFILE_URI);
    
    [[AJOauth2ApiClient sharedClient].requestSerializer setAuthorizationHeaderFieldWithCredential:[self retrieveCredential]];
    [self POST:UPDATE_PROFILE_URI
    parameters:@{@"firstname": firstName, @"lastname": lastName, @"dob": dob}
      progress:nil
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           NSLog(@"Success: %@", responseObject);
           success(task, responseObject);
       }
       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSLog(@"Failure: %@", error);
           failure(task, error);
       }];
}

#pragma mark REFRESH_TOKEN_URI
- (void)refreshTokenWithSuccess:(void (^)(AFOAuthCredential *newCredential))success
                        failure:(void (^)(NSError *error))failure {
    NSLog(@"[%@ %@]", [self class], REFRESH_TOKEN_URI);
    
    AFOAuthCredential *credential = [self retrieveCredential];
    if (credential == nil) {
        NSLog(@"[%@]: credential is nil", credential);
        if (failure) {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:@"Failed to get credentials" forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"world" code:200 userInfo:errorDetail];
            failure(error);
        }
        return;
    }
    
    NSLog(@"[%@ %@]: refreshing credential, credential.refreshToken: %@", [self class], REFRESH_TOKEN_URI, credential.refreshToken);
    [self authenticateUsingOAuthWithURLString:REFRESH_TOKEN_URI refreshToken:credential.refreshToken success:^(AFOAuthCredential * _Nonnull newCredential) {
        NSLog(@"[%@ %@]: refreshed access token %@", [self class], REFRESH_TOKEN_URI, newCredential.accessToken);
        [AFOAuthCredential storeCredential:newCredential withIdentifier:self.serviceProviderIdentifier];
        
        if (success) {
            success(newCredential);
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"[%@ %@]: an error occurred refreshing credential: %@", [self class], REFRESH_TOKEN_URI, error);
        if (failure) {
            failure(error);
        }
        
    }];
}

@end
