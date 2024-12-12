import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quizStep step: QuizStepViewModel)
    func showQuizResult(_ result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}
