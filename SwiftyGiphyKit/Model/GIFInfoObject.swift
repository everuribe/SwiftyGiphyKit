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
    var url: URL
    ///Scale transform.
    var scale: CGFloat
    ///This is the center location divided by the width/height (ie x/width, y/height).
    var universalLocation: CGPoint
    ///Rotation transform in radians.
    var rotation: CGFloat
    
    ///Converts the GIFDisplayInfo struct object to a dictionary, useful for storing data as keyed values (ie uploading info to a keyed cloud storage).
    public func convertToDictObject() -> [String: Any] {
        return ["url": url, "scale": scale, "universalLocation": universalLocation, "rotation": rotation]
    }
}
