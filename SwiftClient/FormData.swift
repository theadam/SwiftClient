//
//  FormData.swift
//  SwiftClient
//
//  Created by Adam Nalisnick on 11/4/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import Foundation
import MobileCoreServices

internal class FormData {
    
    private let boundary = "BOUNDARY-" + NSUUID().UUIDString;
    
    private let nl = stringToData("\r\n");
    
    internal init(){}
    
    private var fields:[(name:String, value:String)] = Array();
    
    private var files:[(name:String, data:NSData, filename:String, mimeType:String)] = Array();
    
    internal func append(name:String, _ value:String){
        fields += [(name: name, value: value)]
    }
    
    internal func append(name:String, _ data:NSData, _ filename:String, _ mimeType:String? = nil){
        let type = mimeType ?? determineMimeType(filename)
        files += [(name: name, data: data, filename: filename, mimeType: type)]
    }
    
    private func determineMimeType(filename:String) -> String {
        let type = NSURL(string: filename)!.pathExtension!
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, type as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream";
    }
    
    internal func getContentType() -> String {
        return "multipart/form-data; boundary=\(boundary)";
    }
    
    internal func getBody() -> NSData? {
        if(fields.count > 0 || files.count > 0){
            
            let body = NSMutableData();
            
            for (field) in fields {
                appendField(body, field.name, field.value)
            }
            
            for (file) in files {
                appendFile(body, file.name, file.data, file.filename, file.mimeType);
            }
            
            body.appendData(stringToData("--\(boundary)--"));
            body.appendData(nl);
            return body;
        }
        return nil
    }
    
    private func appendFile(body:NSMutableData, _ name:String, _ data:NSData, _ filename:String, _ mimeType:String) {
        body.appendData(stringToData("--\(boundary)"))
        body.appendData(nl)
        body.appendData(stringToData("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\""))
        body.appendData(nl);
        body.appendData(stringToData("Content-Type: \(mimeType)"));
        body.appendData(nl);
        body.appendData(nl);
        body.appendData(data);
        body.appendData(nl);
    }
    
    private func appendField(body:NSMutableData, _ name:String, _ value:String) {
        body.appendData(stringToData("--\(boundary)"))
        body.appendData(nl)
        body.appendData(stringToData("Content-Disposition: form-data; name=\"\(name)\""))
        body.appendData(nl);
        body.appendData(nl);
        body.appendData(stringToData(value))
        body.appendData(nl);
    }
}
