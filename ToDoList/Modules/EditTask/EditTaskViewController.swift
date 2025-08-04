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
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.showsHorizontalScrollIndicator = false
        textView.alwaysBounceVertical = true
        textView.font = .preferredFont(forTextStyle: .body)
        return textView
    }()
    
    let task: Task
    let presenter: EditTaskViewToPresenterProtocol
    
    init(task: Task, presenter: EditTaskViewToPresenterProtocol) {
        self.task = task
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        title = task.title
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        view = textView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        textView.textContainerInset = UIEdgeInsets(top: 0.0, left: view.directionalLayoutMargins.leading, bottom: 0.0, right: view.directionalLayoutMargins.trailing)
    }
}

extension EditTaskViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        presenter.textViewDidChange(text: textView.text)
    }
}
