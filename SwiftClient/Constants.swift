//
//  Constants.swift
//  SwiftClient
//
//  Created by Adam Nalisnick on 10/30/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import Foundation

internal func base64Encode(string:String) -> String {
    return dataToString(stringToData(string).base64EncodedDataWithOptions(nil))
}

internal func uriDecode(string:String) -> String{
    return string.stringByRemovingPercentEncoding!
}

internal func uriEncode(string:AnyObject) -> String{
    return string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
}

internal func stringToData(string:String) -> NSData {
    return string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
}

internal func dataToString(data:NSData) -> String {
    return NSString(data: data, encoding: 1)! as String
}

internal func queryPair(key:String, value:AnyObject) -> String{
    return uriEncode(key) + "=" + uriEncode(value)
}

internal func queryString(query:AnyObject) -> String?{
    var pairs:[String]?
    if let dict = query as? Dictionary<String, AnyObject> {
        pairs = Array()
        for (key, value) in dict {
            pairs!.append(queryPair(key, value))
        }
    }
    else if let array = query as? [String] {
        pairs = array
    }
    
    if let pairs = pairs {
        return "&".join(pairs)
    }
    
    return nil
}

// PARSERS
private func parseJson(data:NSData, string: String) -> AnyObject?{
    var error:NSError?
    return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: &error)
}

private func parseForm(data:NSData, string:String) -> AnyObject?{
    let pairs = string.componentsSeparatedByString("&")
    
    var form:[String : String] = Dictionary()
    
    for pair in pairs {
        let parts = pair.componentsSeparatedByString("=")
        form[uriDecode(parts[0])] = uriDecode(parts[1])
    }
    
    return form
}


//SERIALIZERS
private func serializeJson(data:AnyObject) -> NSData? {
    if(data as? Array<AnyObject> != nil || data as? Dictionary<String, AnyObject> != nil){
        var error:NSError?
        return NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions(), error: &error)
    }
    else if let dataString = data as? String{
        return stringToData(dataString)
    }
    return nil
}

private func serializeForm(data:AnyObject) -> NSData? {
    if let queryString = queryString(data) {
        return stringToData(queryString)
    }
    else if let dataString = (data as? String ?? toString(data)) as String? {
        return stringToData(dataString)
    }
    
    return nil
}

internal let types = [
    "html": "text/html",
    "json": "application/json",
    "xml": "application/xml",
    "urlencoded": "application/x-www-form-urlencoded",
    "form": "application/x-www-form-urlencoded",
    "form-data": "application/x-www-form-urlencoded"
]

internal let serializers = [
    "application/x-www-form-urlencoded": serializeForm,
    "application/json": serializeJson
]

internal let parsers = [
    "application/x-www-form-urlencoded": parseForm,
    "application/json": parseJson
]
