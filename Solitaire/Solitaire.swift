
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
        /// XXXXXX Obviously change this later...
        stock = []
        waste = []
        foundation = [[]]
        tableau = [[]]
        
        faceUpCards = Set()
    }
    
    func freshGame(){
        
    }
 
    func gameWon() -> Bool {
        return false
    }
    
    func isCardFaceUp(card : Card) -> Bool {
        return false
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