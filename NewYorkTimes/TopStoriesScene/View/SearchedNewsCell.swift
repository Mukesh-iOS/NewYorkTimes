//
//  SearchedNewsCell.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

class SearchedNewsCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var leadParagraph: UILabel!
    
    func loadDataWith(newsInfo: Docs) {
     
        title.text = newsInfo.headline?.main ?? ""
        leadParagraph.text = newsInfo.leadParagraph ?? ""
    }
}
