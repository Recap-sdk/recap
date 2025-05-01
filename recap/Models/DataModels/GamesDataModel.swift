//
//  GamesDataModel.swift
//  recap
//
//  Created by Diptayan Jash on 09/11/24.
//

import Foundation
struct Games: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let name: String
    let description: String
    let screenName: String
}

let gamesDemo = [
    Games(imageName: "geoGusser", name: "Geo Sorter", description: "Boost memory", screenName: "GeoSorterViewController"),
//    Games(imageName: "cardGame", name: "Card Games", description: "Enhance memory function", screenName: "CardGameViewController"),
    Games(imageName: "MemoryMatch", name: "Match Mania", description: "Increase memory agility", screenName: "MemoryGameViewController"),
//    Games(imageName: "sortGame", name: "Sort Objects", description: "Boost spatial memory", screenName: "SortObjectsViewController")
]
