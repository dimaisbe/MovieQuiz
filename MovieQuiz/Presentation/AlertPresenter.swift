//
//  AlertPresentor.swift
//  MovieQuiz
//
//  Created by Дмитрий Железняков on 07.11.2024.
//

import UIKit

final class AlertPresenter {
    func showAlert(on viewController: UIViewController, with model: AlertModel) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: model.title,
                message: model.message,
                preferredStyle: .alert)
            
            let action = UIAlertAction(
                title: model.buttonText,
                style: .default)
            { _ in model.completion?() }
            
            alert.addAction(action)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}
