
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
    
    private var faceUpCards : Set<Card>;
    
    
    init(){
        stock = []
        waste = []
        foundation = [[]]
        tableau = [[]]
        
        faceUpCards = Set()
        
        freshGame()
    }
    
    func shuffle() {        // shuffles only cards in stock
        
        for _ in 0 ..< 5 {          // shuffle 5 times
            for j in 0 ..< 52 {     // go through every card
                var randomInt = Int(arc4random() % 52)   // pick a random location in deck
                while randomInt == j {              // if picks same number as j, pick again
                    randomInt = Int(arc4random() % 52)
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
        waste = []              // waste has nothing
        foundation = [[]]       // foundation has nothing
        
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
    
    func isCardFaceUp(card : Card) -> Bool {
        if faceUpCards.contains(card) {
            return true
        } else {
            return false
        }
    }
    
    func fanBeginningWithCard(card : Card) -> [Card]? {
        return nil
    }
    
    func canDropCard(card : Card, onFoundation i : Int) -> Bool {
        return false
    }
    
    func didDropCard(card: Card, onFoundation i : Int) {
        
    }
    
    func canDropCard(card : Card, onTableau i : Int) -> Bool {
        return false
    }
    
    func didDropCard(card : Card, onTableau i : Int) {
        
    }
    
    func canFlipCard(card : Card) -> Bool {
        return false
    }
    
    func didFlipCard(card : Card) {
        
    }
    
    func canDealCard() -> Bool {
        return false
    }
    
    func didDealCard() {
        
    }
    
    func collectWasteCardsIntoStock() {
        
    }
    
    
}