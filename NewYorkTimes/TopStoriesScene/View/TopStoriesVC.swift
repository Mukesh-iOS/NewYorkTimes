//
//  TopStoriesVC.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

class TopStoriesVC: UIViewController, TopStoriesDelegate {
    
    @IBOutlet weak var articleSearchBar: UISearchBar!
    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var recentSearchTableView: UITableView!
    
    private var viewModel: TopStoriesViewModel?
    private let leadingAndTrailingPadding: CGFloat = 30
    
    var dataSource = TopStoriesDataSource()
    
    var refresher:UIRefreshControl!
    
    lazy var activityView: UIActivityIndicatorView = {
        let activitySpinnerView = UIActivityIndicatorView(style: .gray)
        activitySpinnerView.center = view.center
        view.addSubview(activitySpinnerView)
        activitySpinnerView.isHidden = true
        return activitySpinnerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetup()
        initialSetup()
        dataSourceSetup()
    }
    
    private func dataSourceSetup() {
        
        dataSource.recentSearchTableView = recentSearchTableView
        dataSource.activityView = activityView
        dataSource.newsCollectionView = newsCollectionView
        dataSource.articleSearchBar = articleSearchBar
        dataSource.topStoriesDelegate = self
        dataSource.viewModel = viewModel
        dataSource.contentWidth = view.frame.size.width - leadingAndTrailingPadding
        
        recentSearchTableView.delegate = dataSource
        recentSearchTableView.dataSource = dataSource
        newsCollectionView.dataSource = dataSource
        newsCollectionView.delegate = dataSource
        articleSearchBar.delegate = dataSource
    }
    
    private func viewSetup() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        recentSearchTableView.isHidden = true
        
        // Pull to refresh
        self.refresher = UIRefreshControl()
        newsCollectionView.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.darkGray
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        newsCollectionView.addSubview(refresher)
    }
    
    private func initialSetup() {
        
        // View Model Binding
        viewModel = TopStoriesViewModel()
        
        viewModel?.topStoriesDetails.notify(notifier: { [weak self] (newsInfo: TopStoriesModel) in
            
            self?.activityView.hideActivity()
            
            // If pull to refresh used
            self?.endPullToRefresh()
            
            self?.updateScreen()
        })
        
        viewModel?.searchStoriesDetails.notify(notifier: { [weak self] (newsInfo: SearchStoriesModel) in
            
            self?.activityView.hideActivity()
            
            // If pull to refresh used
            self?.endPullToRefresh()
            
            self?.updateScreenWithSearchedNews()
        })
        
        viewModel?.error.notify(notifier: { [weak self] (error: FTError) in
            
            guard let strongSelf = self else {
                
                return
            }
            
            strongSelf.activityView.hideActivity()
            
            // If pull to refresh used
            strongSelf.endPullToRefresh()
            
            switch error {
                
            case .Invalid(let message):
                
                UIAlertController.showSimpleAlert(message: message, inViewController: strongSelf)
            }
        })
        
        // Get stories for the 1st time
        viewModel?.getTopStories(pageNumber: dataSource.pageNumber)
    }
    
    @objc func loadData() {
        
        // Pull to refresh REST call
        
        if dataSource.isSearchResultsShown {
            dataSource.searchListPageNumber = 0
            viewModel?.fetchDetailsforNews(searchNews: dataSource.searchedNews, pageNumber: dataSource.searchListPageNumber)
        } else {
            
            dataSource.pageNumber = 0
            viewModel?.getTopStories(pageNumber: dataSource.pageNumber)
        }
    }
    
    func fetchNewsDetailsFromREST() {
        
        // Stories from pagination REST call
        dataSource.pageNumber += 1
        viewModel?.getTopStories(pageNumber: dataSource.pageNumber)
    }
    
    func searchNewsDetailsFromREST() {
        
        // Search news from pagination REST call
        dataSource.searchListPageNumber += 1
        viewModel?.fetchDetailsforNews(searchNews: dataSource.searchedNews, pageNumber: dataSource.searchListPageNumber)
    }
    
    private func updateScreen() {
        
        newsCollectionView.reloadData()
    }
    
    private func updateScreenWithSearchedNews() {
        
        if viewModel?.searchedNewsList.count == 0 {
            
            UIAlertController.showSimpleAlert(message: "Searched content not found", inViewController: self)
            return
        }
        
        dataSource.isSearchResultsShown = true
        newsCollectionView.reloadData()
    }
    
    private func endPullToRefresh() {
        
        if let refreshIndicator = refresher, refreshIndicator.isRefreshing {
            refreshIndicator.endRefreshing()
        }
    }
    
    // MARK: Dismiss Keyboard
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    // MARK: Alert
    
    func showAlert() {
        
        UIAlertController.showSimpleAlert(message: "This feature is not available", inViewController: self)
    }
    
    // MARK: Detailed Stories
    
    func showDetailedStories(inVC: DetailedStoriesVC) {
        
        self.navigationController?.pushViewController(inVC, animated: true)
    }
}
