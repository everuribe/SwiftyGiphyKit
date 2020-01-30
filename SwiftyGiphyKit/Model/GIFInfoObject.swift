//
//  GIFInfoObject.swift
//  GiphyTest
//
//  Created by Ever Uribe on 8/28/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

public struct GIFDisplayInfo: Codable {
    ///Link to GIF.
    var urlString: String
    ///Scale transform.
    var scale: Double
    ///This is the center X location divided by the width
    var universalLocationX: Double
    
    ///This is the center Y location divuded by the height
    var universalLocationY: Double
    
    ///Rotation transform in radians.
    var rotation: Double
    
    ///Converts the GIFDisplayInfo struct object to a dictionary, useful for storing data as keyed values (ie uploading info to a keyed cloud storage).
    public func convertToDictObject() -> [String: Any] {
        return ["url": urlString, "scale": scale, "universalLocationX": universalLocationX, "universalLocationY": universalLocationY, "rotation": rotation]
    }
}
