//
//  TestTestTests.swift
//  TestTestTests
//
//  Created by Булат Галиев on 25.01.17.
//  Copyright © 2017 Булат Галиев. All rights reserved.
//

import XCTest
@testable import TestTest
import SwiftyJSON

class TestTestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResponseParserAuthorize() {
        ResponseParser.sharedInstance.authorize {(error) in
            XCTAssert(error == nil)
            XCTAssert(UserDefaults.standard.string(forKey: "accessToken") != nil)
        }
    }
    
    func testResponseParserGetCategories() {
        ResponseParser.sharedInstance.getCategories {(postCategories, error) in
            XCTAssert(error == nil)
            XCTAssert(postCategories[0].slug == "tech")
            XCTAssert(postCategories[1].slug == "games")
            XCTAssert(postCategories[2].slug == "podcasts")
            XCTAssert(postCategories[3].slug == "books")
        }
    }
    
    func testResponseParserGetPosts() {
        ResponseParser.sharedInstance.getPosts(completion: {(posts, error) in
            XCTAssert(error == nil)
            if posts.count > 0 {
                for post in posts {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    XCTAssert(dateFormatter.date(from: post.day) == Date())
                }
            }
        }, category: PostCategory(id: 0, name: "Tech", slug: "tech"), days_ago: 0)
    }
    
    func testResponseParserParseCategories() {
        let json: JSON = [
            "categories" : [
                [
                    "id" : 1,
                    "slug" : "tech",
                    "name" : "Tech",
                    "color" : "#da552f",
                    "item_name" : "product"
                ],
                [
                    "id" : 2,
                    "slug" : "category-2",
                    "name" : "Category 2",
                    "color" : "#da552f",
                    "item_name" : "product"
                ]
            ]
        ]
        ResponseParser.sharedInstance.parse(json: json, error: nil, completion: {(postCategories:[PostCategory], error) -> () in
            XCTAssert(error == nil)
            XCTAssert(postCategories.count == 2)
            XCTAssert(postCategories[0].id == 1 && postCategories[0].slug == "tech" && postCategories[0].name == "Tech")
            XCTAssert(postCategories[1].id == 2 && postCategories[1].slug == "category-2" && postCategories[1].name == "Category 2")
        })
    }
    
    // Compares posts for equality comparing each field
    func comparePosts(lhs: Post, rhs: Post) -> Bool {
        return lhs.category_id == rhs.category_id &&
            lhs.day == rhs.day &&
            lhs.name == rhs.name &&
            lhs.id == rhs.id &&
            lhs.redirect_url == rhs.redirect_url &&
            lhs.upvotes == rhs.upvotes &&
            lhs.thumbnail == rhs.thumbnail &&
            lhs.screenshot == rhs.screenshot
    }
    
    func testResponseParserParsePosts() {
        let json: JSON = [
            "posts" : [
                [
                    "category_id" : 1,
                    "day" : "2017-01-02",
                    "id" : 1,
                    "name" : "Awesome Idea #23",
                    "product_state" : "default",
                    "tagline" : "Great new search engine",
                    "comments_count" : 0,
                    "created_at" : "2017-01-02T01:17:42.847-08:00",
                    "current_user" : [],
                    "discussion_url" : "http://www.producthunt.com/posts/awesome-idea-23?utm_campaign=producthunt-api&utm_medium=api&utm_source=Application%3A+Awesome+Oauth+App+%2319+%28ID%3A+1%29",
                    "featured" : true,
                    "maker_inside" : false,
                    "makers" : [],
                    "platforms" : [],
                    "topics" : [],
                    "redirect_url" : "http://www.producthunt.com/r/95a1694b3c4c8c/1?app_id=1",
                    "screenshot_url" : [
                        "300px" : "http://placehold.it/850x850.png",
                        "850px" : "http://placehold.it/850x850.png"
                    ],
                    "thumbnail" : [
                        "id" : 1,
                        "media_type" : "image",
                        "image_url" : "https://ph-files.imgix.net/8b63e712-c574-47d9-b022-0faa1d00ebfc?auto=format&fit=crop&h=570&w=430",
                        "metadata" : []
                    ],
                    "votes_count" : 1
                ]
                ]
        ]
        ResponseParser.sharedInstance.parse(json: json, error: nil, completion: {(posts:[Post], error) -> () in
            XCTAssert(error == nil)
            XCTAssert(posts.count == 1)
            let correctPost = Post(category_id: 1, day: "2017-01-02", id: 1, name: "Awesome Idea #23", tagline: "Great new search engine", upvotes: 1, thumbnail: Thumbnail(id: 1, image_url: "https://ph-files.imgix.net/8b63e712-c574-47d9-b022-0faa1d00ebfc?auto=format&fit=crop&h=570&w=430"), screenshot: Screenshot(smallImageUrl: "http://placehold.it/850x850.png", bigImageUrl: "http://placehold.it/850x850.png"), redirect_url: "http://www.producthunt.com/r/95a1694b3c4c8c/1?app_id=1")
            XCTAssert(self.comparePosts(lhs: posts[0], rhs: correctPost))
        })
    }
}
