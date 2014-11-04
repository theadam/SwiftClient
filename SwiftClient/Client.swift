//
//  Client.swift
//  SwiftClient
//
//  Created by Adam Nalisnick on 10/30/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import Foundation

/// Class for handling creating requests
public class Client {
    
    var middleware:(Request) -> Request = {$0};
    var responseTransformer:(Response) -> Response = {$0};
    var errorHandler:(NSError) -> Void = {e in }; // do nothing by default
    
    public init(){}
    
    private func createRequest(method:String, _ url:String) -> Request {
        return self.middleware(Request(method, url, self.errorHandler))
            .transform(responseTransformer);
    }
    
    /// Creates a GET request with the given URL
    public func get(url:String) -> Request {
        return createRequest("GET", url);
    }
    
    /// Creates a HEAD request with the given URL
    public func head(url:String) -> Request {
        return createRequest("HEAD", url);
    }
    
    /// Creates a GET request with the given URL
    public func patch(url:String) -> Request {
        return createRequest("PATCH", url);
    }
    
    /// Creates a POST request with the given URL
    public func post(url:String) -> Request {
        return createRequest("POST", url);
    }
    
    /// Creates a PUT request with the given URL
    public func put(url:String) -> Request {
        return createRequest("PUT", url);
    }
    
    /// Creates a DELETE request with the given URL
    public func delete(url:String) -> Request {
        return createRequest("DELETE", url);
    }
    
    /// Sets the base URL for every request created with this Client as long as the
    /// Request's URL starts with a "/"
    public func baseUrl(url:String) -> Client{
        
        self.use({(request:Request) -> Request in
            if(request.url[request.url.startIndex] == "/"){
                request.url = url + request.url;
            }
            return request;
        });
        return self;
    }
    
    /// Applies the given middleware to every Request created by this Client.
    public func use(middleware: (Request) -> Request) -> Client {
        let oldMiddleware = self.middleware;
        self.middleware = {(request:Request) -> Request in
            return middleware(oldMiddleware(request));
        };
        return self;
    }
    
    
    /// Applies the given Response transformer to every Request created by this Client;
    public func transform(transformer: (Response) -> Response) -> Client {
        let oldTransformer = self.responseTransformer;
        self.responseTransformer = {(response:Response) -> Response in
            return transformer(oldTransformer(response));
        };
        return self;
    }
    
    /// Sets the global error handler for every Request made by this Client.
    public func onError(errorHandler: (NSError) -> Void) -> Client {
        self.errorHandler = errorHandler;
        return self;
    }
    
}
