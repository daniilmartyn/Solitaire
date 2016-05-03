//
//  SolitaireView.swift
//  Solitaire
//
//  Created by Daniil Sergeyevich Martyn on 4/30/16.
//  Copyright © 2016 Daniil Sergeyevich Martyn. All rights reserved.
//

import UIKit

var FAN_OFFSET : CGFloat = 0.0

class SolitaireView: UIView {

    var stockLayer : CALayer!
    var wasteLayer : CALayer!
    var foundationLayers : [CALayer]!   // four foundation layers
    var tableauLayers : [CALayer]!      // seven tableau layers
    
    var topZPosition : CGFloat = 0      // "highest" z-value of all card layers
    var cardToLayerDictionary : [Card : CardLayer]! // map card to it's layer
    
    var draggingCardLayer : CardLayer? = nil    // card layer dragged (nil => no drag)
    var draggingFan : [Card]? = nil             // fan of cards dragged
    var touchStartPoint: CGPoint = CGPointZero
    var touchStartLayerPosition : CGPoint = CGPointZero
    
    lazy var solitaire : Solitaire! = { // reference to model in app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.solitaire
    }()
    
    
    override func awakeFromNib() {
        self.layer.name = "background"
        
        stockLayer = CALayer()
        stockLayer.name = "stock"
        stockLayer.backgroundColor =
            UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.1, alpha: 0.3).CGColor
        self.layer.addSublayer(stockLayer)
        
        
        wasteLayer = CALayer()
        wasteLayer.name = "waste"
        wasteLayer.backgroundColor =
            UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.1, alpha: 0.3).CGColor
        self.layer.addSublayer(wasteLayer)
        
        foundationLayers = []
        for _ in 0 ..< 4 {
            let foundationLayer = CALayer()
            foundationLayer.name = "foundation"
            foundationLayer.backgroundColor =
                UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.1, alpha: 0.3).CGColor
            self.layer.addSublayer(foundationLayer)
            foundationLayers.append(foundationLayer)
        }
        
        tableauLayers = []
        for _ in 0 ..< 7 {
            let tableauLayer = CALayer()
            tableauLayer.name = "tableau"
            tableauLayer.backgroundColor =
                UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.1, alpha: 0.3).CGColor
            self.layer.addSublayer(tableauLayer)
            tableauLayers.append(tableauLayer)
        }
        
        let deck = Card.deck()  // deck of poker cards
        cardToLayerDictionary = [:]
        for card in deck {
            let cardLayer = CardLayer(card: card)
            cardLayer.name = "card"
            self.layer.addSublayer(cardLayer)
            cardToLayerDictionary[card] = cardLayer
        }
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        draggingCardLayer = nil     // deactivate any dragging
        layoutTableAndCards()
    }
    
    func layoutTableAndCards() {
        let width = bounds.size.width
        let height = bounds.size.height
        let portrait = width < height
        var boarder : CGFloat
        
        
        // XXXXXX SET UP BETTER margins/sizes based on height/width
        if portrait {
            boarder = 8.0     // space between cards/layers
            FAN_OFFSET = 0.2
            
        } else {
            boarder = 16.0
            FAN_OFFSET = 0.1
        }

        let ratio : CGFloat = 215/150   // will be used to calculate height of card
        
        let w = (width - 8*boarder)/7
        let h = w*ratio
        
        
        stockLayer.bounds = CGRectMake(0, 0, w, h)
        stockLayer.position = CGPointMake(boarder + w/2, boarder + h/2)
        
        wasteLayer.bounds = CGRectMake(0, 0, w, h)
        wasteLayer.position = CGPointMake(2*boarder + w + w/2, boarder + h/2)
        
        for i in 0 ..< 4 {
            foundationLayers[i].bounds = CGRectMake(0,0,w,h)
            foundationLayers[i].position = CGPointMake(
                3*w + 4*boarder + w * CGFloat(i) + boarder * CGFloat(i) + w/2,
                boarder + h/2)
        }
        
        for i in 0 ..< 7 {
            tableauLayers[i].bounds = CGRectMake(0,0,w,h)
            tableauLayers[i].position = CGPointMake(
                CGFloat(i)*w + boarder + boarder*CGFloat(i) + w/2,
                2*boarder + h + h/2)
        }
        
        layoutCards()
    }
    
    func layoutCards() {
        var z : CGFloat = 1.0
        
        let stock = solitaire.stock
        for card in stock {
            let cardLayer = cardToLayerDictionary[card]!
            cardLayer.frame = stockLayer.frame
            cardLayer.faceUp = solitaire.isCardFaceUp(card)
            cardLayer.zPosition = z++
        }
        
        //  layout the cards in waste and foundation stacks...
        
        let waste = solitaire.waste
        for card in waste {
            let cardLayer = cardToLayerDictionary[card]!
            cardLayer.frame = wasteLayer.frame
            cardLayer.faceUp = solitaire.isCardFaceUp(card)
            cardLayer.zPosition = z++
        }
        
        let foundation = solitaire.foundation
        for i in 0 ..< 4 {
            for card in foundation[i] {
                let cardLayer = cardToLayerDictionary[card]!
                cardLayer.frame = foundationLayers[i].frame
                cardLayer.faceUp = solitaire.isCardFaceUp(card)
                cardLayer.zPosition = z++
            }
        }
        
        let cardSize = stockLayer.bounds.size
        let fanOffset = FAN_OFFSET * cardSize.height
        for i in 0 ..< 7 {
            let tableau = solitaire.tableau[i]
            let tableauOrigin = tableauLayers[i].frame.origin
            var j : CGFloat = 0
            for card in tableau {
                let cardLayer = cardToLayerDictionary[card]!
                cardLayer.frame =
                    CGRectMake(tableauOrigin.x, tableauOrigin.y + j*fanOffset,
                        cardSize.width, cardSize.height)
                cardLayer.faceUp = solitaire.isCardFaceUp(card)
                cardLayer.zPosition = z++
                j++
            }
        }
        
        topZPosition = z    // remember "highest position"
    }
    
    func flipCard(card : Card, faceUp : Bool) {
        // implement this!!!! TODO
        
        // wait... i get it... maybe
    }
    
    func dealCardsFromStockToWaste() {
        if solitaire.canDealCard() {
            let card = solitaire.stock.last
            solitaire.didDealCard()
            
            let cardLayer = cardToLayerDictionary[card!]
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            cardLayer!.zPosition = topZPosition + 1
            CATransaction.commit()
            cardLayer!.position = wasteLayer.position
            
            layoutSublayersOfLayer(self.layer)      // XXXXXX Again... change this later perhaps
        }
    }
    
    func collectWasteCardsIntoStock() {
        solitaire.collectWasteCardsIntoStock()
        layoutSublayersOfLayer(self.layer)
    }
    
    func dragCardsToPosition(position : CGPoint, animate : Bool) {
        if !animate {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        draggingCardLayer!.position = position
        if let draggingFan = draggingFan {
            let off = FAN_OFFSET*draggingCardLayer!.bounds.size.height
            let n = draggingFan.count
            for i in 1 ..< n {
                let card = draggingFan[i]
                let cardLayer = cardToLayerDictionary[card]!
                cardLayer.position = CGPointMake(position.x, position.y + CGFloat(i)*off)
            }
        }
        if !animate {
            CATransaction.commit()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let touchPoint = touch.locationInView(self)
        let hitTestPoint = self.layer.convertPoint(touchPoint, toLayer: self.layer.superlayer)
        let layer = self.layer.hitTest(hitTestPoint)
        
        if let layer = layer {
            if layer.name == "card" {
                let cardLayer = layer as! CardLayer
                let card = cardLayer.card
                
                if solitaire.isCardFaceUp(card) {
                    if touch.tapCount > 1 {
                        for i in 0 ..< 4 {
                            if solitaire.canDropCard(card, onFoundation: i){
                                solitaire.didDropCard(card, onFoundation: i)
                                draggingCardLayer = cardLayer
                                dragCardsToPosition(foundationLayers[i].position, animate: true)
                                draggingCardLayer = nil

                                if solitaire.gameWon() {
                                    NSLog("YOU DID IT")
                                }
                                layoutSublayersOfLayer(self.layer)
                                // maybe use flipCard() to animate card flipping...
                                break
                            }
                        }
                    } else {
                    /// else initiate drag of card or stack of cards by setting draggingCardLayer,
                    /// and (possibly) draggingFan...
                        
                        if solitaire.waste.last == card {
                            cardLayer.zPosition = topZPosition + 1
                            touchStartPoint = touchPoint
                            touchStartLayerPosition = layer.position
                            draggingCardLayer = cardLayer
                        }
                        
                        for i in 0 ..< 7 {
                            if solitaire.tableau[i].last == card {
                                cardLayer.zPosition = topZPosition + 1
                                touchStartPoint = touchPoint
                                touchStartLayerPosition = layer.position
                                draggingCardLayer = cardLayer
                            } else {
                                if solitaire.tableau[i].contains(card) {
                                    if let dragFan = solitaire.fanBeginningWithCard(card) {
                                        
                                        for ii in 0 ..< dragFan.count {
                                            let fanCardLayer = cardToLayerDictionary[dragFan[ii]]
                                            fanCardLayer?.zPosition = topZPosition++
                                        }
                                        self.draggingFan = dragFan
                                        touchStartPoint = touchPoint
                                        touchStartLayerPosition = layer.position
                                        draggingCardLayer = cardLayer
                                    }
                                }
                            }
                        }
                        
                        for i in 0 ..< 4 {
                            if solitaire.foundation[i].last == card {
                                cardLayer.zPosition = topZPosition + 1
                                touchStartPoint = touchPoint
                                touchStartLayerPosition = layer.position
                                draggingCardLayer = cardLayer
                            }
                        }
                    
                    }
                } else if solitaire.canFlipCard(card) {
                    flipCard(card, faceUp: true)  // update model and view
                } else if solitaire.stock.last == card {
                    dealCardsFromStockToWaste()
                }
            } else if (layer.name == "stock") {
                collectWasteCardsIntoStock()
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = draggingCardLayer {
            let touch = touches.first
            let touchPoint = touch?.locationInView(self)
            let delta = CGPointMake(touchPoint!.x - touchStartPoint.x, touchPoint!.y - touchStartPoint.y)
            let pos = CGPointMake(touchStartLayerPosition.x + delta.x, touchStartLayerPosition.y + delta.y)
            dragCardsToPosition(pos, animate: false)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = draggingCardLayer {
             if draggingFan == nil {
                
                for i in 0 ..< 4 {
                    if CGRectIntersectsRect(draggingCardLayer!.frame, foundationLayers[i].frame) {
                        if solitaire.canDropCard(draggingCardLayer!.card, onFoundation: i){
                            solitaire.didDropCard(draggingCardLayer!.card, onFoundation: i)
                            
                            if solitaire.gameWon() {
                                NSLog("YOU DID IT!")
                            }
                            // maybe use flipCard() to animate card flipping...
                            break
                        }
                    }
                }
                
                for i in 0 ..< 7 {
                    
                    if solitaire.tableau[i].isEmpty {
                        if CGRectIntersectsRect(draggingCardLayer!.frame, tableauLayers[i].frame) {
                            if solitaire.canDropCard(draggingCardLayer!.card, onTableau: i) {
                                solitaire.didDropCard(draggingCardLayer!.card, onTableau: i)
                            }
                        }
                    }else {
                        if let whereToDrop = cardToLayerDictionary[solitaire.tableau[i].last!]{
                            if CGRectIntersectsRect(draggingCardLayer!.frame, whereToDrop.frame) {
                                if solitaire.canDropCard(draggingCardLayer!.card, onTableau: i) {
                                    solitaire.didDropCard(draggingCardLayer!.card, onTableau: i)
                                }
                            }
                        }
                    }
                }
                
                layoutSublayersOfLayer(self.layer)
             } else { // fan of cards (can only drop on tableau stack)
                
                for i in 0 ..< 7 {
                    
                    if solitaire.tableau[i].isEmpty {
                        if let firstCardFanLayer = cardToLayerDictionary[draggingFan!.first!]{
                            if CGRectIntersectsRect(firstCardFanLayer.frame, tableauLayers[i].frame) {
                                if solitaire.canDropFan(draggingFan!, onTableau: i) {
                                    solitaire.didDropFan(draggingFan!, onTableau: i)
                                }
                            }
                        }
                    }else {
                        if let whereToDrop = cardToLayerDictionary[solitaire.tableau[i].last!]{
                            if let firstCardFanLayer = cardToLayerDictionary[draggingFan!.first!]{
                                if CGRectIntersectsRect(firstCardFanLayer.frame, whereToDrop.frame) {
                                    if solitaire.canDropFan(draggingFan!, onTableau: i) {
                                        solitaire.didDropFan(draggingFan!, onTableau: i)
                                    }
                                }
                            }
                        }
                    }
                }
                
                layoutSublayersOfLayer(self.layer)
            }
            draggingCardLayer = nil
            draggingFan = nil
        }
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
       // <#code#>
    }












}