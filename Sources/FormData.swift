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
    
    private let boundary = "BOUNDARY-" + UUID().uuidString;
    
    private let nl = stringToData(string: "\r\n");
    
    internal init(){}
    
    private var fields:[(name:String, value:String)] = Array();
    
    private var files:[(name:String, data:Data, filename:String, mimeType:String)] = Array();
    
    internal func append(name:String, value:String){
        fields += [(name: name, value: value)]
    }
    
    internal func append(name:String, data:Data, filename:String, mimeType:String? = nil){
        let type = mimeType ?? determineMimeType(filename: filename)
        files += [(name: name, data: data, filename: filename, mimeType: type)]
    }
    
    private func determineMimeType(filename:String) -> String {
        let type = URL(string: filename)!.pathExtension
        
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
    
    internal func getBody() -> Data? {
        if(fields.count > 0 || files.count > 0){
            
            let body = NSMutableData();
            
            for (field) in fields {
                appendField(body: body, name: field.name, value: field.value)
            }
            
            for (file) in files {
                appendFile(body: body, name: file.name, data: file.data, filename: file.filename, mimeType: file.mimeType);
            }
            
            body.append(stringToData(string: "--\(boundary)--"));
            body.append(nl);
            return body as Data;
        }
        return nil
    }
    
    private func appendFile(body:NSMutableData, name:String, data:Data, filename:String, mimeType:String) {
        body.append(stringToData(string: "--\(boundary)"))
        body.append(nl)
        body.append(stringToData(string: "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\""))
        body.append(nl);
        body.append(stringToData(string: "Content-Type: \(mimeType)"));
        body.append(nl);
        body.append(nl);
        body.append(data);
        body.append(nl);
    }
    
    private func appendField(body:NSMutableData, name:String, value:String) {
        body.append(stringToData(string: "--\(boundary)"))
        body.append(nl)
        body.append(stringToData(string: "Content-Disposition: form-data; name=\"\(name)\""))
        body.append(nl);
        body.append(nl);
        body.append(stringToData(string: value))
        body.append(nl);
    }
}
