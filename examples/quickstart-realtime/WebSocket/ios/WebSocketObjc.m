
#import "WebSocketObjc.h"
@import Jetfire;

@interface WebSocketObjc () <JFRWebSocketDelegate>
@property NSURL *url;
@property (nonatomic, copy) void (^eventHandler)(NSString *, NSString *);
@property JFRWebSocket *webSocket;
@end

@implementation WebSocketObjc

- (instancetype)initWithUrl:(NSString *)url eventHandler:(void (^)(NSString *, NSString *))eventHandler {
	NSLog(@"WebSocketObjc initWithUrl");
	self = [super init];
	if(self != nil) {
		self.url = [NSURL URLWithString:url];
		self.eventHandler = eventHandler;
		self.webSocket = [[JFRWebSocket alloc] initWithURL:self.url protocols:nil];
		self.webSocket.delegate = self;
		[self.webSocket connect];
	}
	return self;
}

- (void)sendString:(NSString *)data {
	[self.webSocket writeString:data];
}

#pragma mark - JFRWebSocketDelegate

-(void)websocketDidConnect:(JFRWebSocket*)socket {
    self.eventHandler(@"open", nil);
}

-(void)websocketDidDisconnect:(JFRWebSocket*)socket error:(NSError*)error {
    self.eventHandler(@"error", [error localizedDescription]);
    self.eventHandler(@"close", [error localizedDescription]);
}

-(void)websocket:(JFRWebSocket*)socket didReceiveMessage:(NSString*)string {
    self.eventHandler(@"message", string);
}

-(void)websocket:(JFRWebSocket*)socket didReceiveData:(NSData*)data {
    
}

@end
