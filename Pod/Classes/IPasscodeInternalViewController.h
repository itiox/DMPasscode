//
//  IPasscodeInternalViewController.h
//  Pods
//
//  Created by Dylan Marriott on 20/09/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol IPasscodeInternalViewControllerDelegate <NSObject>

- (void)enteredCode:(NSString *)code;
- (void)canceled;

@end

@class IPasscodeConfig;

@interface IPasscodeInternalViewController : UIViewController

- (id)initWithDelegate:(id<IPasscodeInternalViewControllerDelegate>)delegate config:(IPasscodeConfig *)config;
- (void)reset;
- (void)setErrorMessage:(NSString *)errorMessage;
- (void)setInstructions:(NSString *)instructions;

@end
