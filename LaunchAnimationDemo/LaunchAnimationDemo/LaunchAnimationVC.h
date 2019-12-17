//
//  LaunchAnimationVC.h
//  Accompany
//
//  Created by Hock on 2019/12/16.
//  Copyright © 2019 chenlong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface  LaunchAnimationVC : UIViewController

@property (nonatomic, copy) void (^playFinished)(void);
@property (nonatomic, strong) NSString *videoUrl;//视频路径

@end

NS_ASSUME_NONNULL_END
