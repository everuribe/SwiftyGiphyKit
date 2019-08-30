//
//  ViewController.swift
//  SwiftyGiphyKitExamples
//
//  Created by Ever Uribe on 8/29/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GiphyPresenterDelegate {
    let button : UIButton = {
        let button: UIButton = UIButton()
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(handleButtonAction), for: .touchUpInside)
        button.setTitle("Add GIF Above", for: .normal)
        button.clipsToBounds = true
        return button
    }()
    
    let presenter: GiphySearchPresenter = GiphySearchPresenter()
    
    let imageView = GIFLayeredImageView(image: UIImage(named: "party"), isUserEditable: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Set presenter delegate
        presenter.delegate = self
        
        let swiftyGiphyKitImage: UIImageView = UIImageView(gifURL: URL(string:  "https://media.giphy.com/media/kfLrsvExow4ixZ7ZLT/giphy.gif")!)
        swiftyGiphyKitImage.contentMode = .scaleAspectFit
        self.view.addSubview(swiftyGiphyKitImage)
        
        view.addSubview(button)
        
        imageView.frame = CGRect(x: 0, y: 140, width: self.view.frame.width, height: 300)
        view.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        swiftyGiphyKitImage.translatesAutoresizingMaskIntoConstraints = false
        
        
        imageView.topAnchor.constraint(equalTo: swiftyGiphyKitImage.bottomAnchor, constant: 50).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.4).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        button.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 220).isActive = true
        button.layer.cornerRadius = 30
        
        swiftyGiphyKitImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        swiftyGiphyKitImage.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        swiftyGiphyKitImage.heightAnchor.constraint(equalTo: swiftyGiphyKitImage.widthAnchor, multiplier: 0.27).isActive = true
        swiftyGiphyKitImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        swiftyGiphyKitImage.layer.cornerRadius = 10
        swiftyGiphyKitImage.clipsToBounds = true
    }
    
    @objc func handleButtonAction() {
        presenter.openGiphyView()
    }
    
    func handleGiphySelected(gifImage: UIImage, url: URL) {
        imageView.addGif(gifImage: gifImage, url: url)
    }
}
