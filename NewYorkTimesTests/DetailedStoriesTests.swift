//
//  DetailedStoriesTests.swift
//  NewYorkTimesTests
//
//  Created by Mukesh on 06/07/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import XCTest
@testable import NewYorkTimes

class DetailedStoriesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTopStoriesInfo() {
        
        if Reachability().isConnectedToNetwork() {
            
            testSearchStoriesInfoFromREST()
            
        } else {
            
            testSearchStoriesInfoFromMock()
        }
    }
    
    func testSearchStoriesInfoFromREST() {
        
        guard let url = URL(string: "https://api.nytimes.com/svc/search/v2/articlesearch.json?api-key=5763846de30d489aa867f0711e2b031c&q=Election&page=0") else {
            
            XCTFail("URL not available")
            return
        }
        
        NYTWebRequest.fetchDetailsWith(serviceURL: url, resultStruct: SearchStoriesModel.self) { (newsInfo, errorInfo) in
            
            guard (newsInfo as? SearchStoriesModel) != nil else {
                
                XCTFail(errorInfo ?? "Unkown error")
                return
            }
        }
    }
    
    func testSearchStoriesInfoFromMock() {
        
        if let path = Bundle.main.path(forResource: "DetailedStories", ofType: "json") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            XCTAssertNotNil(data, "Data is nil")
            let manifestData = try? JSONSerialization.jsonObject(with:data! , options: .mutableContainers)
            XCTAssertNotNil(manifestData, "Manifest Json is Invalid")
            guard (manifestData as? [String : Any]) != nil else {
                
                XCTFail("Unexpected json format")
                return
            }
        } else {
            
            XCTFail("Problem in path formation")
        }
    }
    
    func testTopStoriesResults() {
        
        if let url = Bundle.main.url(forResource: "DetailedStories", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let searchedStories = try decoder.decode(SearchStoriesModel.self, from: data)
                XCTAssertNotNil(searchedStories)
                
                guard let results = searchedStories.response?.docs else {
                    
                    XCTFail("No results available")
                    return
                }
                XCTAssertTrue(results.count > 0)
            } catch {
                XCTFail("\(error.localizedDescription)")
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
