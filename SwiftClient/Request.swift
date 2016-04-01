//
//  SwiftClient.swift
//  SwiftClient
//
//  Created by Adam Nalisnick on 10/25/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import Foundation


private let errorHandler = {(error:NSError) -> Void in };

/// Class for handling request building and sending
public class Request {
    
    var data:AnyObject?;
    var headers: [String : String];
    public var url:String;
    let method: String;
    var delegate: NSURLSessionDelegate?;
    var timeout:Double;
    var transformer:(Response) -> Response = {$0};
    var query:[String] = Array();
    var errorHandler:((NSError) -> Void);
    var formData:FormData?;
    
    internal init(_ method: String, _ url: String, _ errorHandler:(NSError) -> Void){
        self.method = method;
        self.url = url;
        self.headers = Dictionary();
        self.timeout = 60;
        self.errorHandler = errorHandler;
    }
    
    /// Sets headers on the request from a dictionary
    public func set(headers: [String:String]) -> Request{
        for(key, value) in headers {
            self.set(key, value);
        }
        return self;
    }
    
    /// Sets headers on the request from a key and value
    public func set(key: String, _ value: String) -> Request{
        self.headers[key] = value;
        return self;
    }
    
    /// Executs a middleware function on the request
    public func use(middleware: (Request) -> Request) -> Request{
        return middleware(self);
    }
    
    /// Stores a response transformer to be used on the received HTTP response
    public func transform(transformer: (Response) -> Response) -> Request{
        let oldTransformer = self.transformer;
        self.transformer = {(response:Response) -> Response in
            return transformer(oldTransformer(response));
        }
        return self;
    }
    
    /// Sets the content-type.  Can be set using shorthand.
    /// ex: json, html, form, urlencoded, form, form-data, xml
    ///
    /// When not using shorthand, the value is used directory.
    public func type(type:String) -> Request {
        self.set("content-type", (types[type] ?? type));
        return self;
    }
    
    /// Gets the header value for the case insensitive key passed
    public func getHeader(header:String) -> String? {
        return self.headers[header.lowercaseString];
    }
    
    /// Gets the content-type of the request
    private func getContentType() -> String?{
        return getHeader("content-type");
    }
    
    /// Sets the type if not set
    private func defaultToType(type:String){
        if self.getContentType() == nil {
            self.type(type);
        }
    }
    
    /// Adds query params on the URL from a dictionary
    public func query(query:[String : String]) -> Request{
        for (key,value) in query {
            self.query.append(queryPair(key, value: value))
        }
        return self;
    }
    
    /// Adds query params on the URL from a key and value
    public func query(query:String) -> Request{
        self.query.append(uriEncode(query));
        return self;
    }
    
    /// Handles adding a single key and value to the request body
    private func _send(key: String, _ value: AnyObject) -> Request{
        if var dict = self.data as? [String : AnyObject] {
            dict[key] = value;
            self.data = dict;
        }
        else{
            self.data = [key : value];
        }
        return self;
    }

    /// Adds a string to the request body.  If the body already contains
    /// a string and the content type is form, & is also appended.  If the body
    /// is a string and the content-type is not a form, the string is merely appended.
    /// Otherwise, the body is set to the string.
    public func send(data:String) -> Request{
        defaultToType("form");
        if self.getContentType() == types["form"] {
            var oldData = "";
            if let stringData = self.data as? String {
                oldData = stringData + "&";
            }
            self.data = oldData + uriEncode(data);
        }
        else{
            let oldData = self.data as? String ?? "";
            self.data = oldData + data;
        }
        
        return self;
    }
    
    /// Sets the body of the request.  If the body is a Dictionary,
    /// and a dictionary is passed in, the two are merged.  Otherwise,
    /// the body is set directly to the passed data.
    public func send(data:AnyObject) -> Request{
        if let entries = data as? [String : AnyObject] {
            defaultToType("json");
            for (key, value) in entries {
                self._send(key, value);
            }
        }
        else{
            self.data = data;
        }
        return self;
    }
    
    /// Sets the request's timeout interval
    public func timeout(timeout:Double) -> Request {
        self.timeout = timeout;
        return self;
    }
    
    /// Sets the delegate on the request
    public func delegate(delegate:NSURLSessionDelegate) -> Request {
        self.delegate = delegate;
        return self;
    }
    
    /// Sets the error handler on the request
    public func onError(errorHandler:(NSError) -> Void) -> Request {
        self.errorHandler = errorHandler;
        return self;
    }
    
    /// Adds Basic HTTP Auth to the request
    public func auth(username:String, _ password:String) -> Request {
        let authString = base64Encode(username + ":" + password);
        self.set("authorization", "Basic \(authString)")
        return self;
    }
    
    private func getFormData() -> FormData {
        if(self.formData == nil) {
            self.formData = FormData();
        }
        
        return self.formData!;
    }
    
    /// Adds a field to a multipart request
    public func field(name:String, _ value:String) -> Request {
        self.getFormData().append(name, value);
        return self;
    }
    
    /// Attached a file to a multipart request.  If the mimeType isnt given, it will be inferred.
    public func attach(name:String, _ data:NSData, _ filename:String, withMimeType mimeType:String? = nil) -> Request {
        self.getFormData().append(name, data, filename, mimeType)
        return self
    }
    
    /// Attached a file to a multipart request.  If the mimeType isnt given, it will be inferred.  
    /// If the filename isnt given it will be pulled from the path
    public func attach(name:String, _ path:String, _ filename:String? = nil, withMimeType mimeType:String? = nil) -> Request {
        var basename:String! = filename;
        if(filename == nil){
            basename = NSURL(string: path)!.lastPathComponent;
        }
        let data = NSData(contentsOfFile: path)
        
        self.getFormData().append(name, data ?? NSData(), basename, mimeType)
        
        return self
    }
    
    /// Sends the request using the passed in completion handler and the optional error handler
    public func end(done: (Response) -> Void, onError errorHandler: ((NSError) -> Void)? = nil) {
        if(self.query.count > 0){
            if let queryString = queryString(self.query){
                self.url += self.url.rangeOfString("?") != nil ? "&" : "?";
                self.url += queryString;
            }
        }
        
        let queue = NSOperationQueue();
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self.delegate, delegateQueue: queue);
        
        let request = NSMutableURLRequest(URL: NSURL(string: self.url)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: NSTimeInterval(self.timeout));
        
        request.HTTPMethod = self.method;
        
        if(self.method != "GET" && self.method != "HEAD") {
            if(self.formData != nil) {
                request.HTTPBody = self.formData!.getBody();
                self.type(self.formData!.getContentType());
                self.set("Content-Length", String(request.HTTPBody?.length));
            }
            else if(self.data != nil){
                if let data = self.data! as? NSData {
                    request.HTTPBody = data;
                }
                else if let type = self.getContentType(){
                    if let serializer = serializers[type]{
                        request.HTTPBody = serializer(self.data!)
                    }
                    else {
                        request.HTTPBody = stringToData(String(self.data!))
                    }
                }
            }
        }
        
        for (key, value) in self.headers {
            request.setValue(value, forHTTPHeaderField: key);
        }
                
        let task = session.dataTaskWithRequest(request, completionHandler:
            {(data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if let response = response as? NSHTTPURLResponse {
                    done(self.transformer(Response(response, self, data)));
                }
                else if errorHandler != nil {
                    errorHandler!(error!);
                }
                else {
                    self.errorHandler(error!);
                }
            }
        );
        task.resume();
    }
}
