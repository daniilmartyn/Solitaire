
//
//  Solitaire.swift
//  Solitaire
//
//  Created by Daniil Sergeyevich Martyn on 4/29/16.
//  Copyright © 2016 Daniil Sergeyevich Martyn. All rights reserved.
//

import Foundation

class Solitaire {
    var stock : [Card]
    var waste : [Card]
    var foundation : [[Card]]   // Array of 4 card stacks
    var tableau : [[Card]]      // Array of 7 card stacks
    
    fileprivate var faceUpCards : Set<Card>;
    
    
    init(){
        stock = []
        waste = []
        foundation = [[],[],[],[]]
        tableau = [[],[],[],[],[],[],[]]
        
        faceUpCards = Set()
        
        freshGame()
    }
    
    func shuffle() {        // shuffles only cards in stock
        
        for _ in 0 ..< 5 {          // shuffle 5 times
            for j in 0 ..< 52 {     // go through every card
                var randomInt = Int(arc4random_uniform(52))   // pick a random location in deck
                while randomInt == j {              // if picks same number as j, pick again
                    randomInt = Int(arc4random_uniform(52))
                }
                
                
                // swap the cards at locations j and randomInt in the stock array
                
                let tmp : Card = stock[j]
                stock[j] = stock[randomInt]
                stock[randomInt] = tmp
            }
        }
    }
    
    func freshGame(){
        stock = Card.deck()
        shuffle()
        waste.removeAll()             // waste has nothing
        faceUpCards.removeAll()
        
        for index in 0 ..< foundation.count {
            foundation[index].removeAll()
        }
        
        for index in 0 ..< tableau.count {
            tableau[index].removeAll()
        }
        
        // deal cards from stock to tableau and update faceUpCards set
        
        for i in 0 ..< 7 {          // go through each of the 7 tableaus
            for j in 0 ..< i+1 {
                let card : Card = stock.removeLast()
                tableau[i].append(card)
                if j == i {
                    faceUpCards.insert(card)
                }
            }
        }
    }
 
    func gameWon() -> Bool {
       var count : Int = 0
        
        for i in 0 ..< 4 {          // count up how many cards are in the foundation
            count += foundation[i].count
        }
        
        if count == 52 { // if all the cards are in the foundation, game is won
            return true
        } else {
            return false
        }
    }
    
    func isCardFaceUp(_ card : Card) -> Bool {
        if faceUpCards.contains(card) {
            return true
        } else {
            return false
        }
    }
    
    func fanBeginningWithCard(_ card : Card) -> [Card]? {
        
        var cards : [Card] = []
        var done : Bool = false
        
        for i in 0 ..< 7 {
            for j in 0 ..< tableau[i].count {
                if tableau[i][j] == card {
                    for k in j ..< tableau[i].count {
                        cards.append(tableau[i][k])
                    }
                    done = true
                    break
                }
            }
            if done {
                break
            }
        }
        
        
        for i in 1 ..< cards.count {
            if cards[i].rank != cards[i-1].rank-1 {
                return nil
            }
            
            let currentCardSuit = cards[i].suit
            let prevCardSuit = cards[i-1].suit
            
            if ((currentCardSuit == .spades || currentCardSuit == .clubs)
                && (prevCardSuit == .diamonds || prevCardSuit == .hearts))
                ||
                ((currentCardSuit == .diamonds || currentCardSuit == .hearts)
                    && (prevCardSuit == .clubs || prevCardSuit == .spades)){
                        continue
            } else {
                return nil
            }
        }
        
        return cards
    }
    
    func canDropCard(_ card : Card, onFoundation i : Int) -> Bool {
        
        if foundation[i].isEmpty && card.rank == ACE {
            return true
        } else if foundation[i].last?.suit == card.suit && foundation[i].last!.rank == card.rank-1 { 
            return true
        }
        
        return false
        
    }
    
    func didDropCard(_ card: Card, onFoundation i : Int) {
        if waste.contains(card) {
            waste.remove(at: waste.index(of: card)!)
        }
        
        for i in 0 ..< 4 {
            if foundation[i].contains(card){
                foundation[i].remove(at: foundation[i].index(of: card)!)
                break
            }
        }
        
        for i in 0 ..< 7 {
            if tableau[i].contains(card) {
                tableau[i].remove(at: tableau[i].index(of: card)!)
                if !tableau[i].isEmpty{
                    faceUpCards.insert(tableau[i].last!)
                }
                break
            }
        }
        
        
        foundation[i].append(card)
    }
    
    func canDropCard(_ card : Card, onTableau i : Int) -> Bool {
        
        if tableau[i].isEmpty {
            if card.rank == KING {
                return true
            } else {
                return false
            }
        } else {
        
            let cardSuit = card.suit
            let tableauSuit = tableau[i].last!.suit
        
            if ((cardSuit == .spades || cardSuit == .clubs)
                && (tableauSuit == .diamonds || tableauSuit == .hearts))
            ||
                ((cardSuit == .diamonds || cardSuit == .hearts)
                    && (tableauSuit == .clubs || tableauSuit == .spades)){
                        if card.rank == tableau[i].last!.rank-1 {
                            return true
                        }
            }
        
        }
        
        return false
    }
    
    func didDropCard(_ card : Card, onTableau i : Int) {
        if waste.contains(card) {
            waste.remove(at: waste.index(of: card)!)
        }
        
        for i in 0 ..< 4 {
            if foundation[i].contains(card) {
                foundation[i].remove(at: foundation[i].index(of: card)!)
            }
        }
        
        for i in 0 ..< 7 {
            if tableau[i].contains(card) {
                tableau[i].remove(at: tableau[i].index(of: card)!)
                if !tableau[i].isEmpty {
                    faceUpCards.insert((tableau[i].last!))
                }
                break
            }
        }
        
        tableau[i].append(card)
    }
    
    func canDropFan( _ cards : [Card], onTableau i : Int) -> Bool {
        
        if tableau[i].isEmpty {
            if cards.first!.rank == KING {
                return true
            } else {
                return false
            }
        } else {
            
            let cardSuit = cards.first!.suit
            let tableauSuit = tableau[i].last!.suit
            
            if ((cardSuit == .spades || cardSuit == .clubs)
                && (tableauSuit == .diamonds || tableauSuit == .hearts))
                ||
                ((cardSuit == .diamonds || cardSuit == .hearts)
                    && (tableauSuit == .clubs || tableauSuit == .spades)){
                        if cards.first!.rank == tableau[i].last!.rank-1 {
                            return true
                        }
            }
            
        }
        
        return false
    }
    
    func didDropFan(_ cards : [Card], onTableau i : Int) {
        
        var fromWhere : Int = -1
        
        for j in 0 ..< 7 {
            if tableau[j].contains(cards.first!) {
                fromWhere = j
            }
        }
        
        for card in cards {
            tableau[fromWhere].remove(at: tableau[fromWhere].index(of: card)!)
            tableau[i].append(card)
        }
        
        if !tableau[fromWhere].isEmpty {
            faceUpCards.insert(tableau[fromWhere].last!)
        }
        
    }
    
    func canFlipCard(_ card : Card) -> Bool {
       // if card == stock.last {
       //     return true
        //}
        
        return false
    }
    
    func didFlipCard(_ card : Card) {
        
    }
    
    func canDealCard() -> Bool {
        if stock.isEmpty {
            return false
        }
        return true
    }
    
    func didDealCard() {
        let card = stock.last
        stock.removeLast()
        waste.append(card!)
        faceUpCards.insert(card!)
    }
    
    func collectWasteCardsIntoStock() {
        while !waste.isEmpty {
            let card = waste.last
            waste.removeLast()
            stock.append(card!)
            faceUpCards.remove(card!)
        }
    }
}
