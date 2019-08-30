//
//  GiphyPresenterDelegate.swift
//  GiphyTest
//
//  Created by Ever Uribe on 8/27/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import Foundation
import UIKit

protocol GiphyPresenterDelegate {
    func handleGiphySelected(gifImage: UIImage, url: URL)
}
