//
//  JSONObjects.swift
//  GiphyTest
//
//  Created by Ever Uribe on 8/23/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import Foundation

///Raw server response using Giphy API:
struct RawServerResponse: Decodable {
    
    var data: [GIFObject]
    
    struct GIFObject: Decodable {
        var images: ImagesInfo
    }
    
    struct ImagesInfo: Decodable {
        var fixed_width: FixedWidthImageInfo
    }
    
    struct FixedWidthImageInfo: Decodable {
        var url: String
    }
}

///Object decoding Giphy raw response into an array of GIF urls. 
struct GIFUrlArrayObject: Decodable {
    var urls: [URL]
    
    init(from decoder: Decoder) throws {
        let rawResponse = try RawServerResponse(from: decoder)
        
        urls = []
        for object in rawResponse.data {
            if let gifUrl: URL = URL(string: object.images.fixed_width.url) {
                urls.append(gifUrl)
            }
        }
    }
}
