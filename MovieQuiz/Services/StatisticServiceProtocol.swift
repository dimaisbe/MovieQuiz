//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Дмитрий Железняков on 07.11.2024.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get set }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
