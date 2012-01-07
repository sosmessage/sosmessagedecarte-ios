//
//  SMMessagesHandler.m
//  sosmessage
//
//  Created by Arnaud K. on 14/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SMMessagesHandler.h"

@interface SMMessagesHandler () <NSURLConnectionDelegate> {
    @private
    id delegate;
}

+ (void)showUIAlert;

@property (readonly) NSString* UUID;

- (void)resetData;
- (void)startWorking;
- (void)stopWorking;
- (void)startRequest:(NSURLRequest*)request;

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end

@implementation SMMessagesHandler
@synthesize delegate, lastStatusCode;

NSMutableData* data;
NSURLConnection* currentConnection;

bool receiving = false;

#pragma mark Constructor
- (id)init {
    self = [super init];
    return self;
}

- (id)initWithDelegate:(id<SMMessageDelegate,NSObject>)pDelegate {
    self = [self init];
    if (self) {
        self.delegate = pDelegate;
    }
    return self;
}

#pragma mark Custom Methods
-(NSString *)UUID {
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    if (![settings objectForKey:kSOSUUID]) {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        NSString* theUUIDstr = (__bridge_transfer NSString*) CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        [settings setValue:theUUIDstr forKey:kSOSUUID];
        NSLog(@"Generate a new UUID: %@", theUUIDstr);
    }
    return [settings stringForKey:kSOSUUID];
}

-(void)startWorking {
    [self resetData];
    receiving = true;
    [self.delegate startActivityFromMessageHandler:self];
}

-(void)stopWorking {
    if (receiving) {
        receiving = false;
        [self.delegate stopActivityFromMessageHandler:self];
    }
}

-(void)resetData {
    if (data) {
        data = nil;
    }
}

#pragma mark Requesting ....

-(void)startRequest:(NSURLRequest *)request {
    if (receiving && currentConnection) {
        [currentConnection cancel];
        currentConnection = nil;
    }
    
    [self startWorking];
    currentConnection = [NSURLConnection connectionWithRequest:request delegate:self];    
}

- (void)requestUrl:(NSString*)url {
    
    NSURL* nsUrl = [[NSURL alloc] initWithString:url];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:nsUrl];
    
    [self startRequest:request];
    
    [request release];
    [nsUrl release];
}

- (void)requestPOSTUrl:(NSString*)url params:(NSDictionary*)params {
    NSURL* nsUrl = [[NSURL alloc] initWithString:url];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:nsUrl];
    request.HTTPMethod = @"POST";
    
    // Build HTTP Body
    NSMutableString* body = [NSMutableString string];
    for (NSString* key in params) {
        [body appendFormat:@"%@=%@&", key, [params objectForKey:key]];
    }
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [self startRequest:request];
    
    [request release];
    [nsUrl release];    
}

- (void)requestCategories {
    [self requestUrl:[NSString stringWithFormat:@"%@/api/v1/categories", SM_URL]];
}

- (void)requestRandomMessageForCategory:(NSString*)aCategoryId {
    [self requestUrl:[NSString stringWithFormat:@"%@/api/v1/categories/%@/message", SM_URL, aCategoryId]];
}

-(void)requestProposeMessage:(NSString*)aMessage author:(NSString*)anAuthor category:(NSString*)aCategoryId {
    [self requestPOSTUrl:[NSString stringWithFormat:@"%@/api/v1/categories/%@/message", SM_URL, aCategoryId] params:[NSDictionary dictionaryWithObjectsAndKeys:aMessage, @"text", anAuthor, @"contributorName", nil]];
}

- (void)requestVote:(NSInteger)vote messageId:(NSString*)messageId {
    NSLog(@"MessageID: %@", messageId);
    NSString* url = [NSString stringWithFormat:@"%@/api/v1/messages/%@/vote", SM_URL, messageId];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:vote], @"vote", self.UUID, @"uid", nil];
    [self requestPOSTUrl:url params:params];
}

+(void)showUIAlert {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Erreur de connexion" message:@"Un probleme est survenu lors de la connexion au serveur de sosmessage" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];    
}

#pragma mark -
#pragma mark NSURLConnection methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self resetData];
    NSLog(@"%@", error);
    
    [self stopWorking];
    if ([self.delegate respondsToSelector:@selector(messageHandler:didFail:)]) {
        [self.delegate messageHandler:self didFail:error];
    } else {
        [SMMessagesHandler showUIAlert];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)dataChunk {
    if (!data) {
        data = [[NSMutableData alloc] initWithData:dataChunk];
    } else {
        [data appendData:dataChunk];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.lastStatusCode = [(NSHTTPURLResponse*)response statusCode];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self stopWorking];
    
    if (data) {
        NSError* error;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!json) {
            NSLog(@"Error while parsing json object from %@: %@", connection.originalRequest.URL, error);
            NSLog(@"Data: %@", [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease]);
        }
        else if ([self.delegate respondsToSelector:@selector(messageHandler:didFinishWithJSon:)]) {
            [self.delegate messageHandler:self didFinishWithJSon:json];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(messageHandler:didFinish:)]) {
        [self.delegate messageHandler:self didFinish:data];
    }
    
    [self resetData];
}

-(void)dealloc {
    [self stopWorking];
    [data release];
    currentConnection = nil;
    [super dealloc];
}
@end
