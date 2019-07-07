//
//  TopStoriesTests.swift
//  NewYorkTimesTests
//
//  Created by Mukesh on 05/07/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import XCTest
@testable import NewYorkTimes

class TopStoriesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testTopStoriesInfo() {
        
        if Reachability().isConnectedToNetwork() {
            
            testTopStoriesInfoFromREST()
            
        } else {
            
            testTopStoriesInfoFromMock()
        }
    }
    
    func testTopStoriesInfoFromREST() {
        
        guard let url = URL(string: "https://api.nytimes.com/svc/news/v3/content/all/all.json?api-key=5763846de30d489aa867f0711e2b031c&limit=10&offset=0") else {
            
            XCTFail("URL not available")
            return
        }
        
        NYTWebRequest.fetchDetailsWith(serviceURL: url, resultStruct: TopStoriesModel.self) { (newsInfo, errorInfo) in
            
            guard (newsInfo as? TopStoriesModel) != nil else {
                
                XCTFail(errorInfo ?? "Unkown error")
                return
            }
        }
    }
    
    func testTopStoriesInfoFromMock() {
        
        if let path = Bundle.main.path(forResource: "TopStories", ofType: "json") {
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
        
        if let url = Bundle.main.url(forResource: "TopStories", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let topStories = try decoder.decode(TopStoriesModel.self, from: data)
                XCTAssertNotNil(topStories)
                
                guard let results = topStories.results else {
                    
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
