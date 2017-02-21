//
//  ChangeLanguageViewController.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 20/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "ChangeLanguageViewController.h"
#import "MCLocalization.h"
#import "Helper.h"
#import "AppDelegate.h"

@interface ChangeLanguageViewController ()

@property (strong, nonatomic) NSDictionary *languageDict;
@property (assign, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation ChangeLanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Display languages and select default language depends upon MCLocalization shared preferences
    _languageDict = [Helper displayLanguages];
    NSArray *allKeys = [_languageDict allKeys];
    for (NSUInteger i = 0; i < [allKeys count]; i++) {
        NSString *key = [allKeys objectAtIndex:i];
        if ([key isEqualToString:[MCLocalization sharedInstance].language]) {
            _selectedIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        }
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _languageDict.count;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = [[_languageDict allValues] objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [[_languageDict allKeys] objectAtIndex:indexPath.row];
    
    cell.accessoryType = [indexPath isEqual:_selectedIndexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *prevIndexPath = _selectedIndexPath;
    _selectedIndexPath = indexPath;
    if (prevIndexPath != indexPath)
        appDelegate.isLanguageChanged = YES;
    [MCLocalization sharedInstance].language = [[_languageDict allKeys] objectAtIndex:indexPath.row];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:prevIndexPath, indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
}

@end
