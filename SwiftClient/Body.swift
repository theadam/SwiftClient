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
public class Body {
    public var value:AnyObject?;
    
    public init(_ rawValue: AnyObject?){
        self.value = rawValue;
    }
    
    public subscript(key: String) -> Body {
        get{
            if let value = self.value as? Dictionary<String, AnyObject> {
                return Body(value[key]);
            }
            return Body(nil);
        }
    }
    
    public subscript(key: Int) -> Body {
        get{
            if let value = self.value as? Array<AnyObject> {
                return Body(value[key]);
            }
            return Body(nil);
        }
    }
}
