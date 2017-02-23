//
//  ProfileViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 24/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "ProfileViewController.h"
#import "MCLocalization.h"
#import "Helper.h"
#import "SVProgressHUD.h"
#import "User.h"
#import "ChangePasswordViewController.h"
#import "EditProfileViewController.h"
#import "ChangeLanguageViewController.h"
#import "AJOauth2ApiClient.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic)NSArray *listItemsArray;

@end

@implementation ProfileViewController

#pragma mark View-Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self displayUIElements];
    
    if ([Helper isConnected])
        [self showProfile];
    else
        [MCLocalization stringForKey:@"no_internet_connectivity"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // User display info
    [self userDisplayInfo];
    if (appDelegate.isLanguageChanged) {
        [self displayUIElements];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)displayUIElements {
    _listItemsArray = @[[MCLocalization stringForKey:@"profile_edit_section_header_name"], [MCLocalization stringForKey:@"change_password_section_header_name"], [MCLocalization stringForKey:@"change_language_section_header_name"], [MCLocalization stringForKey:@"sign_out"]];
    
    // Navigation title
    self.title = [MCLocalization stringForKey:@"profile_navigation_title"];
    
    // Back bar button item title
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[MCLocalization stringForKey:@"back_bar_button_item_title"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    // Right Bar Button Item image
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sign-out"] style:UIBarButtonItemStylePlain target:self action:@selector(showAlertBeforeLogOut)];
    
    // Basic Infoview
    self.basicInfoView.backgroundColor = THEME_BG_COLOR;
}

- (void)userDisplayInfo {
    // Get user info
    User *user = [Helper getUserPrefs];
    
    // Username
    _userNameLabel.text = [NSString stringWithFormat:@"@%@", user.userName];
    
    // Email Address
    _emailAddressLabel.text = user.emailAddress;
    
    // Full Name
    _fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    
    // DOB
    _dobLabel.text = user.dob;
    
    // Avatar ImageView
    [_avatarImageView setShowActivityIndicatorView:YES];
    [_avatarImageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOST_URL, user.avatarImageURLString]] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageRefreshCached];
    
    _avatarImageView.layer.cornerRadius = BTN_CORNER_RADIUS;
    _avatarImageView.layer.masksToBounds = YES;
    _avatarImageView.userInteractionEnabled = YES;
    [_avatarImageView addGestureRecognizer:[self imageViewRecognizer]];
}

#pragma mark - UITapGestureRecognizer

- (UITapGestureRecognizer *)imageViewRecognizer {
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandler:)];
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.numberOfTapsRequired = 1;
    
    return singleTapRecognizer;
}

- (void)gestureHandler:(UIGestureRecognizer *)gestureRecognizer {
    [self showImageAlertOptions];
}

- (void)updateProfile:(UIImage *)image {
    AJOauth2ApiClient *client = [AJOauth2ApiClient sharedClient];
    [client updateProfileImage:image success:^(NSURLSessionDataTask *task, id responseObject) {
        if (![Helper checkResponseObject:responseObject])
            return ;
        
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        if (statusCode == SUCCESS_CODE) {
            //_avatarImageView.image = image;
            [_avatarImageView setShowActivityIndicatorView:YES];
            [_avatarImageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
             [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOST_URL, jsonDict[@"image_url"]]] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageRefreshCached];
            
            User *user = [Helper getUserPrefs];
            NSDictionary *userDict = @{@"firstname": user.firstName, @"lastname": user.lastName, @"dob": user.dob, @"username": user.userName, @"email":user.emailAddress, @"image_url":jsonDict[@"image_url"]};
            [Helper saveUserInfoInDefaults:userDict];
            
            [SVProgressHUD showSuccessWithStatus:jsonDict[@"show_message"]];
        }else if (statusCode == BAD_REQUEST_CODE) {
            NSLog(@"Error Code: %@; ErrorDescription: %@", jsonDict[@"code"], jsonDict[@"error_description"]);
            [SVProgressHUD showErrorWithStatus:jsonDict[@"show_message"]];
        }else if (statusCode == INTERNAL_SERVER_ERROR_CODE) {
            NSLog(@"Error Code: %@; ErrorDescription: %@", jsonDict[@"code"], jsonDict[@"error_description"]);
            [SVProgressHUD dismiss];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (![Helper isWebUrlValid:error])
            return;
        
        id errorJson = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
        if (![Helper checkResponseObject:errorJson])
            return ;
        
        NSDictionary *errorJsonDict = (NSDictionary *)errorJson;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"%zd", httpResponse.statusCode);
        if (httpResponse.statusCode == UNAUTHORIZED_CODE) {
            [client refreshTokenWithSuccess:^(AFOAuthCredential *newCredential) {
                [self updateProfile:image];
            } failure:^(NSError *error) {
                [SVProgressHUD dismiss];
                if (![Helper isWebUrlValid:error])
                    return;
                
                id errorJson = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
                
                if (![Helper checkResponseObject:errorJson])
                    return ;
                NSDictionary *errorJsonDict = (NSDictionary *)errorJson;
                NSLog(@"Error Code: %@; ErrorDescription: %@", errorJsonDict[@"code"], errorJsonDict[@"error_description"]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:SVProgressHUDWillDisappearNotification object:nil];
                    [SVProgressHUD showSuccessWithStatus:[MCLocalization stringForKey:@"sign_out_message"]];
                });
            }];
        }else if (httpResponse.statusCode == BAD_REQUEST_CODE) {
            NSLog(@"Error Code: %@; ErrorDescription: %@", errorJsonDict[@"code"], errorJsonDict[@"error_description"]);
        }else if (httpResponse.statusCode == INTERNAL_SERVER_ERROR_CODE) {
            NSLog(@"Error Code: %@; ErrorDescription: %@", errorJsonDict[@"code"], errorJsonDict[@"error_description"]);
        }
    }];
}

#pragma mark ME - API

- (void)showProfile {
    [SVProgressHUD show];
    AJOauth2ApiClient *client = [AJOauth2ApiClient sharedClient];
    [client showProfile:^(NSURLSessionDataTask *task, id responseObject) {
        if (![Helper checkResponseObject:responseObject])
            return ;
        
        NSDictionary *jsonDict = (NSDictionary *)responseObject;
        NSInteger statusCode = [jsonDict[@"code"] integerValue];
        if (statusCode == SUCCESS_CODE) {
            // User information stored in NSUserDefaults
            [Helper saveUserInfoInDefaults:jsonDict];
            
            // Display info
            [self userDisplayInfo];
        }
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (![Helper isWebUrlValid:error])
            return;
        
        id errorJson = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
        if (![Helper checkResponseObject:errorJson])
            return ;
        
        NSDictionary *errorJsonDict = (NSDictionary *)errorJson;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        NSLog(@"%zd", httpResponse.statusCode);
        if (httpResponse.statusCode == UNAUTHORIZED_CODE) {
            [client refreshTokenWithSuccess:^(AFOAuthCredential *newCredential) {
                [self showProfile];
            } failure:^(NSError *error) {
                [SVProgressHUD dismiss];
                if (![Helper isWebUrlValid:error])
                    return;
                
                id errorJson = [NSJSONSerialization JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] options:0 error:nil];
                
                if (![Helper checkResponseObject:errorJson])
                    return ;
                NSDictionary *errorJsonDict = (NSDictionary *)errorJson;
                NSLog(@"Error Code: %@; ErrorDescription: %@", errorJsonDict[@"code"], errorJsonDict[@"error_description"]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:SVProgressHUDWillDisappearNotification object:nil];
                    [SVProgressHUD showSuccessWithStatus:[MCLocalization stringForKey:@"sign_out_message"]];
                });
            }];
        }else if (httpResponse.statusCode == BAD_REQUEST_CODE) {
            NSLog(@"Error Code: %@; ErrorDescription: %@", errorJsonDict[@"code"], errorJsonDict[@"error_description"]);
        }else if (httpResponse.statusCode == INTERNAL_SERVER_ERROR_CODE) {
            NSLog(@"Error Code: %@; ErrorDescription: %@", errorJsonDict[@"code"], errorJsonDict[@"error_description"]);
        }
    }];
}

#pragma mark methods

- (void)signOut {
    [Helper removeUserPrefs];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertBeforeLogOut {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:[MCLocalization stringForKey:@"sign_out_prompt_title"]
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:[MCLocalization stringForKey:@"sign_out"]
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction * action) {
                                    // Handle your yes button action here
                                    [self signOut];
                                }];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:[MCLocalization stringForKey:@"cancel_button_title"]
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       // Handle cancelButton button
                                   }];
    
    [alert addAction:cancelButton];
    [alert addAction:yesButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showImageAlertOptions {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:nil
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *chooseFromLibraryButton = [UIAlertAction
                                              actionWithTitle:[MCLocalization stringForKey:@"choose_from_library_option_title"]
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action) {
                                                  [self loadImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
                                              }];
    UIAlertAction *takeProfilePhotoButton = [UIAlertAction
                                             actionWithTitle:[MCLocalization stringForKey:@"take_profile_photo_option_title"]
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                                                 if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                    [self loadImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
                                                 } else {
                                                     UIAlertController *alert = [UIAlertController alertControllerWithTitle:[MCLocalization stringForKey:@"warning_title"] message:[MCLocalization stringForKey:@"no_camera_available"] preferredStyle:UIAlertControllerStyleAlert];
                                                     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[MCLocalization stringForKey:@"cancel_button_title"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                     }];
                                                     [alert addAction:cancelAction];
                                                     [self presentViewController:alert animated:YES completion:nil];
                                                 }
                                             }];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:[MCLocalization stringForKey:@"cancel_button_title"]
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       // Handle cancelButton button
                                   }];
    
    [alert addAction:cancelButton];
    [alert addAction:takeProfilePhotoButton];
    [alert addAction:chooseFromLibraryButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadImagePickerWithSource:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
    pickerView.allowsEditing = YES;
    pickerView.delegate = self;
    pickerView.sourceType = type;
    [self presentViewController:pickerView animated:YES completion:nil];
}

#pragma mark SVProgressHUD

- (void)handleNotification:(NSNotification *)notification {
    NSLog(@"Notification received: %@", notification.name);
    NSLog(@"Status user info key: %@", notification.userInfo[SVProgressHUDStatusUserInfoKey]);
    
    if ([notification.name isEqualToString:SVProgressHUDWillDisappearNotification]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SVProgressHUDWillDisappearNotification object:nil];
        [self signOut];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _listItemsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text =  [_listItemsArray objectAtIndex:indexPath.section];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 3) {
        [self showAlertBeforeLogOut];
        return;
    }
    
    UIViewController *vc = nil;
    if (indexPath.section == 0)
        vc = [[EditProfileViewController alloc] initWithNibName:@"EditProfileViewController" bundle:[NSBundle mainBundle]];
    else if (indexPath.section == 1)
        vc = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:[NSBundle mainBundle]];
    else if (indexPath.section == 2)
        vc = [[ChangeLanguageViewController alloc] initWithNibName:@"ChangeLanguageViewController" bundle:[NSBundle mainBundle]];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - PickerDelegates

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // You may change scaled width and height from the macros which is defined in Constants.h
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    image = [Helper scaleImage:image toSize:CGSizeMake(SCALED_WIDTH_SIZE, SCALED_HEIGHT_SIZE)];
    [picker dismissViewControllerAnimated:YES completion:^{
        // Call update profile API
        [self updateProfile:image];
    }];
}

@end
