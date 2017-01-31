//
//  PostModel.swift
//  TestTest
//
//  Created by Булат Галиев on 30.01.17.
//  Copyright © 2017 Булат Галиев. All rights reserved.
//

import Foundation

struct PostCategory {
    let id: Int
    let name: String
    let slug: String
}

struct Post {
    let category_id: Int
    let day: String
    var formattedDate: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let dateFromString = dateFormatter.date(from: day) else {
                return ""
            }
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "EEEE, MMM d"
            
            return dateFormatter2.string(from: dateFromString)
        }
    }
    let id: Int
    let name: String
    let tagline: String
    let upvotes: Int
    let thumbnail: Thumbnail
    let screenshot: Screenshot
    let redirect_url: String
}

extension Post: Equatable {}

func ==(lhs: Post, rhs: Post) -> Bool {
    return lhs.id == rhs.id
}

struct Thumbnail {
    let id: Int
    let image_url: String
}

func ==(lhs: Thumbnail, rhs: Thumbnail) -> Bool {
    return lhs.id == rhs.id && lhs.image_url == rhs.image_url
}

struct Screenshot {
    let smallImageUrl: String
    let bigImageUrl: String
}

func ==(lhs: Screenshot, rhs: Screenshot) -> Bool {
    return lhs.smallImageUrl == rhs.smallImageUrl && lhs.bigImageUrl == rhs.bigImageUrl
}
