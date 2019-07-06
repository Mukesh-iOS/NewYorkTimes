//
//  DetailedStoriesVC.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

private enum DetailedStoriesIdentifiers: String {
    case detailedStoriesCell = "DetailedStoriesCell"
}

private enum DetailedStoriesConstants: CGFloat {
    case defaultImageHeight = 293
    case detailedStoriesHeightPadding = 80
}

class DetailedStoriesVC: UIViewController {
    
    @IBOutlet weak var detailedCollectionView: UICollectionView!
    var newsInfo: [TopStories]?
    var coverImageDataInfo: [Data]?
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let indexPath = IndexPath(item: selectedIndex ?? 0, section: 0)
        DispatchQueue.main.async {
            self.detailedCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
}

extension DetailedStoriesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return newsInfo?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let deatiledNewssCell = detailedCollectionView.dequeueReusableCell(withReuseIdentifier: DetailedStoriesIdentifiers.detailedStoriesCell.rawValue, for: indexPath) as? DetailedStoriesCell else {
            
            return UICollectionViewCell()
        }
        if let selectedNewsInfo = newsInfo?[indexPath.row], let imageData = coverImageDataInfo?[indexPath.row] {
         
            deatiledNewssCell.loadDataWith(newsInfo: selectedNewsInfo, withImgaeData: imageData)
        }
        
        return deatiledNewssCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let labelWidth = view.frame.size.width - 30
        
        guard let titleFont = UIFont(name: "Helvetica Neue", size: 20.0), let abstractFont = UIFont(name: "Helvetica Neue", size: 15.0) else {
            
            return CGSize(width: 0, height: 0)
        }
        
        let titleHeight = UILabel.heightWithContent(text: newsInfo?[indexPath.row].title ?? "", font: titleFont, width: labelWidth)
        let dateHeight = UILabel.heightWithContent(text: newsInfo?[indexPath.row].pubDate ?? "", font: abstractFont, width: labelWidth)
        let sourceHeight = UILabel.heightWithContent(text: newsInfo?[indexPath.row].source ?? "", font: abstractFont, width: labelWidth)
        let imageHeight: CGFloat = DetailedStoriesConstants.defaultImageHeight.rawValue
        var newsCaption = ""

        switch newsInfo?[indexPath.row].multimedia {
        case .dictInfo(let mediaInfo)?:
            let filtered = mediaInfo.filter { $0.format == "mediumThreeByTwo440"}
            if filtered.count > 0 {
                
                let imageCaption = filtered[0].caption ?? ""
                let coverCaption = imageCaption + (imageCaption.count > 0 ? " | " : "") + (filtered[0].copyright ?? "")
                
                newsCaption += coverCaption
            }
        case .stringInfo(let stringInfo)?:
            print(stringInfo)
        case .none:
            print("Not available")
        }
        
        let captionHeight = UILabel.heightWithContent(text: newsCaption, font: abstractFont, width: labelWidth)
        
        let expectedHeight = titleHeight + dateHeight + sourceHeight + imageHeight + captionHeight + DetailedStoriesConstants.detailedStoriesHeightPadding.rawValue
        
        return CGSize(width: view.frame.width, height: expectedHeight)
    }
}
