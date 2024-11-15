import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var alertPresenter: AlertPresenter?
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    private var currentQuestionIndex = 0
    private var correctAnswer = 0

     
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
            super.viewDidLoad()
            
            alertPresenter = AlertPresenter()
            statisticService = StatisticService()
            
            let factory = QuestionFactory()
            factory.setup(delegate: self)
            questionFactory = factory
            
            resetQuiz()
            
        }
        
        
        
        // MARK: - QuestionFactoryDelegate
        
        func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            
            DispatchQueue.main.async { [weak self] in
                self?.show(quizStep: viewModel)
            }
        }
    
    // MARK: - Private functions
        private func showAnswerResult(isCorrect: Bool) {
            if isCorrect {
                correctAnswer += 1
            }
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showNextQuestionOrResults()
            }
        }
        
        private func convert(model: QuizQuestion) -> QuizStepViewModel {
            QuizStepViewModel(
                image: UIImage(named: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
            )
        }
        
        private func showNextQuestionOrResults() {
            if currentQuestionIndex == questionsAmount - 1 {
                let text = correctAnswer == questionsAmount ?
                "Поздравляем, вы ответили на 10 из 10!" :
                "Вы ответили на \(correctAnswer) из 10, попробуйте ещё раз!"
                
                let resultViewModel = QuizResultsViewModel(title: "Результаты", text: text, buttonText: "Начать заново")
                showQuizResult(resultViewModel) // Вызываем метод для показа результата
                
            } else {
                currentQuestionIndex += 1
                questionFactory?.requestNextQuestion()
            }
        }
        
        private func show(quizStep step: QuizStepViewModel) {
            imageView.image = step.image
            textLabel.text = step.question
            counterLabel.text = step.questionNumber
            imageView.layer.borderWidth = 0
            setButtonsEnabled(true)
        }
        
        private func showQuizResult(_ result: QuizResultsViewModel) {
            guard let statisticService = statisticService else { return }
            // обновление статистики
            statisticService.store(correct: correctAnswer, total: questionsAmount)
            
            // месседж в алерт (проверить + поправить!!!!!!)
            let bestGame = statisticService.bestGame
            let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
            let gamesCount = statisticService.gamesCount
            
            let message = """
                    Ваш результат: \(correctAnswer)/\(questionsAmount)
                    Количество сыгранных квизов: \(gamesCount)
                    Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                    Средняя точность: \(totalAccuracy)%
                    """
            
            let alertModel = AlertModel (
                title: "Этот раунд окончен!",
                message: message,
                buttonText: "Сыграть еще раз",
                completion: { [weak self] in
                    self?.resetQuiz()
                }
            )
            alertPresenter?.showAlert(on: self, with: alertModel)
        }
        
        private func resetQuiz() {
            currentQuestionIndex = 0
            correctAnswer = 0
            questionFactory?.resetQuestions()
            questionFactory?.requestNextQuestion()
        }
        
        private func setButtonsEnabled(_ isEnabled: Bool) {
            yesButton.isEnabled = isEnabled
            noButton.isEnabled = isEnabled
        }
        
    // MARK: - Actions
        @IBAction private func yesButtonClicked(_ sender: UIButton) {
            setButtonsEnabled(false)
            guard let currentQuestion = currentQuestion else {
                return
            }
            showAnswerResult(isCorrect: currentQuestion.correctAnswer)
        }
        
        @IBAction private func noButtonClicked(_ sender: UIButton) {
            setButtonsEnabled(false)
            guard let currentQuestion = currentQuestion else {
                return
            }
            showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
        }
    }
