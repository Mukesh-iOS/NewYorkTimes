//
//  DetailedStoriesCell.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

class DetailedStoriesCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var pubDate: UILabel!
    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var caption: UILabel!
    
    func loadDataWith(newsInfo: TopStories, withImgaeData: Data) {
        
        title.text = newsInfo.title ?? ""
        if let publishedDate = newsInfo.pubDate {
            pubDate.text = Date().UTCToLocalTime(pubTime: publishedDate)
        }
        source.text = newsInfo.source ?? ""
        coverImage.image = UIImage(data: withImgaeData)
        
        switch newsInfo.multimedia {
        case .dictInfo(let mediaInfo):
            let filtered = mediaInfo.filter { $0.format == "mediumThreeByTwo440"}
            
            if filtered.count > 0 {
             
                let imageCaption = filtered[0].caption ?? ""
                let coverCaption = imageCaption + (imageCaption.count > 0 ? " | " : "") + (filtered[0].copyright ?? "")
                
                caption.text = coverCaption
            }
        case .stringInfo(let stringInfo):
            print(stringInfo)
        }
    }
}
