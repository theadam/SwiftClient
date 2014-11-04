//
//  Response.swift
//  SwiftClient
//
//  Created by Adam Nalisnick on 10/30/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import Foundation


public class Response{
    
    public let text: String?;
    public let data: NSData?;
    public var body: AnyObject?;
    
    public let type: String?;
    public let charset: String?;
    
    public let status: Int;
    public let statusType: Int;
    
    public let info: Bool;
    public let ok: Bool;
    public let clientError: Bool;
    public let serverError: Bool;
    public let error: Bool;
    
    public let accepted: Bool;
    public let noContent: Bool;
    public let badRequest: Bool;
    public let unauthorized: Bool;
    public let notAcceptable: Bool;
    public let notFound: Bool;
    public let forbidden: Bool;
    
    public let headers: [String : String];
    
    private func trim(s:String) -> String{
        return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
    }
    
    private func splitContentParams(params: [String]) -> [String : String]{
        return params.reduce(Dictionary(), combine: {(var map: [String : String], pair: String) -> [String : String] in
            var pairArray = pair.componentsSeparatedByString("=");
            if(pairArray.count == 2){
                map.updateValue(self.trim(pairArray[1]), forKey: self.trim(pairArray[0]).lowercaseString)
            }
            return map;
        });
    }
    
    init(_ response: NSHTTPURLResponse, _ rawData: NSData?){
        
        let status = response.statusCode;
        let type = response.statusCode / 100 | 0;
        
        // status / class
        self.status = status;
        self.statusType = type;
        
        // basics
        self.info = 1 == type;
        self.ok = 2 == type;
        self.clientError = 4 == type;
        self.serverError = 5 == type;
        self.error = 4 == type || 5 == type;
        
        // sugar
        self.accepted = 202 == status;
        self.noContent = 204 == status || 1223 == status;
        self.badRequest = 400 == status;
        self.unauthorized = 401 == status;
        self.notAcceptable = 406 == status;
        self.notFound = 404 == status;
        self.forbidden = 403 == status;
        
        // header filling
        headers = Dictionary();
        for (key, value) in response.allHeaderFields {
            headers.updateValue(value.description, forKey: key.description.lowercaseString);
        }
        
        if let type = headers["content-type"] {
            var typeArray = type.componentsSeparatedByString(";");
            self.type = trim(typeArray.removeAtIndex(0));
            let params = splitContentParams(typeArray);
            self.charset = params["charset"];
        }
        
        self.data = rawData;
        self.body = rawData;
        if let data = rawData {
            self.text = NSString(data: data, encoding: 1)!;
            if let type = self.type {
                if let parser = parsers[type] {
                    self.body = parser(data, self.text!);
                }
            }
        }
    }
}


