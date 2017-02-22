//
//  SolitaireView.swift
//  Solitaire
//
//  Created by Daniil Sergeyevich Martyn on 4/30/16.
//  Copyright © 2016 Daniil Sergeyevich Martyn. All rights reserved.
//

import UIKit

var FAN_OFFSET : CGFloat = 0.2

class SolitaireView: UIView {

    var stockLayer : CALayer!
    var wasteLayer : CALayer!
    var foundationLayers : [CALayer]!   // four foundation layers
    var tableauLayers : [CALayer]!      // seven tableau layers
    
    var topZPosition : CGFloat = 0      // "highest" z-value of all card layers
    var cardToLayerDictionary : [Card : CardLayer]! // map card to it's layer
    
    var draggingCardLayer : CardLayer? = nil    // card layer dragged (nil => no drag)
    var draggingFan : [Card]? = nil             // fan of cards dragged
    var touchStartPoint: CGPoint = CGPoint.zero
    var touchStartLayerPosition : CGPoint = CGPoint.zero
    
    var isWin : Bool = false
    
    lazy var solitaire : Solitaire! = { // reference to model in app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.solitaire
    }()
    
    
    override func awakeFromNib() {
        self.layer.name = "background"
        
        stockLayer = CALayer()
        stockLayer.name = "stock"
        stockLayer.backgroundColor =
            UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.1, alpha: 0.3).cgColor
        self.layer.addSublayer(stockLayer)
        
        
        wasteLayer = CALayer()
        wasteLayer.name = "waste"
        wasteLayer.backgroundColor =
            UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.1, alpha: 0.3).cgColor
        self.layer.addSublayer(wasteLayer)
        
        foundationLayers = []
        for _ in 0 ..< 4 {
            let foundationLayer = CALayer()
            foundationLayer.name = "foundation"
            foundationLayer.backgroundColor =
                UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.1, alpha: 0.3).cgColor
            self.layer.addSublayer(foundationLayer)
            foundationLayers.append(foundationLayer)
        }
        
        tableauLayers = []
        for _ in 0 ..< 7 {
            let tableauLayer = CALayer()
            tableauLayer.name = "tableau"
            tableauLayer.backgroundColor =
                UIColor(colorLiteralRed: 0.0, green: 0.5, blue: 0.1, alpha: 0.3).cgColor
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
    
     override func layoutSublayers(of layer: CALayer) {
        draggingCardLayer = nil     // deactivate any dragging
        layoutTableAndCards()
    }
    
    func layoutTableAndCards() {
        
        if isWin {
            party()
            return
        }
        
        let width = bounds.size.width
        let height = bounds.size.height
        let portrait = width < height
        var m : CGFloat       // left/right between edges of screen and cards
        var t : CGFloat         // top/bottom border
        var d : CGFloat     // horizontal gap between cards
        var s : CGFloat     // gap between tableau and foundation/stock/waste
        
        var w : CGFloat
        var h : CGFloat
        
        let ratio : CGFloat = 215/150   // will be used to calculate height/width of card
        
        if portrait {
            FAN_OFFSET = 0.2
            m = 8.0
            t = 8.0
            d = 4.0
            s = 16.0
            w = (width - 2*m - 6*d)/7
            h = w*ratio
            
            
        } else {
            FAN_OFFSET = 0.15
            m = 64.0
            t = 8.0
            s = 12.0
            h = (height - 2*t - s)/4.7 //  2 full height + 2.7 worth of fanned cards
            w = h / ratio
            d = (width - 2*m - 7*w)/6
        }
        
        stockLayer.bounds = CGRect(x: 0, y: 0, width: w, height: h)
        stockLayer.position = CGPoint(x: m + w/2, y: t + h/2)
        
        wasteLayer.bounds = CGRect(x: 0, y: 0, width: w, height: h)
        wasteLayer.position = CGPoint(x: m + d + w + w/2, y: t + h/2)
        
        for i in 0 ..< 4 {
            foundationLayers[i].bounds = CGRect(x: 0,y: 0,width: w,height: h)
            foundationLayers[i].position = CGPoint(
                x: 3*w + m + 3*d + w * CGFloat(i) + d * CGFloat(i) + w/2,
                y: t + h/2)
        }
        
        for i in 0 ..< 7 {
            tableauLayers[i].bounds = CGRect(x: 0,y: 0,width: w,height: h)
            tableauLayers[i].position = CGPoint(
                x: CGFloat(i)*w + m + d*CGFloat(i) + w/2,
                y: t + s + h + h/2)
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
            z += 1
            cardLayer.zPosition = z
        }
        
        //  layout the cards in waste and foundation stacks...
        
        let waste = solitaire.waste
        for card in waste {
            let cardLayer = cardToLayerDictionary[card]!
            cardLayer.frame = wasteLayer.frame
            cardLayer.faceUp = solitaire.isCardFaceUp(card)
             z += 1
            cardLayer.zPosition = z
        }
        
        let foundation = solitaire.foundation
        for i in 0 ..< 4 {
            for card in foundation[i] {
                let cardLayer = cardToLayerDictionary[card]!
                cardLayer.frame = foundationLayers[i].frame
                cardLayer.faceUp = solitaire.isCardFaceUp(card)
                z += 1
                cardLayer.zPosition = z
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
                    CGRect(x: tableauOrigin.x, y: tableauOrigin.y + j*fanOffset,
                        width: cardSize.width, height: cardSize.height)
                cardLayer.faceUp = solitaire.isCardFaceUp(card)
                z += 1
                cardLayer.zPosition = z
                j += 1
            }
        }
        
        topZPosition = z    // remember "highest position"
    }
    
    func flipCard(_ card : Card, faceUp : Bool) {
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
            
            layoutSublayers(of:self.layer)      // XXXXXX Again... change this later perhaps
        }
    }
    
    func collectWasteCardsIntoStock() {
        solitaire.collectWasteCardsIntoStock()
        layoutSublayers(of:self.layer)
    }
    
    func dragCardsToPosition(_ position : CGPoint, animate : Bool) {
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
                cardLayer.position = CGPoint(x: position.x, y: position.y + CGFloat(i)*off)
            }
        }
        if !animate {
            CATransaction.commit()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let touchPoint = touch.location(in: self)
        let hitTestPoint = self.layer.convert(touchPoint, to: self.layer.superlayer)
        let layer = self.layer.hitTest(hitTestPoint)
        
        if let layer = layer {
            if layer.name == "card" {
                let cardLayer = layer as! CardLayer
                let card = cardLayer.card
                
                if solitaire.isCardFaceUp(card) {
                   /* if touch.tapCount > 1 {
                        for i in 0 ..< 4 {
                            if solitaire.canDropCard(card, onFoundation: i){
                                solitaire.didDropCard(card, onFoundation: i)
                                draggingCardLayer = cardLayer
                                dragCardsToPosition(foundationLayers[i].position, animate: true)
                                draggingCardLayer = nil

                                if solitaire.gameWon() {
                                    party()
                                }
                                layoutSublayers(of:self.layer)
                                // maybe use flipCard() to animate card flipping...
                                break
                            }
                        }
                    } else {*/
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
                                            topZPosition += 1
                                            fanCardLayer?.zPosition = topZPosition
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
                    
                    //}
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = draggingCardLayer {
            let touch = touches.first
            let touchPoint = touch?.location(in: self)
            let delta = CGPoint(x: touchPoint!.x - touchStartPoint.x, y: touchPoint!.y - touchStartPoint.y)
            let pos = CGPoint(x: touchStartLayerPosition.x + delta.x, y: touchStartLayerPosition.y + delta.y)
            dragCardsToPosition(pos, animate: false)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = draggingCardLayer {
             if draggingFan == nil {
                var intended = false
                for i in 0 ..< 4 {
                    if draggingCardLayer!.frame.intersects(foundationLayers[i].frame) {
                        if solitaire.canDropCard(draggingCardLayer!.card, onFoundation: i){
                            solitaire.didDropCard(draggingCardLayer!.card, onFoundation: i)
                            intended = true
                            if solitaire.gameWon() {
                                party()
                            }
                            // maybe use flipCard() to animate card flipping...
                            break
                        }
                    }
                }
                if !intended {
                    for i in 0 ..< 7 {
                        
                        if solitaire.tableau[i].isEmpty {
                            if draggingCardLayer!.frame.intersects(tableauLayers[i].frame) {
                                if solitaire.canDropCard(draggingCardLayer!.card, onTableau: i) {
                                    solitaire.didDropCard(draggingCardLayer!.card, onTableau: i)
                                    intended = true
                                }
                            }
                        }else {
                            if let whereToDrop = cardToLayerDictionary[solitaire.tableau[i].last!]{
                                if draggingCardLayer!.frame.intersects(whereToDrop.frame) {
                                    if solitaire.canDropCard(draggingCardLayer!.card, onTableau: i) {
                                        solitaire.didDropCard(draggingCardLayer!.card, onTableau: i)
                                        intended = true
                                    }
                                }
                            }
                        }
                    }
                }
                if !intended {
                    
                    let cardLayer = draggingCardLayer!
                    let card = cardLayer.card
                    var found = false
                    for i in 0 ..< 4 {
                        if solitaire.canDropCard(card, onFoundation: i){
                            solitaire.didDropCard(card, onFoundation: i)
                            draggingCardLayer = cardLayer
                            dragCardsToPosition(foundationLayers[i].position, animate: true)
                            draggingCardLayer = nil
                            found = true
                            if solitaire.gameWon() {
                                party()
                            }
                            break
                        }
                    }
                    
                    if !found {
                        for i in 0 ..< 7 {
                            if solitaire.tableau[i].isEmpty {
                                    if solitaire.canDropCard(draggingCardLayer!.card, onTableau: i) {
                                        solitaire.didDropCard(draggingCardLayer!.card, onTableau: i)
                                        draggingCardLayer = cardLayer
                                        dragCardsToPosition(tableauLayers[i].position, animate: true)
                                        draggingCardLayer = nil
                                        break
                                    }
                                
                            } else {
                                if let whereToDrop = cardToLayerDictionary[solitaire.tableau[i].last!]{
                                        if solitaire.canDropCard(draggingCardLayer!.card, onTableau: i) {
                                            solitaire.didDropCard(draggingCardLayer!.card, onTableau: i)
                                            draggingCardLayer = cardLayer
                                            dragCardsToPosition(tableauLayers[i].position, animate: true)
                                            draggingCardLayer = nil
                                            break
                                        }
                                }
                            }
                        }
                    }
                }
                layoutSublayers(of:self.layer)
             } else { // fan of cards (can only drop on tableau stack)
                
                var intended = false
                for i in 0 ..< 7 {
                    
                    if solitaire.tableau[i].isEmpty {
                        if let firstCardFanLayer = cardToLayerDictionary[draggingFan!.first!]{
                            if firstCardFanLayer.frame.intersects(tableauLayers[i].frame) {
                                if solitaire.canDropFan(draggingFan!, onTableau: i) {
                                    solitaire.didDropFan(draggingFan!, onTableau: i)
                                    intended = true
                                    break
                                }
                            }
                        }
                    } else {
                        if let whereToDrop = cardToLayerDictionary[solitaire.tableau[i].last!]{
                            if let firstCardFanLayer = cardToLayerDictionary[draggingFan!.first!]{
                                if firstCardFanLayer.frame.intersects(whereToDrop.frame) {
                                    if solitaire.canDropFan(draggingFan!, onTableau: i) {
                                        solitaire.didDropFan(draggingFan!, onTableau: i)
                                        intended = true
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
                if !intended {
                    for i in 0 ..< 7 {
                        
                        if solitaire.tableau[i].isEmpty {
                            if let firstCardFanLayer = cardToLayerDictionary[draggingFan!.first!]{
                                    if solitaire.canDropFan(draggingFan!, onTableau: i) {
                                        solitaire.didDropFan(draggingFan!, onTableau: i)
                                        break
                                    }
                                
                            }
                        } else {
                            if let whereToDrop = cardToLayerDictionary[solitaire.tableau[i].last!]{
                                if let firstCardFanLayer = cardToLayerDictionary[draggingFan!.first!]{
                                        if solitaire.canDropFan(draggingFan!, onTableau: i) {
                                            solitaire.didDropFan(draggingFan!, onTableau: i)
                                            break
                                        }
                                    
                                }
                            }
                        }
                    }

                }
                
                layoutSublayers(of:self.layer)
            }
            draggingCardLayer = nil
            draggingFan = nil
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
       // <#code#>
    }


    func fanCards() {
        let radius = 0.35*max(bounds.width/2, bounds.height/2)
        let theta0 : CGFloat = CGFloat(M_PI)
        let theta1 : CGFloat = 0.0
        let dtheta = (theta1 - theta0)/51
        
        let deck = Card.deck()
        
        for i in 0 ..< 50 {
            let clayer = cardToLayerDictionary[deck[i]]
            let theta = theta0 + CGFloat(i)*dtheta
            let x : CGFloat = center.x - radius*cos(theta)
            let y : CGFloat = center.y + radius*sin(theta)
            clayer!.position = CGPoint(x: x, y: y)
            topZPosition += 1
            clayer!.zPosition = topZPosition
            clayer!.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(M_PI_2) - theta, 0, 0, 1)
        }
    }
    
    func resetLayers() {
        let deck = Card.deck()
        
        for i in 0 ..< 52 {
            let clayer = cardToLayerDictionary[deck[i]]
            topZPosition += 1
            clayer!.zPosition = topZPosition
            clayer!.transform = CATransform3DIdentity
        }
    }
    
    func playAgain() {
        //  accessing alertController from UIView method by Zev Eisenberg
        // http://stackoverflow.com/questions/26554894/how-to-present-uialertcontroller-when-not-in-a-view-controller
        
        let alert = UIAlertController(title: "YOU WON!", message: "Congrats!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Play Again?", style: UIAlertActionStyle.default, handler:
            {(UIAlertAction) -> Void in
                self.solitaire.freshGame()
                self.isWin = false
                self.resetLayers()
                self.layoutSublayers(of:self.layer)}))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func party() {
        
        isWin = true
        
        let width = bounds.size.width
        let height = bounds.size.height
        
        let deck = Card.deck()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let clayer = cardToLayerDictionary[deck[50]]
        let x : CGFloat = width/5 * 2
        let y : CGFloat = height/3
        clayer!.position = CGPoint(x: x, y: y)
        topZPosition += 1
        clayer!.zPosition = topZPosition

        let clayer2 = cardToLayerDictionary[deck[51]]
        let x2 : CGFloat = width/5 * 3
        let y2 : CGFloat = height/3
        clayer2!.position = CGPoint(x: x2, y: y2)
        topZPosition += 1
        clayer2!.zPosition = topZPosition
        CATransaction.commit()
        
        
        fanCards()
        
        playAgain()
        
    }

}
