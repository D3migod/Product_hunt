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
    /**
        Performs Get query to api.producthunt.com. 
     
        - Parameter parse: parses returned JSON response
        - Parameter completion: processes result of the parse
        - Parameter days_ago: posts created 'days_ago' days ago are returned
     */
    func getData(parse: @escaping (JSON, @escaping ([Post]) -> Void) -> Void, completion: @escaping ([Post]) -> Void, days_ago: Int) {
        var urlParameters = ""
        if days_ago > 0 {
            urlParameters = "?days_ago=\(days_ago)"
        }
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            Alamofire.request(
                "https://api.producthunt.com/v1/categories/tech/posts" + urlParameters,
                method: .get,
                parameters: nil,
                headers: ["Accept": "application/json",
                          "Content-Type": "application/json",
                          "Authorization": "Bearer \(accessToken)",
                          "Host": "api.producthunt.com"]).responseJSON { (response) -> Void in
                            print(response.description)
                            guard response.result.isSuccess else {
                                print("Error while getting response: \(response.result.error)")
                                completion([Post]())
                                return
                            }
                            //fix error
                            parse(JSON(response.result.value!), completion)
            }
        }
    }
    
    /**
     Gets client level token from api.producthunt.com.
     
     - Parameter parse: parses returned JSON response
     - Parameter completion: processes result of the parse
     */
    func getToken(parse: @escaping (JSON, @escaping () -> Void) -> Void, completion: @escaping () -> Void) {
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
                        guard response.result.isSuccess else {
                            print("Error while getting response: \(response.result.error)")
                            completion()
                            return
                        }
                        parse(JSON(response.result.value!), completion)
        }
    }
    
}
