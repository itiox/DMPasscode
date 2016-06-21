//
//  IPasscode.m
//  IPasscode
//
//  Created by Dylan Marriott on 20/09/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "IPasscode.h"
#import "IPasscodeInternalNavigationController.h"
#import "IPasscodeInternalViewController.h"
#import "IKeychain.h"

#ifdef __IPHONE_8_0
#import <LocalAuthentication/LocalAuthentication.h>
#endif

#undef NSLocalizedString
#define NSLocalizedString(key, comment) \
[bundle localizedStringForKey:(key) value:@"" table:@"IPasscodeLocalisation"]

static IPasscode* instance;
static const NSString* KEYCHAIN_NAME = @"passcode";
static NSBundle* bundle;
NSString * const IUnlockErrorDomain = @"com.IPasscode.error.unlock";

@interface IPasscode () <IPasscodeInternalViewControllerDelegate>
@end

@implementation IPasscode {
    PasscodeCompletionBlock _completion;
    IPasscodeInternalViewController* _passcodeViewController;
    int _mode; // 0 = setup, 1 = input
    int _count;
    NSString* _prevCode;
    IPasscodeConfig* _config;
}

+ (void)initialize {
    [super initialize];
    instance = [[IPasscode alloc] init];
    bundle = [IPasscode bundleWithName:@"IPasscode.bundle"];
}

- (instancetype)init {
    if (self = [super init]) {
        _config = [[IPasscodeConfig alloc] init];
    }
    return self;
}

+ (NSBundle*)bundleWithName:(NSString*)name {
    NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
    NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:frameworkBundlePath]){
        return [NSBundle bundleWithPath:frameworkBundlePath];
    }
    return nil;
}

#pragma mark - Public
+ (void)setupPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion {
    [instance setupPasscodeInViewController:viewController completion:completion];
}

+ (void)showPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion {
    [instance showPasscodeInViewController:viewController completion:completion];
}

+ (void)removePasscode {
    [instance removePasscode];
}

+ (BOOL)isPasscodeSet {
    return [instance isPasscodeSet];
}

+ (void)setConfig:(IPasscodeConfig *)config {
    [instance setConfig:config];
}

#pragma mark - Instance methods
- (void)setupPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion {
    _completion = completion;
    [self openPasscodeWithMode:0 viewController:viewController];
}

- (void)showPasscodeInViewController:(UIViewController *)viewController completion:(PasscodeCompletionBlock)completion {
    NSAssert([self isPasscodeSet], @"No passcode set");
    _completion = completion;
    LAContext* context = [[LAContext alloc] init];
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:NSLocalizedString(@"IPasscode_touchid_reason", nil) reply:^(BOOL success, NSError* error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    switch (error.code) {
                        case LAErrorUserCancel:
                            _completion(NO, nil);
                            break;
                        case LAErrorSystemCancel:
                            _completion(NO, nil);
                            break;
                        case LAErrorAuthenticationFailed:
                            _completion(NO, error);
                            break;
                        case LAErrorPasscodeNotSet:
                        case LAErrorTouchIDNotEnrolled:
                        case LAErrorTouchIDNotAvailable:
                        case LAErrorUserFallback:
                            [self openPasscodeWithMode:1 viewController:viewController];
                            break;
                    }
                } else {
                    _completion(success, nil);
                }
            });
        }];
    } else {
        // no touch id available
        [self openPasscodeWithMode:1 viewController:viewController];
    }
}

- (void)removePasscode {
    [[IKeychain defaultKeychain] removeObjectForKey:KEYCHAIN_NAME];
}

- (BOOL)isPasscodeSet {
    BOOL ret = [[IKeychain defaultKeychain] objectForKey:KEYCHAIN_NAME] != nil;
    return ret;
}

- (void)setConfig:(IPasscodeConfig *)config {
    _config = config;
}

#pragma mark - Private
- (void)openPasscodeWithMode:(int)mode viewController:(UIViewController *)viewController {
    _mode = mode;
    _count = 0;
    _passcodeViewController = [[IPasscodeInternalViewController alloc] initWithDelegate:self config:_config];
    IPasscodeInternalNavigationController* nc = [[IPasscodeInternalNavigationController alloc] initWithRootViewController:_passcodeViewController];
    [nc setModalPresentationStyle:UIModalPresentationFormSheet];
    [viewController presentViewController:nc animated:YES completion:nil];
    if (_mode == 0) {
        [_passcodeViewController setInstructions:NSLocalizedString(@"IPasscode_enter_new_code", nil)];
    } else if (_mode == 1) {
        [_passcodeViewController setInstructions:NSLocalizedString(@"IPasscode_enter_to_unlock", nil)];
    }
}

- (void)closeAndNotify:(BOOL)success withError:(NSError *)error {
    [_passcodeViewController dismissViewControllerAnimated:YES completion:^() {
        _completion(success, error);
    }];
}

#pragma mark - IPasscodeInternalViewControllerDelegate
- (void)enteredCode:(NSString *)code {
    if (_mode == 0) {
        if (_count == 0) {
            _prevCode = code;
            [_passcodeViewController setInstructions:NSLocalizedString(@"IPasscode_repeat", nil)];
            [_passcodeViewController setErrorMessage:@""];
            [_passcodeViewController reset];
        } else if (_count == 1) {
            if ([code isEqualToString:_prevCode]) {
                [[IKeychain defaultKeychain] setObject:code forKey:KEYCHAIN_NAME];
                [self closeAndNotify:YES withError:nil];
            } else {
                [_passcodeViewController setInstructions:NSLocalizedString(@"IPasscode_enter_new_code", nil)];
                [_passcodeViewController setErrorMessage:NSLocalizedString(@"IPasscode_not_match", nil)];
                [_passcodeViewController reset];
                _count = 0;
                return;
            }
        }
    } else if (_mode == 1) {
        if ([code isEqualToString:[[IKeychain defaultKeychain] objectForKey:KEYCHAIN_NAME]]) {
            [self closeAndNotify:YES withError:nil];
        } else {
            if (_count == 1) {
                [_passcodeViewController setErrorMessage:NSLocalizedString(@"IPasscode_1_left", nil)];
            } else {
                [_passcodeViewController setErrorMessage:[NSString stringWithFormat:NSLocalizedString(@"IPasscode_n_left", nil), 2 - _count]];
            }
            [_passcodeViewController reset];
            if (_count >= 2) { // max 3 attempts
                NSError *errorMatchingPins = [NSError errorWithDomain:IUnlockErrorDomain code:IErrorUnlocking userInfo:nil];
                [self closeAndNotify:NO withError:errorMatchingPins];
            }
        }
    }
    _count++;
}

- (void)canceled {
    _completion(NO, nil);
}

@end
