//
//  CardLayer.swift
//  Solitaire
//
//  Created by Daniil Sergeyevich Martyn on 4/30/16.
//  Copyright © 2016 Daniil Sergeyevich Martyn. All rights reserved.
//

import UIKit

class CardLayer: CALayer {

    let card : Card
    var faceUp : Bool {
        didSet {
            if faceUp != oldValue {
                let image = faceUp ? frontImage : CardLayer.backImage
                self.contents = image?.CGImage
            }
        }
    }
    var frontImage : UIImage
    static let backImage = UIImage(named: "back-blue-150-1.png")
    
    init(card : Card) {
        self.card = card
        faceUp = true
        frontImage = UIImage()
        super.init()
        frontImage = imageForCard(card)  // load associated image from main bundle
        self.contents = frontImage.CGImage
        self.contentsGravity = kCAGravityResizeAspect
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imageForCard(card : Card) -> UIImage {
        
        let suits = ["spades", "clubs", "diamonds", "hearts"]
        let ranks = [
            "",
            "a", "2", "3", "4", "5", "6", "7",
            "8", "9", "10", "j", "q", "k"]
        
        let cardRank : Int = Int(card.rank)
        let cardSuit : Int = Int(card.suit.rawValue)
        
        let imageName = "\(suits[cardSuit])-\(ranks[cardRank])-150"
        return UIImage(named: imageName)!
    }

}
