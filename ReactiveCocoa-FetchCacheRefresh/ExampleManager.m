//
//  ExampleManager.m
//  ReactiveCocoa-FetchCacheRefresh
//
//  Created by Maciej Konieczny on 2014-05-29.
//


#import <ReactiveCocoa/RACEXTScope.h>

#import "ExampleManager.h"


@interface ExampleManager ()

@property (strong, nonatomic) RACSignal *fetchNumber;
@property (strong, nonatomic) NSNumber *everBiggerNumber;
@property (strong, nonatomic) NSNumber *memoizedNumber;

@end



@implementation ExampleManager


#pragma mark - Public API


- (RACSignal *)fetchNumber
{
    if (!_fetchNumber) {
        _fetchNumber = RACObserve(self, memoizedNumber);
        [self refreshNumber];
    }

    return _fetchNumber;
}

- (void)refreshNumber
{
    NSLog(@"Performing refresh...");

    @weakify(self);
    [[self fetchNumberPrivate] subscribeNext:^(NSNumber *number) {
        @strongify(self);
        self.memoizedNumber = number;
    }];
}



#pragma mark - Private API


- (NSNumber *)everBiggerNumber
{
    if (!_everBiggerNumber) {
        _everBiggerNumber = @0;
    }

    _everBiggerNumber = @(_everBiggerNumber.integerValue + 1);

    return _everBiggerNumber;
}

- (RACSignal *)fetchNumberPrivate
{
    NSLog(@"Performing potentially time-consuming fetch...");
  
    @weakify(self)
    RACSignal *incrementingSignal = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
        @strongify(self)
      
        [subscriber sendNext:self.everBiggerNumber];
        [subscriber sendCompleted];
      
        return nil;
    }];
  
    return [[[[self rac_signalForSelector:@selector(refreshNumber)]
      startWith:nil]
      mapReplace:incrementingSignal]
      flatten];
}


@end
