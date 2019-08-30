//
//  MainSearchBar.swift
//  CornerBlocRefactor
//
//  Created by Ever Uribe on 5/24/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//
import UIKit

class SearchBar: UITextField {
    
    private let iconView = UIImageView(image: UIImage(named: "search")!.withRenderingMode(.alwaysTemplate))
    
    ///Padding of leftView to leftAnchor
    private let padding: CGFloat = 8
    
    ///Size of the search icon image
    private let size: CGFloat = 15
    
    init(textColor: UIColor = .white, placeholderText: NSAttributedString, backgroundColor: UIColor = .clear) {
        super.init(frame: .zero)
        
        attributedPlaceholder = placeholderText
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.iconView.tintColor = textColor
        font = UIFont.systemFont(ofSize: 16.0)
        
        //Create an outer view with padding and then add the left view image for the search bar
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: padding + size + padding, height: size) )
        iconView.frame = CGRect(x: padding, y: 0, width: size, height: size)
        outerView.addSubview(iconView)
        leftView = outerView
        leftViewMode = UITextField.ViewMode.always
        
        clearButtonMode = .whileEditing
        
        //Set clear button to custom white image
        if let clearButton: UIButton = value(forKey: "clearButton") as? UIButton {
            let clearImage: UIImage = UIImage(named: "clear")!
            clearButton.setImage(clearImage, for: .normal)
            
            let clearImageSelected: UIImage = UIImage(named: "clear_selected")!
            clearButton.setImage(clearImageSelected, for: .selected)
        }
    }
    
    // MARK: VIEW ANIMATION
    ///Function that animates search bar subviews when search is toggled.
    func toggleSearch(didBeganEditing: Bool) {
        if didBeganEditing {
            UIView.animate(withDuration: 0.25, animations: {
                self.leftView?.subviews[0].transform = (self.leftView?.subviews[0].transform.scaledBy(x: 4/3, y: 4/3))!
            })
        }
        else {
            UIView.animate(withDuration: 0.25, animations: {
                self.leftView?.subviews[0].transform = .identity
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


