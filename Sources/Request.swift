//
//  SwiftClient.swift
//  SwiftClient
//
//  Created by Adam Nalisnick on 10/25/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import Foundation


private let errorHandler = {(error:Error) -> Void in };

/// Class for handling request building and sending
open class Request {
    
    var data:Any?;
    var headers: [String : String];
    open var url:String;
    let method: String;
    var delegate: URLSessionDelegate?;
    var timeout:Double;
    var transformer:(Response) -> Response = {$0};
    var query:[String] = Array();
    var errorHandler:((Error) -> Void);
    var formData:FormData?;
    
    internal init(method: String, url: String, errorHandler:@escaping (Error) -> Void){
        self.method = method;
        self.url = url;
        self.headers = Dictionary();
        self.timeout = 60;
        self.errorHandler = errorHandler;
    }
    
    /// Sets headers on the request from a dictionary
    open func set(headers: [String:String]) -> Request{
        for(key, value) in headers {
            _ = self.set(key: key, value: value);
        }
        return self;
    }
    
    /// Sets headers on the request from a key and value
    open func set(key: String, value: String) -> Request{
        self.headers[key] = value;
        return self;
    }
    
    /// Executs a middleware function on the request
    open func use(middleware: (Request) -> Request) -> Request{
        return middleware(self);
    }
    
    /// Stores a response transformer to be used on the received HTTP response
    open func transform(transformer: @escaping (Response) -> Response) -> Request{
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
    open func type(type:String) -> Request {
        _ = self.set(key: "content-type", value: (types[type] ?? type));
        return self;
    }
    
    /// Gets the header value for the case insensitive key passed
    open func getHeader(header:String) -> String? {
        return self.headers[header.lowercased()];
    }
    
    /// Gets the content-type of the request
    private func getContentType() -> String?{
        return getHeader(header: "content-type");
    }
    
    /// Sets the type if not set
    private func defaultToType(type:String){
        if self.getContentType() == nil {
            _ = self.type(type: type);
        }
    }
    
    /// Adds query params on the URL from a dictionary
    open func query(query:[String : String]) -> Request{
        for (key,value) in query {
            self.query.append(queryPair(key: key, value: value))
        }
        return self;
    }
    
    /// Adds query params on the URL from a key and value
    open func query(query:String) -> Request{
        self.query.append(uriEncode(string: query));
        return self;
    }
    
    /// Handles adding a single key and value to the request body
    private func _send(key: String, value: Any) -> Request{
        if var dict = self.data as? [String : Any] {
            dict[key] = value;
            self.data = dict;
        }
        else{
            let arrayData: [String: Any] = [key : value];
            self.data = arrayData;
        }
        return self;
    }

    /// Adds a string to the request body.  If the body already contains
    /// a string and the content type is form, & is also appended.  If the body
    /// is a string and the content-type is not a form, the string is merely appended.
    /// Otherwise, the body is set to the string.
    open func send(data:String) -> Request{
        defaultToType(type: "form");
        if self.getContentType() == types["form"] {
            var oldData = "";
            if let stringData = self.data as? String {
                oldData = stringData + "&";
            }
            let dataString: String = oldData + uriEncode(string: data);
            self.data = dataString;
        }
        else{
            let oldData = self.data as? String ?? "";
            let dataString: String = oldData + data;
            self.data = dataString;
        }
        
        return self;
    }
    
    /// Sets the body of the request.  If the body is a Dictionary,
    /// and a dictionary is passed in, the two are merged.  Otherwise,
    /// the body is set directly to the passed data.
    open func send(data:Any) -> Request{
        if let entries = data as? [String : Any] {
            defaultToType(type: "json");
            for (key, value) in entries {
                _ = self._send(key: key, value: value);
            }
        }
        else{
            self.data = data;
        }
        return self;
    }
    
    /// Sets the request's timeout interval
    open func timeout(timeout:Double) -> Request {
        self.timeout = timeout;
        return self;
    }
    
    /// Sets the delegate on the request
    open func delegate(delegate:URLSessionDelegate) -> Request {
        self.delegate = delegate;
        return self;
    }
    
    /// Sets the error handler on the request
    open func onError(errorHandler:@escaping (Error) -> Void) -> Request {
        self.errorHandler = errorHandler;
        return self;
    }
    
    /// Adds Basic HTTP Auth to the request
    open func auth(username:String, password:String) -> Request {
        let authString = base64Encode(string: username + ":" + password);
        _ = self.set(key: "authorization", value: "Basic \(authString)")
        return self;
    }
    
    private func getFormData() -> FormData {
        if(self.formData == nil) {
            self.formData = FormData();
        }
        
        return self.formData!;
    }
    
    /// Adds a field to a multipart request
    open func field(name:String, value:String) -> Request {
        self.getFormData().append(name: name, value: value);
        return self;
    }
    
    /// Attached a file to a multipart request.  If the mimeType isnt given, it will be inferred.
    open func attach(name:String, data:Data, filename:String, withMimeType mimeType:String? = nil) -> Request {
        self.getFormData().append(name: name, data: data, filename: filename, mimeType: mimeType)
        return self
    }
    
    /// Attached a file to a multipart request.  If the mimeType isnt given, it will be inferred.  
    /// If the filename isnt given it will be pulled from the path
    open func attach(name:String, path:String, filename:String? = nil, withMimeType mimeType:String? = nil) -> Request {
        var basename:String! = filename;
        if(filename == nil){
            basename = URL(string: path)!.lastPathComponent;
        }
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        
        self.getFormData().append(name: name, data: data ?? Data(), filename: basename, mimeType: mimeType)
        
        return self
    }
    
    /// Sends the request using the passed in completion handler and the optional error handler
    open func end(done: @escaping (Response) -> Void, onError errorHandler: ((Error) -> Void)? = nil) {
        if(self.query.count > 0){
            if let queryString = queryString(query: self.query){
                self.url += self.url.range(of: "?") != nil ? "&" : "?";
                self.url += queryString;
            }
        }
        
        let queue = OperationQueue();
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self.delegate, delegateQueue: queue);
        
        var request = URLRequest(url: URL(string: self.url)!, cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: TimeInterval(self.timeout));
        
        request.httpMethod = self.method;
        
        if(self.method != "GET" && self.method != "HEAD") {
            if(self.formData != nil) {
                request.httpBody = self.formData!.getBody() as Data?;
                _ = self.type(type: self.formData!.getContentType());
                _ = self.set(key: "Content-Length", value: String(describing: request.httpBody?.count));
            }
            else if(self.data != nil){
                if let data = self.data as? Data {
                    request.httpBody = data;
                }
                else if let type = self.getContentType(){
                    if let serializer = serializers[type]{
                        request.httpBody = serializer(self.data!) as Data?
                    }
                    else {
                        request.httpBody = stringToData(string: String(describing: self.data!))
                    }
                }
            }
        }

        for (key, value) in self.headers {
            request.setValue(value, forHTTPHeaderField: key);
        }
                
        let task = session.dataTask(with: request, completionHandler:
            {(data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let response = response as? HTTPURLResponse {
                    done(self.transformer(Response(response: response, request: self, rawData: data)));
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
