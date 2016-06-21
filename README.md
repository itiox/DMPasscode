# IPasscode

[![Build Status](https://img.shields.io/travis/D-32/IPasscode/master.svg?style=flat)](https://travis-ci.org/D-32/IPasscode)
[![Version](https://img.shields.io/cocoapods/v/IPasscode.svg?style=flat)](http://cocoadocs.org/docsets/IPasscode)
![License](https://img.shields.io/cocoapods/l/IPasscode.svg?style=flat)
[![twitter: @dylan36032](http://img.shields.io/badge/twitter-%40dylan36032-blue.svg?style=flat)](https://twitter.com/dylan36032)

A simple passcode screen that can be displayed manually. If Touch ID is available the user can skip the screen and instead use his fingerprint to unlock.

Can easily be customised to fit your design.

![image](http://46.105.26.1/uploads/passcode2.png)

## Installation

IPasscode is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "IPasscode"
If you're not using CocoaPods you'll find the source code files inside `Pod/Classes`. You'll also have to add the `IPasscode.bundle` to your project.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The class `IPasscode` contains following methods:
	
	+ (void)setupPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion;
	+ (void)showPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion;
	+ (void)removePasscode;
	+ (BOOL)isPasscodeSet;
	+ (void)setConfig:(IPasscodeConfig *)config;

#### PasscodeCompletionBlock(BOOL success, NSError *error)

PasscodeCompletionBlock is a custom type of block provided to `IPasscode` that returns values in the form of two parameters, a `BOOL success` and a `NSError *error`.
If `success`, then the user has successfully either setup their passcode, or successfully unlocked with their passcode.

If not `success`, then the user has either cancelled the passcode process, in which case `error` will be nil.  Or the user has failed to unlock with their passcode, in
which case `error` will not be nil.

## Customisation

You can pass `IPasscode` a configuration. Just create a new `IPasscodeConfiguration`.  
Following properties are available to customise the passcode screen:

	animationsEnabled
	backgroundColor
	navigationBarBackgroundColor
	navigationBarForegroundColor
	statusBarStyle
	fieldColor
	emptyFieldColor
    errorFont
	errorBackgroundColor
	errorForegroundColor
	descriptionColor
    inputKeyboardAppearance
    instructionsFont
    navigationBarTitle
    navigationBarFont
    navigationBarTitleColor


