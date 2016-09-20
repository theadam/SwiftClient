//
//  Constants.swift
//  SwiftClient
//
//  Created by Adam Nalisnick on 10/30/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import Foundation

internal func base64Encode(string:String) -> String {
    return dataToString(data: stringToData(string: string).base64EncodedData(options: []))
}

internal func uriDecode(string:String) -> String{
    return string.removingPercentEncoding!
}

internal func uriEncode(string:Any) -> String{
    let allowedCharacters = CharacterSet(charactersIn:" \"#%/<>?@\\^`{}[]|&+").inverted

    return (string as AnyObject).addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
}

internal func stringToData(string:String) -> Data {
    return string.data(using: String.Encoding.utf8, allowLossyConversion: true)!
}

internal func dataToString(data:Data) -> String {
    return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
}

internal func queryPair(key:String, value:Any) -> String{
    return uriEncode(string: key) + "=" + uriEncode(string: value)
}

internal func queryString(query:Any) -> String?{
    var pairs:[String]?
    if let dict = query as? Dictionary<String, Any> {
        pairs = Array()
        for (key, value) in dict {
            pairs!.append(queryPair(key: key, value: value))
        }
    }
    else if let array = query as? [String] {
        pairs = array
    }
    
    if let pairs = pairs {
        return pairs.joined(separator: "&")
    }
    
    return nil
}

// PARSERS
private func parseJson(data:Data, string: String) -> Any?{
    do {
        return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
    } catch {
        print(error)
    }
    return nil;
}

private func parseForm(data:Data, string:String) -> Any?{
    let pairs = string.components(separatedBy: "&")
    
    var form:[String : String] = Dictionary()
    
    for pair in pairs {
        let parts = pair.components(separatedBy: "=")
        form[uriDecode(string: parts[0])] = uriDecode(string: parts[1])
    }
    
    return form
}


//SERIALIZERS
private func serializeJson(data:Any) -> Data? {
    if let arrayData = data as? NSArray {
        do {
            return try JSONSerialization.data(withJSONObject: arrayData, options: JSONSerialization.WritingOptions())
        } catch {
            print(error)
        }
    }
    
    if let dictionaryData = data as? NSDictionary {
        do {
            return try JSONSerialization.data(withJSONObject: dictionaryData, options: JSONSerialization.WritingOptions())
        } catch {
            print(error)
        }
    }

    if let dataString = data as? String{
        return stringToData(string: dataString)
    }

    return nil
}

private func serializeForm(data:Any) -> Data? {
    if let queryString = queryString(query: data) {
        return stringToData(string: queryString)
    }
    else if let dataString = (data as? String ?? String(describing: data)) as String? {
        return stringToData(string: dataString)
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
