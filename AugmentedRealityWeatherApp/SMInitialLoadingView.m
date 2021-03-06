//
//  SMLoadView.m
//  AugmentedRealityWeatherApp
//
//  Created by Shaun Merritt on 9/24/14.
//  Copyright (c) 2014 True Merit Development. All rights reserved.
//

#import "SMInitialLoadingView.h"
#import "SMStyleKit.h"
#import "SMWeatherModel.h"
#import "SMWeatherInfoCardView.h"
#import "SMViewController.h"
#import <POP.h>

@interface SMInitialLoadingView (){
 
    CAShapeLayer *_bezier;
    SMWeatherModel *_weatherModel;
    NSArray *_currentWeather;
    SMWeatherInfo *_weatherInfoForCity;
    SMViewController *_viewController;
    
}

@end

@implementation SMInitialLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *bezierPath = [SMStyleKit drawLocationIcon];
    bezierPath.lineCapStyle = kCGLineCapRound;
    
    _bezier = [[CAShapeLayer alloc] init];
    _bezier.path          = bezierPath.CGPath;
    _bezier.strokeColor   = [UIColor whiteColor].CGColor;
    _bezier.fillColor     = [UIColor clearColor].CGColor;
    _bezier.lineWidth     = 5.4;
    _bezier.strokeStart   = 0.0;
    _bezier.strokeEnd     = 1.0;
    [self.layer addSublayer:_bezier];
    
    CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd.duration  = 1.2;
    animateStrokeEnd.delegate = self;
    animateStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0f];
    animateStrokeEnd.toValue   = [NSNumber numberWithFloat:1.0f];
    [animateStrokeEnd setValue:_bezier forKey:@"layer"];
    [_bezier addAnimation:animateStrokeEnd forKey:@"strokeEndAnimation"];
    
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    POPSpringAnimation *scaleTheLocationIcon = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleTheLocationIcon.toValue = [NSValue valueWithCGPoint:CGPointMake(1.5, 1.5)];
    scaleTheLocationIcon.springBounciness = 8.0f; // Between 0-20
    scaleTheLocationIcon.springSpeed = 20.0f; // Between 0-20
    [self pop_addAnimation:scaleTheLocationIcon forKey:@"scaleTheLocationIcon"];

    
    POPSpringAnimation *spinTheLocationIcon = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    spinTheLocationIcon.toValue = @(M_PI*4);
    spinTheLocationIcon.springBounciness = 7;
    spinTheLocationIcon.springSpeed = 2.0f;
    [self.layer pop_addAnimation:spinTheLocationIcon forKey:@"spinTheLocationIcon"];
    
    POPSpringAnimation *scaleDownLocationIcon = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    scaleDownLocationIcon.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
    scaleDownLocationIcon.springBounciness = 8.0f; // Between 0-20
    scaleDownLocationIcon.springSpeed = 20.0f; // Between 0-20
    [self pop_addAnimation:scaleDownLocationIcon forKey:@"scaleDownLocationIcon"];

    
    spinTheLocationIcon.completionBlock = ^(POPAnimation *frame, BOOL finished) {
    
        POPSpringAnimation *scaleTheLocationIconOffScreen = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleTheLocationIconOffScreen.toValue = [NSValue valueWithCGPoint:CGPointMake(10, 10)];
        scaleTheLocationIconOffScreen.springBounciness = 4.0f; // Between 0-20
        scaleTheLocationIconOffScreen.springSpeed = 20.0f; // Between 0-20
        [self pop_addAnimation:scaleTheLocationIconOffScreen forKey:@"scaleTheLocationIconOffScreen"];
    
        POPSpringAnimation *fadeLocationIcon = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
        fadeLocationIcon.toValue = @(0.0);
        fadeLocationIcon.springBounciness = 2.0f;
        fadeLocationIcon.springSpeed = 20.0f;
        [self pop_addAnimation:fadeLocationIcon forKey:@"fadeLocationIcon"];
        fadeLocationIcon.completionBlock = ^(POPAnimation *fade, BOOL finished) {
            
            [_bezier removeFromSuperlayer];
            
            POPSpringAnimation *showFrame = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
            showFrame.toValue = [NSValue valueWithCGRect:CGRectMake((int) self.window.frame.origin.x + 10, (int) self.window.frame.origin.y + 30, (int) self.window.frame.size.width - 20, self.window.frame.size.height)];
            showFrame.springBounciness = 4.0f;
            showFrame.springSpeed = 1.0f;
            [self pop_addAnimation:showFrame forKey:@"showFrame"];
            

            
            POPSpringAnimation *fadeIn = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
            fadeIn.toValue = @(1.0);
            fadeIn.springBounciness = 2.0f;
            fadeIn.springSpeed = 1.0f;
            [self pop_addAnimation:fadeIn forKey:@"fadeIn"];

            self.backgroundColor = [UIColor clearColor];
            self.layer.cornerRadius = 2;
            self.layer.borderColor = [UIColor whiteColor].CGColor;
            self.layer.borderWidth = 0.4;

            [self setFrame:CGRectIntegral(self.frame)];

            showFrame.completionBlock = ^(POPAnimation *frame, BOOL finished) {
                
                [self displayWeather];

            };
        };
    };
}

- (void)displayWeather {
    
    if (self.cardCreated) {
        self.cardCreated(YES);
    }

}


@end
