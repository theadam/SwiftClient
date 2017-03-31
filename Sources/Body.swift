//
//  Body.swift
//  SwiftClient
//
//  Created by Adam Nalisnick on 10/30/14.
//  Copyright (c) 2014 Adam Nalisnick. All rights reserved.
//

import Foundation

/// A simple wrapper for AnyObject's that are actually Arrays or Dictionaries
/// Made to work with data that has been parsed from JSON.
open class Body {
    open var value:Any?;
    
    public init(rawValue: Any?){
        self.value = rawValue;
    }
    
    open subscript(key: String) -> Body {
        get{
            if let value = self.value as? Dictionary<String, Any> {
                return Body(rawValue: value[key]);
            }
            return Body(rawValue: nil);
        }
    }
    
    open subscript(key: Int) -> Body {
        get{
            if let value = self.value as? Array<Any> {
                return Body(rawValue: value[key]);
            }
            return Body(rawValue: nil);
        }
    }
}
