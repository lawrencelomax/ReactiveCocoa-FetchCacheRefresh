//
//  ExampleManager.m
//  ReactiveCocoa-FetchCacheRefresh
//
//  Created by Maciej Konieczny on 2014-05-29.
//


#import <ReactiveCocoa/RACEXTScope.h>

#import "ExampleManager.h"


@interface ExampleManager ()

@property (strong, nonatomic) NSNumber *memoizedNumber;

@end



@implementation ExampleManager


#pragma mark - Public API

- (void)refreshNumber
{
  // The behaviour for refreshing is handled by rac_signalForSelector
  NSLog(@"Refreshing....");
}

- (RACSignal *)latestNumber
{
    if (!self.memoizedNumber) {
      RAC(self, memoizedNumber) = [self fetchNumberPrivate];
    }

    return RACObserve(self, memoizedNumber);
}

#pragma mark - Private API

- (RACSignal *)fetchNumberPrivate
{
    NSLog(@"Performing potentially time-consuming fetch...");
  
    return [[[self rac_signalForSelector:@selector(refreshNumber)]
      startWith:@0]
      scanWithStart:@0 reduce:^(NSNumber *running, id next) {
        return @(running.integerValue + 1);
      }];
}


@end
