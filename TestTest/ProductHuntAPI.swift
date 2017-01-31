//
//  ProductHuntAPI.swift
//  TestTest
//
//  Created by Булат Галиев on 28.01.17.
//  Copyright © 2017 Булат Галиев. All rights reserved.
//

import Foundation
import SystemConfiguration
import Alamofire
import SwiftyJSON

class ProductHuntAPI {
    
    var onlineManager: SessionManager!
    var offlineManager: SessionManager!
    
    var headers: [String: String] {
        get {
            if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
                return ["Accept": "application/json",
                        "Content-Type": "application/json",
                        "Authorization": "Bearer \(accessToken)",
                    "Host": "api.producthunt.com"]
            } else {
                return [:]
            }
        }
    }
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.urlCache = URLCache(memoryCapacity: 100 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "shared_cache")
        onlineManager = Alamofire.SessionManager(configuration: configuration)
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        offlineManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    /**
     Checks internet connection for availability
     
    - Returns: True, if internet is available
     */
    private func isNetworkAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    /**
     Performs Get query for categories to api.producthunt.com.
     
     - Parameter parse: parses returned JSON response
     - Parameter completion: processes result of the parse
     */
    func getCategories(parse: @escaping (JSON, Error?, @escaping ([PostCategory], Error?) -> Void) -> Void, completion: @escaping ([PostCategory], Error?) -> Void) {
        let currentManager = isNetworkAvailable() ? onlineManager: offlineManager
        currentManager!.request(
            "https://api.producthunt.com/v1/categories",
            method: .get,
            parameters: nil,
            headers: headers).responseJSON { response in
                print(response.description)
                guard let receivedResponse = response.response,
                    let receivedData = response.data,
                    let receivedRequest = response.request,
                    response.result.isSuccess else {
                        print("Error while getting response: \(response.result.error)")
                        completion([PostCategory](), response.result.error)
                        return
                }
                let cachedURLResponse = CachedURLResponse(response: receivedResponse, data: (receivedData as NSData) as Data, userInfo: nil, storagePolicy: .allowed)
                URLCache.shared.storeCachedResponse(cachedURLResponse, for: receivedRequest)
                parse(JSON(data: cachedURLResponse.data), response.result.error, completion)
        }
        
    }
    
    /**
     Performs Get query for posts to api.producthunt.com.
     
     - Parameter parse: parses returned JSON response
     - Parameter completion: processes result of the parse
     - Parameter category: posts in given 'category'
     - Parameter days_ago: posts created 'days_ago' days ago are returned
     */
    func getPosts(parse: @escaping (JSON, Error?, @escaping ([Post], Error?) -> Void) -> Void, completion: @escaping ([Post], Error?) -> Void, category: String, days_ago: Int) {
        var urlParameters = "/\(category)/posts"
        if days_ago > 0 {
            urlParameters += "?days_ago=\(days_ago)"
        }
        let currentManager = isNetworkAvailable() ? onlineManager: offlineManager
        currentManager!.request(
            "https://api.producthunt.com/v1/categories\(urlParameters)",
            method: .get,
            parameters: nil,
            headers: headers).responseJSON { (response) -> Void in
                print(response.description)
                guard let receivedResponse = response.response,
                    let receivedData = response.data,
                    let receivedRequest = response.request,
                    response.result.isSuccess else {
                        print("Error while getting response: \(response.result.error)")
                        completion([Post](), response.result.error)
                        return
                }
                let cachedURLResponse = CachedURLResponse(response: receivedResponse, data: (receivedData as NSData) as Data, userInfo: nil, storagePolicy: .allowed)
                URLCache.shared.storeCachedResponse(cachedURLResponse, for: receivedRequest)
                parse(JSON(data: cachedURLResponse.data), response.result.error, completion)
        }
        
    }
    
    /**
     Gets client level token from api.producthunt.com.
     
     - Parameter parse: parses returned JSON response
     - Parameter completion: processes result of the parse
     */
    func getToken(parse: @escaping (JSON, Error?, @escaping (Error?) -> Void) -> Void, completion: @escaping (Error?) -> Void) {
        Alamofire.request(
            "https://api.producthunt.com/v1/oauth/token",
            method: .post,
            parameters: ["client_id": "a4e3933bbf7d9120a255665183d7a583594d0cdec57cb4200a10c44aa7dfdbb2",
                         "client_secret": "15c519140dd354423986d41f4271202c1be64f6920c3a72a2f638f52f1e69d0b",
                         "grant_type": "client_credentials"],
            encoding: JSONEncoding.default,
            headers: ["Accept": "application/json", "Content-Type": "application/json",
                      "Host": "api.producthunt.com"]).responseJSON { (response) -> Void in
                        print(response.description)
                        guard response.result.isSuccess,
                            let receivedValue = response.result.value,
                            response.result.error == nil else {
                                print("Error while getting response: \(response.result.error)")
                                completion(response.result.error)
                                return
                        }
                        parse(JSON(receivedValue), response.result.error, completion)
        }
    }
    
}
