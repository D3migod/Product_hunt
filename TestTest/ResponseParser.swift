//
//  ResponseParser.swift
//  TestTest
//
//  Created by Булат Галиев on 28.01.17.
//  Copyright © 2017 Булат Галиев. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PostCategory {
    let id: Int
    let name: String
    let slug: String
}

struct Post {
    let category_id: Int
    let day: String
    let id: Int
    let name: String
    let tagline: String
    let upvotes: Int
    let thumbnail: Thumbnail
    let screenshot: Screenshot
    let redirect_url: String
}

struct Thumbnail {
    let id: Int
    let image_url: String
}

struct Screenshot {
    let smallImageUrl: String
    let bigImageUrl: String
}

class ResponseParser {
    static let sharedInstance: ResponseParser = {
        let instance = ResponseParser()
        return instance
    }()
    
    var productHuntAPI = ProductHuntAPI()
    
    /**
     Gets client level token from api.producthunt.com
     
     - Parameter completion: is called after getting token
     */
    func authorize(completion: @escaping () -> Void) {
        productHuntAPI.getToken(parse: parse, completion: completion)
    }
    
    /**
     Gets categories from api.producthunt.com
     
     - Parameter completion: is called after getting categories
     */
    func getCategories(completion: @escaping ([PostCategory]) -> Void) {
        productHuntAPI.getCategories(parse: parse, completion: completion)
    }
    
    /**
     Gets posts from api.producthunt.com
     
     - Parameter completion: processes array of posts
     - Parameter category: posts in given 'category'
     - Parameter days_ago: posts created 'days_ago' days ago are returned
     */
    func getPosts(completion: @escaping ([Post]) -> Void, category: PostCategory, days_ago: Int) {
        productHuntAPI.getPosts(parse: parse, completion: completion, category: category.slug, days_ago: days_ago)
    }
    
    /**
     Parses result of categories get query
     
     - Parameter json: response in JSON format
     - Parameter completion: processes result of the parse
     */
    func parse(json: JSON, completion: @escaping ([PostCategory]) -> Void) {
        if let categories = json["categories"].array {
            var retrievedCategories = [PostCategory]()
            for category in categories {
                retrievedCategories.append(parseSingleCategory(category: category))
            }
            completion(retrievedCategories)
        } else {
            completion([PostCategory]())
        }
    }
    
    /**
     Parses result of posts get query
     
     - Parameter json: response in JSON format
     - Parameter completion: processes result of the parse
     */
    func parse(json: JSON, completion: @escaping ([Post]) -> Void) {
        if let posts = json["posts"].array {
            var retrievedPosts = [Post]()
            for post in posts {
                retrievedPosts.append(parseSinglePost(post: post))
            }
            completion(retrievedPosts)
        } else {
            completion([Post]())
        }
    }
    
    /**
     Retrieves access token from get query result
     
     - Parameter json: response in JSON format
     - Parameter completion: processes result of the parse
     */
    func parse(json: JSON, completion: @escaping () -> Void) {
        if let access_token = json["access_token"].string {
            UserDefaults.standard.set(access_token, forKey: "accessToken")
        }
        completion()
    }
    
    /**
     Creates PostCategory instance from category in JSON format
     
     - Parameter category: category in JSON format
     - Returns: PostCategory instance
     */
    private func parseSingleCategory(category: JSON) -> PostCategory {
        return PostCategory(id: category["id"].intValue, name: category["name"].stringValue, slug: category["slug"].stringValue)
    }
    
    /**
     Creates Post instance from post in JSON format
     
     - Parameter post: post in JSON format
     - Returns: Post instance
     */
    private func parseSinglePost(post: JSON) -> Post {
        let thumbnail = Thumbnail(id: post["thumbnail"]["id"].intValue, image_url: post["thumbnail"]["image_url"].stringValue)
        let screenshot = Screenshot(smallImageUrl: post["screenshot_url"]["300px"].stringValue, bigImageUrl: post["screenshot_url"]["850px"].stringValue)
        return Post(category_id: post["category_id"].intValue, day: post["day"].stringValue, id: post["id"].intValue, name: post["name"].stringValue, tagline: post["tagline"].stringValue, upvotes: post["votes_count"].intValue, thumbnail: thumbnail, screenshot: screenshot, redirect_url: post["redirect_url"].stringValue)
    }
}
