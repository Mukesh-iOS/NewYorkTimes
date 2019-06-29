//
//  TopStoriesDataSource.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

// MARK: - Protocol

protocol TopStoriesDelegate {
    func dismissKeyboard()
    func fetchNewsDetailsFromREST()
    func searchNewsDetailsFromREST()
    func showAlert()
    func showDetailedStories(inVC: DetailedStoriesVC)
}

// MARK: - Enum's

private enum TopStoriesIdentifiers: String {
    case recentSearchs = "RecentlySearched"
    case topNewsCell = "TopNewsCell"
    case activityIndicatorCell = "ActivityIndicatorCell"
    case recentSearchCell = "RecentSearchCell"
    case searchedNewsCell = "SearchedNewsCell"
}

private enum TopStoriesConstants: CGFloat {
    case genericCellHeight = 60
    case searchResultHeightPadding = 45
    case defaultImageHeight = 293
    case topResultsHeightPadding = 75
}

// MARK: - Variables

class TopStoriesDataSource: NSObject {
    
    private let titleFont = UIFont(name: "Helvetica Neue", size: 18.0)
    private let abstractFont = UIFont(name: "Helvetica Neue", size: 14.0)
    private let dateFont = UIFont(name: "Helvetica Neue", size: 13.0)
    
    var recentSearchTableView: UITableView?
    var activityView: UIActivityIndicatorView?
    var newsCollectionView: UICollectionView?
    var articleSearchBar: UISearchBar?
    var topStoriesDelegate :TopStoriesDelegate?
    
    var viewModel: TopStoriesViewModel?
    var pageNumber = 0
    var searchListPageNumber = 0
    var isSearchResultsShown = false
    var searchedNews = ""
    var contentWidth: CGFloat = 0
}

// MARK: - Searchbar Delegates

extension TopStoriesDataSource: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let newsSearch = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) , newsSearch.count > 0 {
            
            activityView?.showActivityIndicator()
            searchListPageNumber = 0
            searchedNews = newsSearch
            viewModel?.fetchDetailsforNews(searchNews: newsSearch, pageNumber: searchListPageNumber)
            
            var searchedTexts = UserDefaults.standard.value(forKey: TopStoriesIdentifiers.recentSearchs.rawValue) as? Array<String>
            
            // Recent searches logic
            if searchedTexts?.contains(newsSearch) ?? false {
                if let index = searchedTexts?.firstIndex(of: newsSearch) {
                    searchedTexts?.remove(at: index)
                }
            }
            if searchedTexts?.count == 10 {
                
                searchedTexts?.remove(at: 9)
            }
            if (searchedTexts == nil) {
                searchedTexts = []
            }
            searchedTexts?.insert(newsSearch, at: 0)
            
            // Save recent searches
            UserDefaults.standard.set(searchedTexts, forKey: TopStoriesIdentifiers.recentSearchs.rawValue)
        }
        
        recentSearchTableView?.isHidden = true
        topStoriesDelegate?.dismissKeyboard()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        recentSearchTableView?.isHidden = false
        recentSearchTableView?.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        isSearchResultsShown = false
        viewModel?.searchedNewsList.removeAll()
        newsCollectionView?.reloadData()
        
        recentSearchTableView?.isHidden = true
        articleSearchBar?.text = nil
        topStoriesDelegate?.dismissKeyboard()
    }
}

// MARK: - Top Stories Collectionview Delegates

extension TopStoriesDataSource: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let searchStoriesCount = viewModel?.searchedNewsList.count, searchStoriesCount > 0, isSearchResultsShown {
            
            return searchStoriesCount + 1
        }
        
        if let topStoriesCount = viewModel?.updatedNewsList.count, topStoriesCount > 0 {
            
            return topStoriesCount + 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Show activity indicator for bottom pagination
        
        if (!isSearchResultsShown && indexPath.row == (viewModel?.updatedNewsList.count ?? 0)) || (isSearchResultsShown && indexPath.row == (viewModel?.searchedNewsList.count ?? 0))  {
            
            guard let indicatorCell = newsCollectionView?.dequeueReusableCell(withReuseIdentifier: TopStoriesIdentifiers.activityIndicatorCell.rawValue, for: indexPath) as? ActivityIndicatorCell else {
                
                return UICollectionViewCell()
            }
            indicatorCell.activityIndicator.startAnimating()
            return indicatorCell
        }
        
        if isSearchResultsShown {
            
            guard let searchedResultCell = newsCollectionView?.dequeueReusableCell(withReuseIdentifier: TopStoriesIdentifiers.searchedNewsCell.rawValue, for: indexPath) as? SearchedNewsCell else {
                
                return UICollectionViewCell()
            }
            
            if let newsDetail = viewModel?.searchedNewsList[indexPath.row] {
                
                searchedResultCell.loadDataWith(newsInfo: newsDetail)
            }
            return searchedResultCell
            
        } else {
            
            // Show top stories cell
            
            guard let cell = newsCollectionView?.dequeueReusableCell(withReuseIdentifier: TopStoriesIdentifiers.topNewsCell.rawValue, for: indexPath) as? TopNewsCell else {
                
                return UICollectionViewCell()
            }
            
            if let newsDetail = viewModel?.updatedNewsList[indexPath.row], let imageData = viewModel?.updatedNewsListCoverData[indexPath.row] {
                
                cell.loadDataWith(newsInfo: newsDetail, withImgaeData: imageData)
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Bottom pagination REST call
        
        if !isSearchResultsShown && indexPath.row == (viewModel?.updatedNewsList.count ?? 0) {
            
            topStoriesDelegate?.fetchNewsDetailsFromREST()
        }
        
        if isSearchResultsShown && indexPath.row == (viewModel?.searchedNewsList.count ?? 0) {
            
            topStoriesDelegate?.searchNewsDetailsFromREST()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isSearchResultsShown {
            
            topStoriesDelegate?.showAlert()

        } else {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailedStoriesVC = storyboard.instantiateViewController(withIdentifier: "DetailedStoriesVC") as? DetailedStoriesVC
            detailedStoriesVC?.selectedIndex = indexPath.row
            detailedStoriesVC?.newsInfo = viewModel?.updatedNewsList
            detailedStoriesVC?.coverImageDataInfo = viewModel?.updatedNewsListCoverData
            
            if let vc = detailedStoriesVC {
                
                topStoriesDelegate?.showDetailedStories(inVC: vc)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isSearchResultsShown && indexPath.row < (viewModel?.searchedNewsList.count ?? 0) {
            
            let titleHeight = UILabel.heightWithContent(text: viewModel?.searchedNewsList[indexPath.row].headline?.main ?? "", font: titleFont!, width: contentWidth)
            let leadParaHeight = UILabel.heightWithContent(text: viewModel?.searchedNewsList[indexPath.row].leadParagraph ?? "", font: abstractFont!, width: contentWidth)
            
            let totalHeight = titleHeight + leadParaHeight + TopStoriesConstants.searchResultHeightPadding.rawValue
            
            return CGSize(width: contentWidth, height: totalHeight)
            
        } else // Calculate dynamic height for top stories
            if !isSearchResultsShown && indexPath.row < (viewModel?.updatedNewsList.count ?? 0) {
                
                
                let titleHeight = UILabel.heightWithContent(text: viewModel?.updatedNewsList[indexPath.row].title ?? "", font: titleFont!, width: contentWidth)
                let abstractHeight = UILabel.heightWithContent(text: viewModel?.updatedNewsList[indexPath.row].abstract ?? "", font: abstractFont!, width: contentWidth)
                let dateHeight = UILabel.heightWithContent(text: viewModel?.updatedNewsList[indexPath.row].pubDate ?? "", font: dateFont!, width: contentWidth)
                
                let expectedHeight = titleHeight + abstractHeight + dateHeight + TopStoriesConstants.defaultImageHeight.rawValue + TopStoriesConstants.topResultsHeightPadding.rawValue
                
                return CGSize(width: contentWidth, height: expectedHeight)
            }
            else {
                // Height for bottom pagination
                
                return CGSize(width: contentWidth, height: TopStoriesConstants.genericCellHeight.rawValue)
        }
    }
}

// MARK: - Recent Searches Tableview Delegates

extension TopStoriesDataSource: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let searchedTexts = UserDefaults.standard.value(forKey: TopStoriesIdentifiers.recentSearchs.rawValue) as? Array<String>, searchedTexts.count > 0 {
            
            return searchedTexts.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return TopStoriesConstants.genericCellHeight.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TopStoriesIdentifiers.recentSearchCell.rawValue) as? RecentSearchCell else {
            return UITableViewCell()
        }
        
        if let searchedTexts = UserDefaults.standard.value(forKey: TopStoriesIdentifiers.recentSearchs.rawValue) as? Array<String> {
            
            cell.recentSearch.text = searchedTexts[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        recentSearchTableView?.isHidden = true
        articleSearchBar?.endEditing(true)
        
        if var searchedTexts = UserDefaults.standard.value(forKey: TopStoriesIdentifiers.recentSearchs.rawValue) as? Array<String> {
            
            // Alter recent searches based on selection made from recent searches
            
            let selectedContent = searchedTexts[indexPath.row]
            searchedTexts.remove(at: indexPath.row)
            searchedTexts.insert(selectedContent, at: 0)
            UserDefaults.standard.set(searchedTexts, forKey: TopStoriesIdentifiers.recentSearchs.rawValue)
            
            // Search action from recent searches
            
            articleSearchBar?.text = selectedContent
            activityView?.showActivityIndicator()
            
            searchListPageNumber = 0
            searchedNews = selectedContent
            viewModel?.fetchDetailsforNews(searchNews: selectedContent, pageNumber: searchListPageNumber)
        }
    }
}
