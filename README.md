# AJOAuth2

This Example is showing the process of authenticating against an OAuth 2 provider.

# Requirements
1. Xcode 8
2. Pod
3. Min iOS Version `9.3`


# How to run this Demo app?
1. Firstly, Download this code either as zip or Git Clone  `https://ajabble@bitbucket.org/ajabble/oauth2.git`
2. `pod install` optional
3. Change *Client_id and Secret Key, BaseURL* in `Constants.h`

# Dependency Management

#### Cocoapods
Below are the third-party libraries used in this application demo, It offers us to easy and fast integration.

* `pod 'AFOAuth2Manager'` => mechanism of oAuth2
* `pod 'MCLocalization'` => Support Localization stuff (multiple languages)
* `pod 'SVProgressHUD'` => Loading wait Indicators
* `pod 'JJMaterialTextField'` => Materialized Textfield
* `pod 'LGSideMenuController'` => Slider Animation

#### Localization
Keep all strings in localization files right from the beginning. It is good not only for translations but also for finding user-facing text quickly stuff.
If you want to support any other language instead of English, Let say add Hindi language, `hi.json` file into the project. Better to add under `Supporting files` folder structure.
Copy *key pairs* from `en.json` and add values to their text languages.

Load `hi.json` file in *AppDelegate.h* with default language

```
NSDictionary * languageURLPairs = @{@"en":[[NSBundle mainBundle] URLForResource:@"en.json" withExtension:nil],@"hi":[[NSBundle mainBundle] URLForResource:@"hi.json" withExtension:nil]};
[MCLocalization loadFromLanguageURLPairs:languageURLPairs defaultLanguage:@"hi"];
```

# Features
This project makes it easy to:
> User Component
* oAuth2 - process of authenticating and authorization.

#### TODO
Baisc idea is to create Forum based demo
> Profile Viewer Component

> Role Editor Component

> Thread Component

* Post [CRUDs]
* Comments


# License

AJOAuth2 is available under the MIT license. See the LICENSE file for more info.
