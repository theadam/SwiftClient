//
//  Response.swift
//  SwiftClient
//
//  Created by Adam Nalisnick on 10/30/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import Foundation


open class Response{
    
    // MARK: - Variables and constraints
    open var text: String?;
    open var data: Data?;
    open var body: Any?;
    
    open var type: String?;
    open var charset: String?;
    
    open let error: Bool;
    
    open var status: ResponseType
    open let statusCode: Int
    open let basicStatus: BasicResponseType
    
    open let request:Request;
    
    open var headers: [String : String];
    
    // MARK: - Methods and class initializers,
    // Trimming a string
    private func trim(_ s:String) -> String{
        return s.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
    }
    
    // Splitting content parameters
    private func splitContentParams(params: [String]) -> [String : String]{
        return params.reduce(Dictionary(), {(map: [String : String], pair: String) -> [String : String] in
            var map = map
            var pairArray = pair.components(separatedBy: "=");
            if(pairArray.count == 2){
                map.updateValue(self.trim(pairArray[1]), forKey: self.trim(pairArray[0]).lowercased())
            }
            return map;
        });
    }
    
    // Initializer of the Response class.
    init(response: HTTPURLResponse, request: Request, rawData: Data?){
        self.request = request;
        self.statusCode = response.statusCode
        let type = response.statusCode / 100 | 0;
        self.error = type == 4 || type == 5

        // basics
        switch(type) {
        case 1:
            self.basicStatus = BasicResponseType.info
            break
        case 2:
            self.basicStatus = BasicResponseType.ok
            break
        case 3:
            self.basicStatus = BasicResponseType.redirection
            break
        case 4:
            self.basicStatus = BasicResponseType.clientError
            break
        case 5:
            self.basicStatus = BasicResponseType.serverError
            break
        default:
            self.basicStatus = BasicResponseType.unknown
            print("Couldn't figure out the basic status code. (\(type))")
            break
        }
        
        // sugar
        switch(response.statusCode) {
        case 200:
            self.status = ResponseType.ok
            break
        case 201:
            self.status = ResponseType.created
            break
        case 202:
            self.status = ResponseType.accepted
            break
        case 203:
            self.status = ResponseType.nonAuthoritativeInfo
            break
        case 204:
            self.status = ResponseType.noContent
            break
        case 205:
            self.status = ResponseType.resetContent
            break
        case 206:
            self.status = ResponseType.partialContent
            break
        case 207:
            self.status = ResponseType.multiStatus
            break
        case 300:
            self.status = ResponseType.multipleChoices
            break
        case 301:
            self.status = ResponseType.movedPermanently
            break
        case 302:
            self.status = ResponseType.found
            break
        case 303:
            self.status = ResponseType.seeOther
            break
        case 304:
            self.status = ResponseType.notModified
            break
        case 305:
            self.status = ResponseType.useProxy
            break
        case 307:
            self.status = ResponseType.temporaryRedirect
            break
        case 400:
            self.status = ResponseType.badRequest
            break
        case 401:
            self.status = ResponseType.unauthorized
            break
        case 402:
            self.status = ResponseType.paymentRequired
            break
        case 403:
            self.status = ResponseType.forbidden
            break
        case 404:
            self.status = ResponseType.notFound
            break
        case 405:
            self.status = ResponseType.methodNotAllowed
            break
        case 406:
            self.status = ResponseType.notAcceptable
            break
        case 407:
            self.status = ResponseType.proxyAuthentication
            break
        case 408:
            self.status = ResponseType.requestTimeout
            break
        case 409:
            self.status = ResponseType.conflict
            break
        case 410:
            self.status = ResponseType.gone
            break
        case 411:
            self.status = ResponseType.lengthRequired
            break
        case 412:
            self.status = ResponseType.preConditionFail
            break
        case 413:
            self.status = ResponseType.requestEntityTooLarge
            break
        case 414:
            self.status = ResponseType.requestURITooLong
            break
        case 415:
            self.status = ResponseType.unsupportedMediaType
            break
        case 416:
            self.status = ResponseType.requestedRangeNotSatisfiable
            break
        case 417:
            self.status = ResponseType.expectationFailed
            break
        case 419:
            self.status = ResponseType.authenticationTimeout
            break
        case 429:
            self.status = ResponseType.tooManyRequests
            break
        case 500:
            self.status = ResponseType.internalServerError
            break
        case 501:
            self.status = ResponseType.notImplemented
            break
        case 502:
            self.status = ResponseType.badGateway
            break
        case 503:
            self.status = ResponseType.serviceUnavailable
            break
        case 504:
            self.status = ResponseType.gatewayTimeout
            break
        case 505:
            self.status = ResponseType.httpVersionNotSupported
            break
        default:
            self.status = ResponseType.unknown
            break
        }
        
        // header filling
        headers = Dictionary()
        for (key, value) in response.allHeaderFields {
            headers.updateValue(value as! String, forKey: key.description.lowercased())
        }
        
        // filling charset
        if let type = headers["content-type"] {
            var typeArray = type.components(separatedBy: ";")
            self.type = trim(typeArray.remove(at: 0))
            let params = splitContentParams(params: typeArray)
            self.charset = params["charset"]
        }
        
        // setting raw data into variables.
        self.data = rawData
        self.body = rawData as Any?
        if let data = rawData {
            self.text = dataToString(data: data)
            if let type = self.type {
                if let parser = parsers[type] {
                    self.body = parser(data, self.text!) as Any?
                }
            }
        }
    }
    
    // MARK: - Response enums.
    // ResponseType enum. Basically the status code of the response
    public enum ResponseType {
        case ok                            // 200
        case created                       // 201
        case accepted                      // 202
        case nonAuthoritativeInfo          // 203
        case noContent                     // 204
        case resetContent                  // 205
        case partialContent                // 206
        case multiStatus                   // 207
        case multipleChoices               // 300
        case movedPermanently              // 301
        case found                         // 302
        case seeOther                      // 303
        case notModified                   // 304
        case useProxy                      // 305
        case temporaryRedirect             // 307
        case badRequest                    // 400
        case unauthorized                  // 401
        case paymentRequired               // 402
        case forbidden                     // 403
        case notFound                      // 404
        case methodNotAllowed              // 405
        case notAcceptable                 // 406
        case proxyAuthentication           // 407
        case requestTimeout                // 408
        case conflict                      // 409
        case gone                          // 410
        case lengthRequired                // 411
        case preConditionFail              // 412
        case requestEntityTooLarge         // 413
        case requestURITooLong             // 414
        case unsupportedMediaType          // 415
        case requestedRangeNotSatisfiable  // 416
        case expectationFailed             // 417
        case authenticationTimeout         // 419
        case tooManyRequests               // 429
        case internalServerError           // 500
        case notImplemented                // 501
        case badGateway                    // 502
        case serviceUnavailable            // 503
        case gatewayTimeout                // 504
        case httpVersionNotSupported       // 505
        case unknown                       // ???
    }
    
    // BasicResponseType enum. Status codes divided by 100.
    public enum BasicResponseType {
        case info           // 1
        case ok             // 2
        case redirection    // 3
        case clientError    // 4
        case serverError    // 5
        case unknown        // ?
    }
}



