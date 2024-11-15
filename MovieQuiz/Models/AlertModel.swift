//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Дмитрий Железняков on 07.11.2024.
//

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
