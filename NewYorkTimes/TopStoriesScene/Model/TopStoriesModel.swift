//
//  TopStoriesModel.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

struct TopStoriesModel: Decodable {
    private enum CodingKeys: String, CodingKey {
        case results
    }
    let results: [TopStories]?
}

struct TopStories: Decodable {
    private enum CodingKeys: String, CodingKey {
        case title
        case abstract
        case coverImage = "thumbnail_standard"
        case source
        case pubDate = "published_date"
        case multimedia
    }
    
    let title: String?
    let abstract: String?
    let coverImage: String?
    let source: String?
    let pubDate: String?
    let multimedia: DynamicMultimedia
}

enum DynamicMultimedia: Decodable {
    
    case dictInfo([Multimedias]), stringInfo(String)
    
    init(from decoder: Decoder) throws {
        if let dictInfo = try? decoder.singleValueContainer().decode([Multimedias].self) {
            self = .dictInfo(dictInfo)
            return
        }
        
        if let stringInfo = try? decoder.singleValueContainer().decode(String.self) {
            self = .stringInfo(stringInfo)
            return
        }
        
        throw MediaError.missingValue
    }
    
    enum MediaError: Error {
        case missingValue
    }
}

struct Multimedias: Codable {
    private enum CodingKeys: String, CodingKey {
        case url
        case format
        case type
        case caption
        case copyright
        case height
        case subtype
    }
    
    let subtype: String?
    let url: String?
    let format: String?
    let type: String?
    let caption: String?
    let copyright: String?
    let height: Int?
}
