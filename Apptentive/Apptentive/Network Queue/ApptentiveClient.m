//
//  ApptentiveClient.m
//  Apptentive
//
//  Created by Frank Schmitt on 4/24/17.
//  Copyright © 2017 Apptentive, Inc. All rights reserved.
//

#import "ApptentiveClient.h"
#import "ApptentiveMessageGetRequest.h"
#import "ApptentiveConfigurationRequest.h"
#import "ApptentiveConversationRequest.h"

#import "ApptentiveSerialRequest.h"

#define APPTENTIVE_MIN_BACKOFF_DELAY 1.0
#define APPTENTIVE_BACKOFF_MULTIPLIER 2.0


@implementation ApptentiveClient

@synthesize URLSession = _URLSession;
@synthesize backoffDelay = _backoffDelay;

- (instancetype)initWithBaseURL:(NSURL *)baseURL apptentiveKey:(nonnull NSString *)apptentiveKey apptentiveSignature:(nonnull NSString *)apptentiveSignature {
	self = [super init];

	if (self) {
		_baseURL = baseURL;
		_apptentiveKey = apptentiveKey;
		_apptentiveSignature = apptentiveSignature;
		_operationQueue = [[NSOperationQueue alloc] init];

		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		configuration.HTTPAdditionalHeaders = @{
			@"Accept": @"application/json",
			@"Accept-Encoding": @"gzip",
			@"Accept-Charset": @"utf-8",
			@"User-Agent": [NSString stringWithFormat:@"ApptentiveConnect/%@ (iOS)", kApptentiveVersionString],
		};

		_URLSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];

		[self resetBackoffDelay];
	}

	return self;
}

#pragma mark - Request operation data source

- (void)increaseBackoffDelay {
	@synchronized(self) {
		_backoffDelay *= APPTENTIVE_BACKOFF_MULTIPLIER;
	}
}

- (void)resetBackoffDelay {
	@synchronized(self) {
		_backoffDelay = APPTENTIVE_MIN_BACKOFF_DELAY;
	}
}

#pragma mark - Creating request operations

- (ApptentiveRequestOperation *)requestOperationWithRequest:(id<ApptentiveRequest>)request delegate:(id<ApptentiveRequestOperationDelegate>)delegate {
	return [self requestOperationWithRequest:request authToken:self.authToken delegate:delegate];
}

- (ApptentiveRequestOperation *)requestOperationWithRequest:(id<ApptentiveRequest>)request authToken:(NSString *)authToken delegate:(id<ApptentiveRequestOperationDelegate>)delegate {
	NSURL *URL = [NSURL URLWithString:request.path relativeToURL:self.baseURL];

	NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:URL];
	URLRequest.HTTPBody = request.payload;
	URLRequest.HTTPMethod = request.method;
	[URLRequest addValue:request.contentType forHTTPHeaderField:@"Content-Type"];
	[URLRequest addValue:request.apiVersion forHTTPHeaderField:@"X-API-Version"];
	[URLRequest addValue:_apptentiveKey forHTTPHeaderField:@"APPTENTIVE-KEY"];
	[URLRequest addValue:_apptentiveSignature forHTTPHeaderField:@"APPTENTIVE-SIGNATURE"];
	if (authToken) {
		[URLRequest addValue:[@"Bearer " stringByAppendingString:authToken] forHTTPHeaderField:@"Authorization"];
	}
	if (request.encrypted) {
		[URLRequest addValue:@"true" forHTTPHeaderField:@"APPTENTIVE-ENCRYPTED"];
	}

	ApptentiveRequestOperation *operation = [[ApptentiveRequestOperation alloc] initWithURLRequest:URLRequest delegate:delegate dataSource:self];
	operation.request = request;
	return operation;
}

@end
