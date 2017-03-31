//
//  Client.swift
//  SwiftClient
//
//  Created by Adam Nalisnick on 10/30/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import Foundation

/// Class for handling creating requests
open class Client {
    
    var middleware:(Request) -> Request = {$0};
    var responseTransformer:(Response) -> Response = {$0};
    var errorHandler:(Error) -> Void = {e in }; // do nothing by default
    
    public init(){}
    
    private func createRequest(method:String, url:String) -> Request {
        return self.middleware(Request(method: method, url: url, errorHandler: self.errorHandler))
            .transform(transformer: responseTransformer);
    }
    
    /// Creates a GET request with the given URL
    open func get(url:String) -> Request {
        return createRequest(method: "GET", url: url);
    }
    
    /// Creates a HEAD request with the given URL
    open func head(url:String) -> Request {
        return createRequest(method: "HEAD", url: url);
    }
    
    /// Creates a GET request with the given URL
    open func patch(url:String) -> Request {
        return createRequest(method: "PATCH", url: url);
    }
    
    /// Creates a POST request with the given URL
    open func post(url:String) -> Request {
        return createRequest(method: "POST", url: url);
    }
    
    /// Creates a PUT request with the given URL
    open func put(url:String) -> Request {
        return createRequest(method: "PUT", url: url);
    }
    
    /// Creates a DELETE request with the given URL
    open func delete(url:String) -> Request {
        return createRequest(method: "DELETE", url: url);
    }
    
    /// Sets the base URL for every request created with this Client as long as the
    /// Request's URL starts with a "/"
    open func baseUrl(url:String) -> Client{
        
        _ = self.use(middleware: {(request:Request) -> Request in
            if(request.url[request.url.startIndex] == "/"){
                request.url = url + request.url;
            }
            return request;
        });
        return self;
    }
    
    /// Applies the given middleware to every Request created by this Client.
    open func use(middleware: @escaping (Request) -> Request) -> Client {
        let oldMiddleware = self.middleware;
        self.middleware = {(request:Request) -> Request in
            return middleware(oldMiddleware(request));
        };
        return self;
    }
    
    
    /// Applies the given Response transformer to every Request created by this Client;
    open func transform(transformer: @escaping (Response) -> Response) -> Client {
        let oldTransformer = self.responseTransformer;
        self.responseTransformer = {(response:Response) -> Response in
            return transformer(oldTransformer(response));
        };
        return self;
    }
    
    /// Sets the global error handler for every Request made by this Client.
    open func onError(errorHandler: @escaping (Error) -> Void) -> Client {
        self.errorHandler = errorHandler;
        return self;
    }
    
}
