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
                }] resume];
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
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/output.json"];
    [self doHttpGet:url];
}


- (IBAction)crashApp:(id)sender {
    
    *(long*)0 = 0xB16B00B5;
    
}

@end
