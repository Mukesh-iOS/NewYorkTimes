//
//  NewYorkTimesTests.swift
//  NewYorkTimesTests
//
//  Created by Mukesh on 24/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import XCTest
@testable import NewYorkTimes

class NewYorkTimesTests: XCTestCase {

    var viewModel: TopStoriesViewModel?
    var sessionUnderTest: URLSession!
    
    override func setUp() {
        super.setUp()
        sessionUnderTest = URLSession(configuration: URLSessionConfiguration.default)
        viewModel = TopStoriesViewModel()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        
        sessionUnderTest = nil
        viewModel = nil
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // Asynchronous test: faster fail
    func testTopStoriesInfoFromREST() {
        // given
        guard let url = URL(string: "https://api.nytimes.com/svc/news/v3/content/all/all.json?api-key=5763846de30d489aa867f0711e2b031c&limit=10&offset=0") else {
            
            XCTFail("URL not available")
            return
        }
        
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        // when
        if Reachability().isConnectedToNetwork() {
            let dataTask = sessionUnderTest.dataTask(with: url) { data, response, error in
                statusCode = (response as? HTTPURLResponse)?.statusCode
                responseError = error
                promise.fulfill()
                
                // then
                XCTAssertNil(responseError)
                if (statusCode != 200) {
                    
                    XCTFail("Rest call failed")
                    return
                }
                
                guard let responseData = data else {
                    
                    XCTFail("Data not available")
                    return
                }
                
                do {
                    let response = try JSONSerialization.jsonObject(with: responseData, options:.allowFragments)
                    
                    XCTAssertNotNil(response, "Parsed json is empty")
                    
                    if let topStories = response as? [String: Any], let stories = topStories["results"] as? [[String: Any]] {
                        
                        XCTAssertTrue(stories.count > 0)
                        
                    } else {
                        
                        XCTFail("Unexpected response")
                    }
                }
                catch {
                    XCTAssertNil(error, "\(error.localizedDescription)")
                }
            }
            dataTask.resume()
            waitForExpectations(timeout: 5, handler: nil)
        } else {
            
            XCTFail("Internet conntection not available")
        }
    }
    
    // Asynchronous test: faster fail
    func testSearchStoriesInfoFromREST() {
        // given
        guard let url = URL(string: "https://api.nytimes.com/svc/search/v2/articlesearch.json?api-key=5763846de30d489aa867f0711e2b031c&q=Election&page=0") else {
            
            XCTFail("URL not available")
            return
        }
        
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        // when
        if Reachability().isConnectedToNetwork() {
            let dataTask = sessionUnderTest.dataTask(with: url) { data, response, error in
                
                statusCode = (response as? HTTPURLResponse)?.statusCode
                responseError = error
                promise.fulfill()
                
                // then
                XCTAssertNil(responseError)
                if (statusCode != 200) {
                    
                    XCTFail("Rest call failed")
                    return
                }
                
                guard let responseData = data else {
                    
                    XCTFail("Data not available")
                    return
                }
                
                do {
                    let response = try JSONSerialization.jsonObject(with: responseData, options:.allowFragments)
                    
                    XCTAssertNotNil(response, "Parsed json is empty")
                    
                    if let searchStories = response as? [String: Any], let stories = searchStories["response"] as? [String: Any], let docs = stories["docs"] as? [[String: Any]] {
                        
                        XCTAssertTrue(docs.count > 0)
                        
                    } else {
                        
                        XCTFail("Unexpected response")
                    }
                }
                catch {
                    XCTAssertNil(error, "\(error.localizedDescription)")
                }
            }
            dataTask.resume()
            waitForExpectations(timeout: 5, handler: nil)
        } else {
            
            XCTFail("Internet conntection not available")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
