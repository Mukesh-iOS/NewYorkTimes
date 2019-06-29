//
//  TopStoriesViewModel.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

class TopStoriesViewModel: NSObject {
    
    var topStoriesDetails: Variable<TopStoriesModel> = Variable<TopStoriesModel>()
    var searchStoriesDetails: Variable<SearchStoriesModel> = Variable<SearchStoriesModel>()
    
    var error: Variable<FTError> = Variable<FTError>()
    
    var updatedNewsList: [TopStories] = []
    var updatedNewsListCoverData: [Data] = []
    var searchedNewsList: [Docs] = []
    
    func getTopStories(pageNumber: Int) {
        
        let params = NSMutableDictionary()
        params.setValue(APIKey.nyTimes.rawValue, forKey: "api-key")
        params.setValue(ContentLimit.defaultLimit.rawValue, forKey: "limit")
        params.setValue(ContentLimit.defaultLimit.rawValue * pageNumber, forKey: "offset")

        let searchURL = NYTWebRequest().loadQueryParams(params, toURL: URL(string: NYTServiceHelper.listOfNews)!)
        
        NYTWebRequest.fetchDetailsWith(serviceURL: searchURL, resultStruct: TopStoriesModel.self) { [weak self] (newsInfo, errorInfo) in
            
            self?.topStoriesDetails.value = newsInfo as? TopStoriesModel
            
            if let newsList = self?.topStoriesDetails.value?.results {
                
                if (pageNumber == 0) {
                    self?.updatedNewsList.removeAll()
                    self?.updatedNewsListCoverData.removeAll()
                }
                
                for sortedNewsList in newsList.compactMap({ $0 }).filter({ $0.coverImage?.count ?? 0 > 0}) {
                    self?.updatedNewsList.append(sortedNewsList)
                    
                    switch sortedNewsList.multimedia {
                    case .dictInfo(let mediaInfo):
                        let filtered = mediaInfo.filter { $0.format == "mediumThreeByTwo440"}
                        if filtered.count > 0, let coverPic = URL(string: filtered[0].url ?? "") {
                            
                            let imageData = Data().getDataFor(url: coverPic)
                            self?.updatedNewsListCoverData.append(imageData)
                        }
                    case .stringInfo(let stringInfo):
                        print(stringInfo)
                    }
                }
            }
            
            if let errorDescription = errorInfo {
                
                self?.error.value = FTError.Invalid(errorDescription)
            }
        }
    }
    
    func fetchDetailsforNews(searchNews: String, pageNumber: Int) {
        
        let params = NSMutableDictionary()
        params.setValue(APIKey.nyTimes.rawValue, forKey: "api-key")
        params.setValue(searchNews, forKey: "q")
        params.setValue(pageNumber, forKey: "page")
        
        let searchURL = NYTWebRequest().loadQueryParams(params, toURL: URL(string: NYTServiceHelper.searchNews)!)
        
        NYTWebRequest.fetchDetailsWith(serviceURL: searchURL, resultStruct: SearchStoriesModel.self) { [weak self] (newsInfo, errorInfo) in
            
            if let newsList = (newsInfo as? SearchStoriesModel)?.response?.docs {
                
                if (pageNumber == 0) {
                    self?.searchedNewsList.removeAll()
                }
                self?.searchedNewsList += newsList
            }
            
            self?.searchStoriesDetails.value = newsInfo as? SearchStoriesModel
            
            if let errorDescription = errorInfo {
                
                self?.error.value = FTError.Invalid(errorDescription)
            }
        }
    }
}
