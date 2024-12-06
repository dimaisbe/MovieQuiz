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
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
            super.viewDidLoad()
        
        showLoadingIndicator()
        imageView.isHidden = true
        
        alertPresenter = AlertPresenter()
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        questionFactory?.loadData()
        
        resetQuiz()
        }
        
        
        
        // MARK: - QuestionFactoryDelegate
        
    public func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            hideLoadingIndicator()
            imageView.isHidden = false
            currentQuestion = question
            let viewModel = convert(model: question)
            
            DispatchQueue.main.async { [weak self] in
                self?.show(quizStep: viewModel)
            }
        }
    
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
            image: UIImage(data: model.image) ?? UIImage(),
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
            showQuizResult(resultViewModel)
            
        } else {
            currentQuestionIndex += 1
            showLoadingIndicator()
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
        statisticService.store(correct: correctAnswer, total: questionsAmount)
        
        
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
    
    private func showLoadingIndicator() {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [ weak self ] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswer = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter?.showAlert(on: self, with: model)
    }
    
    public func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    public func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - Private functions
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
