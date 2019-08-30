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
    private let removeBin: UIImageView = UIImageView(image: UIImage(named: "trash"))
    ///Determines whether removeBin has already been scaled.
    private var removeBinScaled: Bool = false
    
    init(image: UIImage?, isUserEditable: Bool) {
        super.init(image: image)
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        
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
    
    ///Add gif to view and to database
    public func addGif(gifImage: UIImage, url: URL) {
        let newGif: UIImageView = UIImageView(gifImage: gifImage)
        let size: CGFloat = self.frame.width/3.75
        newGif.frame.size = CGSize(width: size, height: size)
        newGif.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        self.insertSubview(newGif, belowSubview: removeBin)
        gifArray.append(newGif)
        
        let universalLocation: CGPoint = CGPoint(x: newGif.center.x/self.frame.width, y: newGif.center.y/self.frame.height)
        let gifInfo = GIFDisplayInfo(url: url, scale: 1, universalLocation: universalLocation, rotation: 0)
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
            let rotation: CGFloat = atan2(transform.b, transform.a)
            let scale: CGFloat = sqrt(transform.a * transform.a + transform.c * transform.c)
            let location: CGPoint = CGPoint(x: gif.center.x/self.frame.width, y: gif.center.y/self.frame.height)
            
            gifInfoArray[index].rotation = rotation
            gifInfoArray[index].scale = scale
            gifInfoArray[index].universalLocation = location
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
            if let gif: UIImageView = selectedGif {
                let scale: CGFloat = recognizer.scale
                gif.transform =  originalTransform.scaledBy(x: scale, y: scale)
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
