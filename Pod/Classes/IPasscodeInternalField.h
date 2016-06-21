//
//  IPasscodeInternalField.h
//  Pods
//
//  Created by Dylan Marriott on 20/09/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class IPasscodeConfig;

@interface IPasscodeInternalField : UIView

@property (nonatomic, strong, readonly) UIView* emptyIndicator;
@property (nonatomic, strong, readonly) UIView* filledIndicator;
@property (nonatomic, strong) NSString* text;

- (id)initWithFrame:(CGRect)frame config:(IPasscodeConfig *)config;

@end
