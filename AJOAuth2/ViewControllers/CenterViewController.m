//
//  CenterViewController.m
//

#import "CenterViewController.h"
#import "MCLocalization.h"
#import <LGSideMenuController/UIViewController+LGSideMenuController.h>

@interface CenterViewController ()
@end

@implementation CenterViewController

#pragma mark View-Life Cycle

- (id)init {
    self = [super init];
    if (self) {
        // Center Navigation title
        self.title = [MCLocalization stringForKey:@"center_navigation_title"];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[MCLocalization stringForKey:@"back_bar_button_item_title"] style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backBarButtonItem;
        
        
        // Background Color        
        self.view.backgroundColor = VIEW_BG_COLOR;
        
        // Left Bar Button Item image
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(showLeftView)];
    }
    
    return self;
}

#pragma mark - LGSlider

- (void)showLeftView {
    [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
    [self.sideMenuController.leftViewController viewWillAppear:YES];
}

@end
