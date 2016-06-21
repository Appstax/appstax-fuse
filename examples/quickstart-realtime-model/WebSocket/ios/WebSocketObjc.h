
#import <Foundation/Foundation.h>

@interface WebSocketObjc: NSObject

- (instancetype)initWithUrl:(NSString *)url eventHandler:(void (^)(NSString *, NSString *))eventHandler;
- (void)sendString:(NSString *)data;

@end
