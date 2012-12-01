//
//  RdioTrayAppDelegate.m
//  RdioTray
//
//  Created by Marc Lacoursiere on 2012-11-30.
//  Copyright (c) 2012 Marc Lacoursiere. All rights reserved.
//

#import "RdioTrayAppDelegate.h"

#import "ASIHTTPRequest+OAuth.h"
#import "ASIFormDataRequest+OAuth.h"
#import "GTMNSString+HTML.h"

@implementation RdioTrayAppDelegate

- (void)dealloc
{
    [super dealloc];
}


#pragma mark WebView methods

// delegate method called whenever there's a request happening in the webview
- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource{

    NSLog(@"%@", @"Request");
    NSLog(@"%@", [request URL].absoluteString);
    
    return request;
}


#pragma mark instance methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // to allow delegates to fire from webview
    [_webView setResourceLoadDelegate:self];

    NSString *myConsumerKey = @"5gf488wx7mfx5xyqkbxawdvt";
    NSString *myConsumerSecret = @"M34BX7Njw4";
    
    NSURL *url = [NSURL URLWithString:@"http://api.rdio.com/oauth/request_token"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request signRequestWithClientIdentifier:myConsumerKey secret:myConsumerSecret
                             tokenIdentifier:nil secret:nil
                                 usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];

    [request setRequestMethod: @"POST"];
    [request setPostValue:@"http://localhost/4567" forKey:@"oauth_callback"];
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (error) {
        NSLog(@"%@", @"ERROR");
    } else {
        NSLog(@"%@", @"Ok");
        NSLog(@"%@", [request responseString]);
        
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [[request responseString] componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            
            [queryStringDictionary setObject:value forKey:key];
        }
        
        NSString *oauth_token = [queryStringDictionary objectForKey:@"oauth_token"];
        NSString *oauth_token_secret = [queryStringDictionary objectForKey:@"oauth_token_secret"];
        NSString *escaped_login_url = [queryStringDictionary objectForKey:@"login_url"];
        
        NSString *login_url = [[escaped_login_url
                                stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                               stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", login_url);
        NSLog(@"%@", oauth_token);
        NSLog(@"%@", oauth_token_secret);
        
        NSString *login_url_query_string= [login_url stringByAppendingString:@"?oauth_token="];
        NSString *login_url_with_token = [login_url_query_string stringByAppendingString:oauth_token];
        
        NSLog(@"%@", login_url_with_token);
        
        [[_webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:login_url_with_token]]];
    }
}

@end
