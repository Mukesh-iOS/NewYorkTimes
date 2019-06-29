//
//  NYTServiceHelper.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

enum APIKey: String {
    
    case nyTimes = "5763846de30d489aa867f0711e2b031c"
}

enum ContentLimit: Int {
    
    case defaultLimit = 10
}

enum FTError: Error {
    
    case Invalid(String)
}

class NYTServiceHelper: NSObject {
    
    private static let baseURL = "https://api.nytimes.com/svc"
    
    static let listOfNews = NYTServiceHelper.baseURL + "/news/v3/content/all/all.json"
    
    static let searchNews = NYTServiceHelper.baseURL + "/search/v2/articlesearch.json"
}
