//
//  RestApiManager.swift
//  occupyhdm
//
//  Created by user on 19.04.16.
//  Copyright © 2016 occupyhdm. All rights reserved.
//

import Foundation

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    func makeRestRequest(query: String, callback: (result: AnyObject) -> Void) {
        let baseUrl: String = "http://localhost:8080"
        
        let endpoint: String = baseUrl + query
        let url = NSURL(string: endpoint)
        let urlRequest = NSURLRequest(URL: url!)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) in
            if (error != nil) {
                print("error calling GET on " + query)
                print(error)
                return
            }
            if (data == nil) {
                print("Error: did not receive data")
                return
            }
            
            do {
                if let result = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String: AnyObject] {
                    print("Retrieved REST data for query", query)
                    callback(result: result)
                    return
                }
                
                print("error trying to convert data to JSON")
                return
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
}