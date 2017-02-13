# AJOAuth2

AJOAuth2 example is showing the process of authenticating against an OAuth 2 provider.

### Description
This project makes it easy to integrate:
> User Component
* oAuth2 - process of authenticating and authorization.

This example is based on [OAuth 2.0 Protocol](https://tools.ietf.org/html/draft-ietf-oauth-v2-10). It implements the native application which is written in ObjC and supports end-user authorization and authentication. Furthermore it also supports the user credentials flow from end-user for their username and password and use them directly to obtain an access token thereafter show profile and you can change edit the profile and change password of user.

## Getting Started
#### Requirements
1. Xcode 8
2. CocoaPods, Here is the [Installation Guide](https://guides.cocoapods.org/using/getting-started.html)
3. Min iOS Version `9.3`

#### How to run this Demo app?
1. Firstly, Download this code either as zip or Git Clone. Here is the [link](https://ajabble@bitbucket.org/ajabble/oauth2.git)
2. `pod install` or `pod update`

#### Set up Web API
[Link]()

#### Configure your client
Once you are set up with web part and had added valid OAuth2.0 client and secret. Please do required changes in **AJOauth2ApiClient** file

```ruby
BASE_URL @"YOUR_WEB_HOSTED_URL"
CLIENT_ID @"YOUR_CLIENT_ID"
SECRET_KEY @"YOUR_SECRET_KEY"
API_VERSION @"YOUR_API_VERSION"
```

#### Requesting Access to a Service
Once you have configured your client you are ready to request access to one of those services. The AJOauth2ApiClient provides different methods for this:

> signInWithUsernameAndPassword - signin with username and password. [POST]

> registerMe - signup with required fields. [POST]

> requestPassword - forgot password with email/username. [GET]

> showProfile - list the profile of user. [POST]

> changePassword - password change. [POST]

> updateProfile - user profile update. [POST]

> refreshTokenWithSuccess - to get access token when invalid. [POST]

**For example:**
```ruby
[[AJOauth2ApiClient sharedClient] signInWithUsernameAndPassword:@"YOUR_USERNAME_OR_EMAIL" password:@"YOUR_PASSWORD" success:^(AFOAuthCredential *credential) {
    } failure:^(NSError *error) {
    }];
```
**On Success**
After a successful authentication *user credential* [**i.e access_token, refresh_token, token_type, expiration_time**] will be saved, if you want to add anything more do it inside block.

**On Failure**
If the authentication did not succeed, *NSError* will be send and you may catch HTTPResponse codes and message inside this block

## Dependency Management
#### Cocoapods
Below are the third-party libraries used in this application demo, It offers us to easy and fast integration.

* `pod 'AFOAuth2Manager'` => mechanism of oAuth2
* `pod 'MCLocalization'` => Support Localization stuff (with multiple languages)
* `pod 'SVProgressHUD'` => Loading wait Indicators
* `pod 'JJMaterialTextField'` => Materialized Textfield
* `pod 'LGSideMenuController'` => Slider Animation

#### Localization
Keep all strings in localization files right from the beginning. It is good not only for translations but also for finding user-facing text quickly stuff.
If you want to support any other language instead of English, Let say add Hindi language, `hi.json` file into the project. Also, always better to add json file under `Supporting files` folder structure.

Copy *key pairs*  which is case-sensitive from `en.json` and add values to their text languages.

Load `hi.json` file in *AppDelegate.h* with default language

```ruby
NSDictionary * languageURLPairs = @{@"en":[[NSBundle mainBundle] URLForResource:@"en.json" withExtension:nil],@"hi":[[NSBundle mainBundle] URLForResource:@"hi.json" withExtension:nil]};
[MCLocalization loadFromLanguageURLPairs:languageURLPairs defaultLanguage:@"hi"];
[MCLocalization sharedInstance].language = @"hi";
```

## Contributing & Pull Requests
Patches and pull requests are welcome! We are sorry if it takes a while to review them, but sooner or later we will get to yours.
Note that we are using the git-flow model of branching and releasing, so **please create pull requests against the develop branch.**

## License

AJOAuth2 is available under the MIT license. See the LICENSE file for more info.
