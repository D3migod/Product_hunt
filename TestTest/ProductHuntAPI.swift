//
//  ProductHuntAPI.swift
//  TestTest
//
//  Created by Булат Галиев on 28.01.17.
//  Copyright © 2017 Булат Галиев. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class ProductHuntAPI {
    var manager: SessionManager!
    init() {
        let memoryCapacity = 500 * 1024 * 1024; // 500 MB
        let diskCapacity = 500 * 1024 * 1024;
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "shared_cache")
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.urlCache = cache
        manager = Alamofire.SessionManager(configuration: configuration)
    }
    
    /**
     Performs Get query for categories to api.producthunt.com.
     
     - Parameter parse: parses returned JSON response
     - Parameter completion: processes result of the parse
     */
    func getCategories(parse: @escaping (JSON, @escaping ([PostCategory]) -> Void) -> Void, completion: @escaping ([PostCategory]) -> Void) {
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            manager.request(
                "https://api.producthunt.com/v1/categories",
                method: .get,
                parameters: nil,
                headers: ["Accept": "application/json",
                          "Content-Type": "application/json",
                          "Authorization": "Bearer \(accessToken)",
                    "Host": "api.producthunt.com"]).responseJSON { (response) -> Void in
                        print(response.description)
                        let cachedURLResponse = CachedURLResponse(response: response.response!, data: (response.data! as NSData) as Data, userInfo: nil, storagePolicy: .allowed)
                        URLCache.shared.storeCachedResponse(cachedURLResponse, for: response.request!)
                        
                        guard response.result.isSuccess, response.result.error == nil else {
                            print("Error while getting response: \(response.result.error)")
                            completion([PostCategory]())
                            return
                        }
                        parse(JSON(data: cachedURLResponse.data), completion)
            }
        }
    }
    
    /**
        Performs Get query for posts to api.producthunt.com.
     
        - Parameter parse: parses returned JSON response
        - Parameter completion: processes result of the parse
        - Parameter category: posts in given 'category'
        - Parameter days_ago: posts created 'days_ago' days ago are returned
     */
    func getPosts(parse: @escaping (JSON, @escaping ([Post]) -> Void) -> Void, completion: @escaping ([Post]) -> Void, category: String, days_ago: Int) {
        var urlParameters = "/\(category)/posts"
        if days_ago > 0 {
            urlParameters += "?days_ago=\(days_ago)"
        }

        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            manager.request(
                "https://api.producthunt.com/v1/categories\(urlParameters)",
                method: .get,
                parameters: nil,
                headers: ["Accept": "application/json",
                          "Content-Type": "application/json",
                          "Authorization": "Bearer \(accessToken)",
                          "Host": "api.producthunt.com"]).responseJSON { (response) -> Void in
                            print(response.description)
                            let cachedURLResponse = CachedURLResponse(response: response.response!, data: (response.data! as NSData) as Data, userInfo: nil, storagePolicy: .allowed)
                            URLCache.shared.storeCachedResponse(cachedURLResponse, for: response.request!)
                            
                            guard response.result.isSuccess, response.result.error == nil else {
                                print("Error while getting response: \(response.result.error)")
                                completion([Post]())
                                return
                            }
                            parse(JSON(data: cachedURLResponse.data), completion)
            }
        }
    }
    
    /**
     Gets client level token from api.producthunt.com.
     
     - Parameter parse: parses returned JSON response
     - Parameter completion: processes result of the parse
     */
    func getToken(parse: @escaping (JSON, @escaping () -> Void) -> Void, completion: @escaping () -> Void) {
        manager.request(
            "https://api.producthunt.com/v1/oauth/token",
            method: .post,
            parameters: ["client_id": "a4e3933bbf7d9120a255665183d7a583594d0cdec57cb4200a10c44aa7dfdbb2",
                         "client_secret": "15c519140dd354423986d41f4271202c1be64f6920c3a72a2f638f52f1e69d0b",
                         "grant_type": "client_credentials"],
            encoding: JSONEncoding.default,
            headers: ["Accept": "application/json", "Content-Type": "application/json",
                      "Host": "api.producthunt.com"]).responseJSON { (response) -> Void in
                        print(response.description)
                        guard response.result.isSuccess else {
                            print("Error while getting response: \(response.result.error)")
                            completion()
                            return
                        }
                        parse(JSON(response.result.value!), completion)
        }
    }
    
}
