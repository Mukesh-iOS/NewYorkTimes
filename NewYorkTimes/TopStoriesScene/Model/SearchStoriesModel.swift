
//
//  SearchStoriesModel.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

struct SearchStoriesModel: Codable {
    private enum CodingKeys: String, CodingKey {
        case response
    }
    let response: SearchResponse?
}

struct SearchResponse: Codable {
    private enum CodingKeys: String, CodingKey {
        case docs
    }
    let docs: [Docs]?
}

struct Docs: Codable {
    private enum CodingKeys: String, CodingKey {
        case headline
        case leadParagraph = "lead_paragraph"
    }

    let headline: Headline?
    let leadParagraph: String?
}

struct Headline: Codable {
    private enum CodingKeys: String, CodingKey {
        case main
    }
    
    let main: String?
}
