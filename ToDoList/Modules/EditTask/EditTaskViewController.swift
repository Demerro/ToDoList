//
//  EditTaskViewController.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 2.08.25.
//

import UIKit

protocol EditTaskViewToPresenterProtocol: AnyObject {
    func textViewDidChange(text: String)
}

final class EditTaskViewController: UIViewController {
    
    private let textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.showsHorizontalScrollIndicator = false
        textView.alwaysBounceVertical = true
        textView.font = .preferredFont(forTextStyle: .body)
        return textView
    }()
    
    private lazy var navigationBar = navigationController?.navigationBar as! NavigationBar
    
    let task: Task
    let presenter: EditTaskViewToPresenterProtocol
    let dateFormatter: DateFormatter
    
    init(task: Task, presenter: EditTaskViewToPresenterProtocol, dateFormatter: DateFormatter) {
        self.task = task
        self.presenter = presenter
        self.dateFormatter = dateFormatter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCommon()
        setupViewConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationBar.subtitleLabel.alpha = 0.0
        navigationBar.subtitleLabel.isHidden = false
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: CATransaction.animationDuration(), delay: 0.0) {
            self.navigationBar.subtitleLabel.alpha = 1.0
        } completion: { [weak self] _ in
            self?.navigationBar.subtitleLabel.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationBar.subtitleLabel.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.textContainer.lineFragmentPadding = view.layoutMargins.left
    }
}

extension EditTaskViewController {
    
    private func setupCommon() {
        textView.delegate = self
        view.backgroundColor = textView.backgroundColor
        view.addSubview(textView)
        title = task.title
        textView.text = task.description
        navigationBar.subtitleLabel.text = dateFormatter.string(from: task.date)
    }
    
    private func setupViewConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2.0),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            view.keyboardLayoutGuide.topAnchor.constraint(equalTo: textView.bottomAnchor),
        ])
    }
}

extension EditTaskViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        presenter.textViewDidChange(text: textView.text)
    }
}
