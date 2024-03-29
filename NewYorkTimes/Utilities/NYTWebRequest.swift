//
//  NYTWebRequest.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

private struct StatusCode {
    
    static let Success = 200
}

struct NYTWebRequest {
    
    static func fetchDetailsWith<T>(serviceURL: URL?,
                                    resultStruct: T.Type,
                                    completionHandler:@escaping ((Any?, String?) -> Void )) where T: Decodable {
        
        if Reachability().isConnectedToNetwork() {
            
            guard let serviceURL = serviceURL else {
                
                completionHandler(nil, "URL not provided")
                return
            }
            
            URLSession.shared.dataTask(with: serviceURL, completionHandler: {
                (data, response, error) in
                
                guard error == nil else {
                    
                    completionHandler(nil, error?.localizedDescription)
                    return
                }
                
                // Check if data is available
                
                guard let responseData = data, let httpResponse = response as? HTTPURLResponse else {
                    
                    DispatchQueue.main.async {
                        completionHandler(nil, "No data in response")
                    }
                    return
                }
                
                switch (httpResponse.statusCode) {
                    
                case StatusCode.Success:
                    
                    do {
                        let response = try JSONSerialization.jsonObject(with: responseData, options:.allowFragments)
                        
                        // This code will be executed for a response json of dictionary format
                        
                        if response is [String: Any] {
                            
                            let decoder = JSONDecoder()
                            
                            let resultantModel = try decoder.decode(resultStruct.self, from: responseData)
                            DispatchQueue.main.async {
                                completionHandler(resultantModel, nil)
                            }
                        }
                        
                        // This code will be executed for a response json of array format
                        if let _ = response as? [[String: Any]] {
                            
                            let resultantModel = decodeArray(json: responseData, asA: resultStruct.self)
                            
                            DispatchQueue.main.async {
                                completionHandler(resultantModel, nil)
                            }
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            completionHandler(nil, error.localizedDescription)
                        }
                    }
                    break
                default:
                    // Failure case
                    DispatchQueue.main.async {
                        completionHandler(nil, "Unsuccessfull process")
                    }
                    break
                }
            }).resume()
        }
        else {
            completionHandler(nil, "Bad spot!! No network available")
        }
    }
    
    func loadQueryParams(_ params : Dictionary<String, Any>?, toURL url : URL) -> URL {
        
        if let params = params, params.count > 0 {
          
            var urlComponents = URLComponents(string: "\(url)")
            
            var queryItems = [URLQueryItem]()
            
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: String(describing: value))
                queryItems.append(queryItem)
            }
            
            urlComponents?.queryItems = queryItems
            
            if let constructedURL = urlComponents?.url {
                
                return constructedURL
            }
        }

        return url
    }
}

private func decode<T: Decodable>(json: Data, asA thing: T.Type) -> T? {
    return try? JSONDecoder().decode(thing, from: json)
}

private func decodeArray<T: Decodable>(json: Data, asA thing: T.Type) -> [T] {
    
    return decode(json: json, asA: [T].self) ?? []
}
