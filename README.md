# AJOAuth2
AJOAuth2 example is showing the process of authenticating against an OAuth 2 provider.

### Description
This project makes it easy to integrate:
> User Component
* oAuth2 - process of authenticating and authorization.

This example is based on [OAuth 2.0 Protocol](https://tools.ietf.org/html/draft-ietf-oauth-v2-10). It implements the native application which is written in ObjC and supports end-user authorization and authentication. Furthermore it also supports the user credentials flow from end-user for their username and password and use them directly to obtain an access token thereafter show profile and you can change edit the profile and change password of user.

# Table Of Contents
* [Requirements](#requirements)
* [Documentation](#documentation)
* [Dependency Management](#dependency-management)
* [Localization](#localization)
* [Roadmap](#roadmap)
* [Contributing & Pull Requests](#contribution-pr)
* [License](#license)

# <a name="requirements"> Requirements
1. Xcode 8
2. CocoaPods, Here is the [Installation Guide](https://guides.cocoapods.org/using/getting-started.html)
3. Min iOS Version `9.3`

# <a name="documentation"> Documentation
Follow along the [Wiki](https://github.com/ajabble/AJOAuth2/wiki) to find out more.

# <a name="dependency-management"> Dependency Management
#### Cocoapods
Below are the third-party libraries used in this application demo, It offers us to easy and fast integration.

* `pod 'AFOAuth2Manager'` => mechanism of oAuth2
* `pod 'MCLocalization'` => Support Localization stuff (with multiple languages)
* `pod 'SVProgressHUD'` => Loading wait Indicators
* `pod 'JJMaterialTextField'` => Materialized Textfield
* `pod 'LGSideMenuController'` => Slider Animation
* `pod 'SDWebImage', '~>3.8'` => Image Caching and load on UIImageView

# <a name="localization"> Localization
Keep all strings in localization files right from the beginning. It is good not only for translations but also for finding user-facing text quickly stuff.
If you want to support any other language, Let say German language, you need only two things to do make it work.
* Add `de.json` file into the project and always better to add json file under `Supporting files` folder structure. Also, copy *key-value pairs* from `en.json` and add values to their text languages in `de.json`.
* Modify `getLanguages()` method which is defined in *Helper.m* and add `de` is internal_name and `German` is display_name of the language.
```ruby
return @{
         @"languages": @[
                        @{ @"internal_name":@"en" , @"display_name":@"English" },
                        @{ @"internal_name":@"hi" , @"display_name":@"Hindi"},
                        @{ @"internal_name":@"de" , @"display_name":@"German"}
                       ]
      };
```

# <a name="roadmap"> Roadmap
Here's the TODO list for the next release (**2.0**).
* [ ] Refactoring of source code.
* [ ] Add API and UI tests.
* [ ] Correct all issues.

# <a name="contribution-pr"> Contributing & Pull Requests
Patches and pull requests are welcome! We are sorry if it takes a while to review them, but sooner or later we will get to yours.
Note that we are using the git-flow model of branching and releasing, so **please create pull requests against the develop branch.**

# <a name="license"> License

AJOAuth2 is available under the MIT license. See the LICENSE file for more info.
