//
//  GIFInfoObject.swift
//  GiphyTest
//
//  Created by Ever Uribe on 8/28/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import Foundation
import UIKit

public struct GIFDisplayInfo {
    ///Link to GIF.
    var url: URL
    ///Scale transform.
    var scale: CGFloat
    ///This is the center location divided by the width/height (ie x/width, y/height).
    var universalLocation: CGPoint
    ///Rotation transform in radians.
    var rotation: CGFloat
}
