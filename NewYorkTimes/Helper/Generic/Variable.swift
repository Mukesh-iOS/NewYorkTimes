//
//  Variable.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import Foundation

class Variable<type>{
    
    typealias block = ((_ value:type) -> Void)
    private var data: type?
    private var callback: block?
    
    var value: type? {
        get {
            return data
        }
        set {
            data = newValue
            if let data = data {
                callback?(data)
            }
        }
    }
    
    func notify(notifier: block?) {
        callback = notifier
    }
}
