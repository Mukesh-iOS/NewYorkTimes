//
//  TopNewsCell.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

class TopNewsCell: UICollectionViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var abstract: UILabel!
    @IBOutlet weak var publishedDate: UILabel!
    
    func loadDataWith(newsInfo: TopStories, withImgaeData: Data) {
        
        title.text = newsInfo.title ?? ""
        abstract.text = newsInfo.abstract ?? ""
        if let pubDate = newsInfo.pubDate {
            publishedDate.text = Date().UTCToLocalTime(pubTime: pubDate)
        }
        coverImage.image = UIImage(data: withImgaeData)
    }
}
