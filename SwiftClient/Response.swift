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
        return params.reduce(Dictionary(), combine: {(map: [String : String], pair: String) -> [String : String] in
            var map = map
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
        case 3:
            self.basicStatus = BasicResponseType.Redirection
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
        case 203:
            self.status = ResponseType.NonAuthoritativeInfo
            break
        case 204:
            self.status = ResponseType.NoContent
            break
        case 205:
            self.status = ResponseType.ResetContent
            break
        case 206:
            self.status = ResponseType.PartialContent
            break
        case 207:
            self.status = ResponseType.MultiStatus
            break
        case 300:
            self.status = ResponseType.MultipleChoices
            break
        case 301:
            self.status = ResponseType.MovedPermanently
            break
        case 302:
            self.status = ResponseType.Found
            break
        case 303:
            self.status = ResponseType.SeeOther
            break
        case 304:
            self.status = ResponseType.NotModified
            break
        case 305:
            self.status = ResponseType.UseProxy
            break
        case 307:
            self.status = ResponseType.TemporaryRedirect
            break
        case 400:
            self.status = ResponseType.BadRequest
            break
        case 401:
            self.status = ResponseType.Unauthorized
            break
        case 402:
            self.status = ResponseType.PaymentRequired
            break
        case 403:
            self.status = ResponseType.Forbidden
            break
        case 404:
            self.status = ResponseType.NotFound
            break
        case 405:
            self.status = ResponseType.MethodNotAllowed
            break
        case 406:
            self.status = ResponseType.NotAcceptable
            break
        case 407:
            self.status = ResponseType.ProxyAuthentication
            break
        case 408:
            self.status = ResponseType.RequestTimeout
            break
        case 409:
            self.status = ResponseType.Conflict
            break
        case 410:
            self.status = ResponseType.Gone
            break
        case 411:
            self.status = ResponseType.LengthRequired
            break
        case 412:
            self.status = ResponseType.PreConditionFail
            break
        case 413:
            self.status = ResponseType.RequestEntityTooLarge
            break
        case 414:
            self.status = ResponseType.RequestURITooLong
            break
        case 415:
            self.status = ResponseType.UnsupportedMediaType
            break
        case 416:
            self.status = ResponseType.RequestedRangeNotSatisfiable
            break
        case 417:
            self.status = ResponseType.ExpectationFailed
            break
        case 419:
            self.status = ResponseType.AuthenticationTimeout
            break
        case 429:
            self.status = ResponseType.TooManyRequests
            break
        case 500:
            self.status = ResponseType.InternalServerError
            break
        case 501:
            self.status = ResponseType.NotImplemented
            break
        case 502:
            self.status = ResponseType.BadGateway
            break
        case 503:
            self.status = ResponseType.ServiceUnavailable
            break
        case 504:
            self.status = ResponseType.GatewayTimeout
            break
        case 505:
            self.status = ResponseType.HTTPVersionNotSupported
            break
        default:
            self.status = ResponseType.Unknown
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
        case OK                            // 200
        case Created                       // 201
        case Accepted                      // 202
        case NonAuthoritativeInfo          // 203
        case NoContent                     // 204
        case ResetContent                  // 205
        case PartialContent                // 206
        case MultiStatus                   // 207
        case MultipleChoices               // 300
        case MovedPermanently              // 301
        case Found                         // 302
        case SeeOther                      // 303
        case NotModified                   // 304
        case UseProxy                      // 305
        case TemporaryRedirect             // 307
        case BadRequest                    // 400
        case Unauthorized                  // 401
        case PaymentRequired               // 402
        case Forbidden                     // 403
        case NotFound                      // 404
        case MethodNotAllowed              // 405
        case NotAcceptable                 // 406
        case ProxyAuthentication           // 407
        case RequestTimeout                // 408
        case Conflict                      // 409
        case Gone                          // 410
        case LengthRequired                // 411
        case PreConditionFail              // 412
        case RequestEntityTooLarge         // 413
        case RequestURITooLong             // 414
        case UnsupportedMediaType          // 415
        case RequestedRangeNotSatisfiable  // 416
        case ExpectationFailed             // 417
        case AuthenticationTimeout         // 419
        case TooManyRequests               // 429
        case InternalServerError           // 500
        case NotImplemented                // 501
        case BadGateway                    // 502
        case ServiceUnavailable            // 503
        case GatewayTimeout                // 504
        case HTTPVersionNotSupported       // 505
        case Unknown                       // ???
    }
    
    // BasicResponseType enum. Status codes divided by 100.
    public enum BasicResponseType {
        case Info           // 1
        case OK             // 2
        case Redirection    // 3
        case ClientError    // 4
        case ServerError    // 5
        case Unknown        // ?
    }
}



