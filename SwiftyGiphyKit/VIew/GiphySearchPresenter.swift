//
//  GiphySearchPresenter.swift
//  GiphyTest
//
//  Created by Ever Uribe on 8/23/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit


var giphyResults: [UIImage] = []

class GiphySearchPresenter: NSObject {
    var delegate: GiphyPresenterDelegate?
    
    var giphyView: GiphySearchView!
    
    ///Reference to top constraint of giphyView for pan gesture sliding
    var topConstraint: NSLayoutConstraint!
    
    ///Reference to key window
    var keyWindow: UIWindow!
    
    ///Opens the giphy view.
    func openGiphyView() {
        if let keyWindowRef: UIWindow = UIApplication.shared.keyWindow {
            keyWindow = keyWindowRef
            
            giphyView = GiphySearchView(presenter: self)
            giphyView.layer.cornerRadius = 10
            giphyView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            giphyView.clipsToBounds = true
            
            let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            giphyView.addGestureRecognizer(panGesture)
            
            keyWindow.addSubview(giphyView)
            
            //x,y,w,h
            giphyView.translatesAutoresizingMaskIntoConstraints = false
            
            giphyView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor).isActive = true
            giphyView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor).isActive = true
            giphyView.heightAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.heightAnchor, constant: keyWindow.safeAreaInsets.bottom).isActive = true
            topConstraint = giphyView.topAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.topAnchor, constant: keyWindow.frame.height)
            topConstraint.isActive = true
            
            //Establish start point
            keyWindow.layoutIfNeeded()
            
            //Animate view into display
            topConstraint.constant = 0
            UIView.animate(withDuration: 0.55, animations: {
                self.keyWindow.layoutIfNeeded()
            })
        }
    }
    
    ///Closes the giphy view
    func closeGiphyView() {
        topConstraint.constant = keyWindow.frame.height
        
        UIView.animate(withDuration: 0.25, animations: {
            self.keyWindow.layoutIfNeeded()
        }, completion: { completion in
            self.giphyView.removeFromSuperview()
            self.giphyView = nil
            self.topConstraint = nil
            self.keyWindow = nil
        })
    }
    
    
    ///Handles dragging to close the giphy view.
    @objc func handlePanGesture(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: keyWindow)
        if translation.y >= 0 {
            slideViewTo(location: translation.y)
        } else if translation.y < 0 && topConstraint.constant != 0 {
            slideViewTo(location: 0)
        }
        
        if pan.state == .began {
            if giphyView.searchBar.text!.isEmpty {
                giphyView.cancelSearch()
            } else {
                giphyView.searchBar.endEditing(true)
            }
        } else if pan.state == .ended {
            slideViewFrom(finalLocation: translation.y)
        }
    }
    
    ///Handles movement of giphy view as it's sliding.
    func slideViewTo(location: CGFloat){
        topConstraint.constant = location
        keyWindow.layoutIfNeeded()
    }
    
    ///Handles final action on giphy view after sliding is completed: close view or return to original position.
    func slideViewFrom(finalLocation: CGFloat){
        giphyView.isUserInteractionEnabled = false
        if finalLocation > 60 {
            closeGiphyView()
        } else {
            topConstraint.constant = 0
            
            UIView.animate(withDuration: 0.25, animations: {
                self.keyWindow.layoutIfNeeded()
            }, completion: { completion in
                self.giphyView.isUserInteractionEnabled = true
            })
        }
    }
}
