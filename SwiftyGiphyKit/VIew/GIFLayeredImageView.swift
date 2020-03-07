//
//  GIFLayeredImageView.swift
//  GiphyTest
//
//  Created by Ever Uribe on 8/28/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import Foundation
import UIKit

///User interactable image view with GIFs layered onto image. 
///- clipsToBounds = true
///- contentMode = .scaleAspectFill
public class GIFLayeredImageView: UIImageView, UIGestureRecognizerDelegate {
    
    public var gifArray: [UIImageView] = []
    public var gifInfoArray: [GIFDisplayInfo] = []
    
    ///Used to indicate gif has been selected with some gesture.
    private var selectedGif: UIImageView?
    ///Used to save transform of gif before it was selected.
    private var originalTransform: CGAffineTransform!
    ///Used to save transform of gif before it was dragged under removeBin.
    private var transformBeforeTrashed: CGAffineTransform!
    
    ///UI feature indicating to user ability to delete gif as it's being dragged.
    private let removeBin: UIImageView = UIImageView(image: trashIcon)
    ///Determines whether removeBin has already been scaled.
    private var removeBinScaled: Bool = false
    
    private static var trashIcon: UIImage {
        let bundle = Bundle(for: self)
        let image: UIImage = UIImage(named: "trash", in: bundle, compatibleWith: nil)!
        return image
    }
    
    public init(image: UIImage?, isUserEditable: Bool) {
        super.init(image: image)
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        self.isUserInteractionEnabled = isUserEditable
        
        removeBin.alpha = 0
        addSubview(removeBin)
        
        setConstraints()
        addGestures()
    }
    
    private func setConstraints() {
        removeBin.translatesAutoresizingMaskIntoConstraints = false
        removeBin.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        removeBin.centerYAnchor.constraint(equalTo: self.bottomAnchor, constant: -40).isActive = true
        removeBin.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        removeBin.heightAnchor.constraint(equalTo: removeBin.widthAnchor).isActive = true
    }
    
    private func addGestures() {
        let pinchGesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        pinchGesture.delegate = self
        self.addGestureRecognizer(pinchGesture)
        
        let rotateGesture: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotateGesture))
        rotateGesture.delegate = self
        self.addGestureRecognizer(rotateGesture)
        
        let dragGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        dragGesture.delegate = self
        self.addGestureRecognizer(dragGesture)
    }
    
    //Override bounds to listen for changes and adjust gifs accordingly
    override public var bounds: CGRect {
        didSet {
            for (index, gif) in gifArray.enumerated() {
                setGifView(gif: gif, gifInfo: gifInfoArray[index])
            }
        }
    }
    
    ///Load gifs from a GIFDisplayInfo array
    public func loadGifsFrom(info: [GIFDisplayInfo]) {
        for gifInfo in info {
            let newGif: UIImageView = UIImageView()
            
            setGifView(gif: newGif, gifInfo: gifInfo)
            
            //Load gif
            let url: URL = URL(string: gifInfo.urlString)!
            newGif.setGifFromURL(url)
            
            //Add gif
            self.insertSubview(newGif, belowSubview: removeBin)
            gifArray.append(newGif)
        }
        gifInfoArray = info
    }
    
    private func setGifView(gif: UIImageView, gifInfo: GIFDisplayInfo){
        //Set center, scale, and rotation
        let centerX: CGFloat = CGFloat(gifInfo.universalLocationX)*self.frame.width
        let centerY: CGFloat = CGFloat(gifInfo.universalLocationY)*self.frame.height
        let scale: CGFloat = CGFloat(gifInfo.scale)
        let rotation: CGFloat = CGFloat(gifInfo.rotation)
        
        //Determine frame of GIF
        let size: CGFloat = self.frame.width/3.75
        gif.frame.size = CGSize(width: size, height: size)
        gif.center = CGPoint(x: centerX, y: centerY)

        gif.transform = gif.transform.scaledBy(x: scale, y: scale)
        gif.transform = gif.transform.rotated(by: rotation)
    }
    
    public func clearAllGifs(){
        for gif in gifArray {
            gif.removeFromSuperview()
        }
        gifArray.removeAll()
        gifInfoArray.removeAll()
    }
    
    ///Add gif to view and to database
    public func addGif(gifImage: UIImage, url: URL) {
        let newGif: UIImageView = UIImageView(gifImage: gifImage)
        let size: CGFloat = self.frame.width/3.75
        newGif.frame.size = CGSize(width: size, height: size)
        newGif.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        self.insertSubview(newGif, belowSubview: removeBin)
        gifArray.append(newGif)
        
        let universalLocationX: Double = Double(newGif.center.x/self.frame.width)
        let universalLocationY: Double = Double(newGif.center.y/self.frame.height)
        let gifInfo = GIFDisplayInfo(urlString: url.absoluteString, scale: 1, universalLocationX: universalLocationX, universalLocationY: universalLocationY, rotation: 0)
        gifInfoArray.append(gifInfo)
    }
    
    ///Remove gif from view and from gifArray and remove it's info from gifInfoArray
    private func removeGif(gif: UIImageView){
        gif.removeFromSuperview()
        
        if let index: Int = gifArray.firstIndex(of: gif) {
            gifArray.remove(at: index)
            gifInfoArray.remove(at: index)
        }
    }
    
    ///Calculate and save all gif info including rotation, scale, and location.
    public func saveGifInfo() {
        for (index, gif) in gifArray.enumerated() {
            let transform: CGAffineTransform = gif.transform
            let rotation: Double = Double(atan2(transform.b, transform.a))
            let scale: Double = Double(sqrt(transform.a * transform.a + transform.c * transform.c))
            let locationX: Double = Double(gif.center.x/self.frame.width)
            let locationY: Double = Double(gif.center.y/self.frame.height)
            
            gifInfoArray[index].rotation = rotation
            gifInfoArray[index].scale = scale
            gifInfoArray[index].universalLocationX = locationX
            gifInfoArray[index].universalLocationY = locationY
        }
    }
    
    //MARK: GESTURES
    
    @objc private func handlePinchGesture(recognizer: UIPinchGestureRecognizer){
        if recognizer.state == .began {
            let location: CGPoint = recognizer.location(in: recognizer.view)
            
            for gif in gifArray {
                if gif.frame.contains(location) {
                    selectedGif = gif
                    originalTransform = gif.transform
                }
            }
        } else if recognizer.state == .changed {
            if let gif: UIImageView = selectedGif, let ogTransform: CGAffineTransform = originalTransform {
                let scale: CGFloat = recognizer.scale
                gif.transform =  ogTransform.scaledBy(x: scale, y: scale)
            }
        } else if recognizer.state == .ended {
            selectedGif = nil
        }
    }
    
    @objc private func handleRotateGesture(recognizer: UIRotationGestureRecognizer){
        if recognizer.state == .began {
            let location = recognizer.location(in: self)
            for gif in gifArray {
                if gif.frame.contains(location) {
                    selectedGif = gif
                    originalTransform = gif.transform
                }
            }
        } else if recognizer.state == .changed {
            if let gif: UIImageView = selectedGif {
                let rotation: CGFloat = recognizer.rotation
                gif.transform =  originalTransform.rotated(by: rotation)
            }
        } else if recognizer.state == .ended {
            selectedGif = nil
        }
    }
    
    @objc private func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            let location = recognizer.location(in: self)
            for gif in gifArray {
                if gif.frame.contains(location) {
                    selectedGif = gif
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.removeBin.alpha = 1
                    })
                }
            }
        } else if recognizer.state == .changed {
            if let gif: UIImageView = selectedGif {
                let translation: CGPoint = recognizer.translation(in: self)
                gif.center = CGPoint(x: gif.center.x + translation.x, y: gif.center.y + translation.y)
                recognizer.setTranslation(.zero, in: self)
                
                //If dragged under removeBin, scale. Else, scale back to size before being dragged under removeBin.
                if removeBin.frame.contains(gif.center){
                    if !removeBinScaled {
                        removeBinScaled = true
                        
                        //Register haptic feedback
                        let impact: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator()
                        impact.impactOccurred()
                        
                        //Determine shrink transform for gif
                        let transform: CGAffineTransform = gif.transform
                        let currentScale: CGFloat = sqrt(transform.a * transform.a + transform.c * transform.c)
                        let newScale: CGFloat = 0.432/currentScale
                        //formula for constant 0.432 = removeBin.width*1.5/1.3*(self.frame.width/3.75) where 1.5 is removeBin scale, 1.3 is margin of newScale, and self.frame.width/3.75 is original size of GIF
                        
                        //Save transform to revert if dragged away from trash before drag ends.
                        transformBeforeTrashed = gif.transform
                        
                        UIView.animate(withDuration: 0.25, animations: {
                            self.removeBin.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
                            self.selectedGif!.transform = self.transformBeforeTrashed.scaledBy(x: newScale, y: newScale)
                        })
                    }
                } else {
                    if removeBinScaled {
                        UIView.animate(withDuration: 0.25, animations: {
                            self.removeBin.transform = CGAffineTransform.identity
                            gif.transform = self.transformBeforeTrashed
                        }, completion: {completion in
                            self.transformBeforeTrashed = nil
                            self.removeBinScaled = false
                        })
                    }
                }
            }
        } else if recognizer.state == .ended {
            if let gif: UIImageView = selectedGif {
                //Remove gif as necessary
                if removeBin.frame.contains(gif.center) {
                    removeGif(gif: gif)
                }
                selectedGif = nil
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                self.removeBin.alpha = 0
            })
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
