//
//  Card.swift
//  Solitaire
//
//  Created by Daniil Sergeyevich Martyn on 4/29/16.
//  Copyright © 2016 Daniil Sergeyevich Martyn. All rights reserved.
//

import Foundation

enum Suit : UInt8 {
    case SPADES = 0
    case CLUBS = 1
    case DIAMONDS = 2
    case HEARTS = 3
}

let ACE : UInt8 = 1
let JACK : UInt8 = 11
let QUEEN : UInt8 = 12
let KING : UInt8 = 13

func ==(left: Card, right: Card) -> Bool {
    return left.suit == right.suit && left.rank == right.rank
}

struct Card : Hashable {
    let suit : Suit   // .SPADES ... .HEARTS
    let rank : UInt8  // 1 ... 13
    
    var hashValue : Int {
        return Int(suit.rawValue*13 + rank-1)  // perfect hash to 0 ... 51
    }
    
    init(suit s : Suit, rank r :UInt8){
        suit = s;
        rank = r;
    }
    
    static func deck() -> [Card] {
        var deck : [Card] = []
        for suit in 0 ... 3  {
            for rank in 1 ... 13 {
                
                var newCard : Card?
                
                switch suit {
                case 0:
                    newCard = Card(suit: .SPADES, rank: UInt8(rank))
                case 1:
                    newCard = Card(suit: .CLUBS, rank: UInt8(rank))
                case 2:
                    newCard = Card(suit: .DIAMONDS, rank: UInt8(rank))
                case 3:
                    newCard = Card(suit: .HEARTS, rank: UInt8(rank))
                default:
                    break;
                }
                
                deck.append(newCard!)
            }
        }
        return deck
    }
}