//
//  ViewController.m
//  objc-NSURLSession
//
//  Created by Mark Prichard on 11/16/15.
//  Copyright © 2015 AppDynamics. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSString *sessionId = nil;
NSString *routeId = nil;

int noOfItems = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getHttpCookies:(NSURLResponse*)response
                forURL:(NSURL*)url {
    NSDictionary *headers = [(NSHTTPURLResponse*)response allHeaderFields];
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:headers forURL:url];
    for (int i = 0; i < [cookies count]; i++) {
        NSHTTPCookie *cookie = ((NSHTTPCookie *) [cookies objectAtIndex:i]);
        
        if ([[cookie name] isEqualToString:@"JSESSIONID"]) {
            sessionId = [[cookie properties] objectForKey:NSHTTPCookieValue];
        }
        if ([[cookie name] isEqualToString:@"ROUTEID"]) {
            routeId = [[cookie properties] objectForKey:NSHTTPCookieValue];
        }
    }
}

- (void)getHttpRequestHeaders:(NSURLRequest*)request {
    NSDictionary *headers = [(NSMutableURLRequest*)request allHTTPHeaderFields];
    NSLog(@"Request Headers: %@", [headers description]);
}

- (void)getHttpResponseHeaders:(NSURLResponse*)response {
    NSDictionary *headers = [(NSHTTPURLResponse*)response allHeaderFields];
    NSLog(@"Response Headers: %@", [headers description]);
}

- (void)doHttpGet:(NSURL*)url {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:60.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:sessionId forHTTPHeaderField:@"JSESSIONID"];
    [request setValue:routeId forHTTPHeaderField:@"ROUTEID"];
    [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"username" ]forHTTPHeaderField:@"USERNAME"];
    [self getHttpRequestHeaders:request];
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"Request URL: %@", url);
                    NSLog(@"HTTP Status Code: %ld", [(NSHTTPURLResponse*)response statusCode]);
                    NSLog(@"%@",strData);
                    [self getHttpResponseHeaders:response];
                    [self getWeatherData:response fromData:data];
                }] resume];
}


- (void)getWeatherData:(NSURLResponse*)response
              fromData:(NSData*) data {
    NSDictionary *dict=[[NSDictionary alloc]init];
    dict=[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    
    NSArray *weather = [dict objectForKey:@"weather"];
    NSDictionary *loc = [weather objectAtIndex:0];
    NSString *main = [loc objectForKey:@"main"];
    NSLog(@"current weather in london: %@", main);
    
    if ([@"rain" isEqualToString:[main lowercaseString] ]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_doesItRain setText:@"YES :("];
        }];
        
    } else {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_doesItRain setText:@"NO :)"];
        }];

    }

}

- (void)doHttpPost:(NSURL*)url {
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:60.0];
    
    NSString *postString = @"username=";
    postString = [postString stringByAppendingString: [[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    postString = [postString stringByAppendingString:@"&password="];
    postString = [postString stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
    NSData *postBody = [postString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"POST body: %@", [[NSString alloc] initWithData:postBody encoding:NSUTF8StringEncoding]);
    
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postBody];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error) {
        NSLog(@"Request URL: %@", url);
        NSLog(@"HTTP Status Code %ld", [(NSHTTPURLResponse*)response statusCode]);
        
        [self getHttpCookies:response forURL:url];
        [self getHttpResponseHeaders:response];
    }] resume];
}


- (IBAction)getItemsClicked:(id)sender {
    NSString *httpEndpoint = @"http://api.openweathermap.org/data/2.5/weather?q=";
    NSString *location = @"London";
    NSString *apiKey =@"&appid=716f8bdc119843c7e88b7ada22d5d7c3";

    NSURL *url = [NSURL URLWithString: [ @[httpEndpoint, location, apiKey] componentsJoinedByString:@""] ];
    [self doHttpGet:url];
}


- (IBAction)crashApp:(id)sender {
    
    *(long*)0 = 0xB16B00B5;
    
}

@end
