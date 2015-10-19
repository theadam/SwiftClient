//
//  Response.swift
//  SwiftClient
//
//  Created by Adam Nalisnick on 10/30/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import Foundation


public class Response{
    
    // MARK: - Variables and constraints
    public var text: String?;
    public var data: NSData?;
    public var body: AnyObject?;
    
    public var type: String?;
    public var charset: String?;
    
    public let error: Bool;
    
    public var status: ResponseType
    public let statusCode: Int
    public let basicStatus: BasicResponseType
    
    public let request:Request;
    
    public var headers: [String : String];
    
    // MARK: - Methods and class initializers,
    // Trimming a string
    private func trim(s:String) -> String{
        return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
    }
    
    // Splitting content parameters
    private func splitContentParams(params: [String]) -> [String : String]{
        return params.reduce(Dictionary(), combine: {(var map: [String : String], pair: String) -> [String : String] in
            var pairArray = pair.componentsSeparatedByString("=");
            if(pairArray.count == 2){
                map.updateValue(self.trim(pairArray[1]), forKey: self.trim(pairArray[0]).lowercaseString)
            }
            return map;
        });
    }
    
    // Initializer of the Response class.
    init(_ response: NSHTTPURLResponse, _ request: Request, _ rawData: NSData?){
        self.request = request;
        self.statusCode = response.statusCode
        let type = response.statusCode / 100 | 0;
        self.error = type == 4 || type == 5

        // basics
        switch(type) {
        case 1:
            self.basicStatus = BasicResponseType.Info
            break
        case 2:
            self.basicStatus = BasicResponseType.OK
            break
        case 4:
            self.basicStatus = BasicResponseType.ClientError
            break
        case 5:
            self.basicStatus = BasicResponseType.ServerError
            break
        default:
            self.basicStatus = BasicResponseType.Unknown
            print("Couldn't figure out the basic status code. (\(type))")
            break
        }
        
        // sugar
        switch(response.statusCode) {
        case 200:
            self.status = ResponseType.OK
            break
        case 201:
            self.status = ResponseType.Created
            break
        case 202:
            self.status = ResponseType.Accepted
            break
        case 204:
            self.status = ResponseType.NoContent
            break
        case 400:
            self.status = ResponseType.BadRequest
            break
        case 401:
            self.status = ResponseType.Unauthorized
            break
        case 403:
            self.status = ResponseType.Forbidden
            break
        case 404:
            self.status = ResponseType.NotFound
            break
        case 406:
            self.status = ResponseType.NotAcceptable
            break
        case 412:
            self.status = ResponseType.PreConditionFail
            break
        case 419:
            self.status = ResponseType.AuthenticationTimeout
            break
        case 429:
            self.status = ResponseType.TooManyRequests
            break
        default:
            self.status = ResponseType.Unknown
            print("Couldn't set responseType (\(response.statusCode))")
            break
        }
        
        // header filling
        headers = Dictionary()
        for (key, value) in response.allHeaderFields {
            headers.updateValue(value.description, forKey: key.description.lowercaseString)
        }
        
        // filling charset
        if let type = headers["content-type"] {
            var typeArray = type.componentsSeparatedByString(";")
            self.type = trim(typeArray.removeAtIndex(0))
            let params = splitContentParams(typeArray)
            self.charset = params["charset"]
        }
        
        // setting raw data into variables.
        self.data = rawData
        self.body = rawData
        if let data = rawData {
            self.text = dataToString(data)
            if let type = self.type {
                if let parser = parsers[type] {
                    self.body = parser(data, string:self.text!)
                }
            }
        }
    }
    
    // MARK: - Response enums.
    // ResponseType enum. Basically the status code of the response
    public enum ResponseType {
        case OK                    // 200
        case Created               // 201
        case Accepted              // 202
        case NoContent             // 204
        case BadRequest            // 400
        case Unauthorized          // 401
        case Forbidden             // 403
        case NotFound              // 404
        case NotAcceptable         // 406
        case PreConditionFail      // 412
        case AuthenticationTimeout // 419
        case TooManyRequests       // 429
        case Unknown               // ???
    }
    
    // BasicResponseType enum. Status codes divided by 100.
    public enum BasicResponseType {
        case Info           // 1
        case OK             // 2
        case ClientError    // 4
        case ServerError    // 5
        case Unknown        // ?
    }
}



