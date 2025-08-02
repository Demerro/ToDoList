//
//  TaskListViewController.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import UIKit

protocol TaskListViewToPresenterProtocol: AnyObject {
    func getTasks()
}

final class TaskListViewController: UIViewController {
    
    private let collectionView: UICollectionView = {
        let layoutConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfiguration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(languageCode: .english, languageRegion: .unitedStates)
        return formatter
    }()
    
    private var tasks = [Task]()
    
    private lazy var dataSource = makeDiffableDataSource()
    
    weak var presenter: TaskListViewToPresenterProtocol? = nil
    
    override func loadView() {
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Задачи"
        collectionView.delegate = self
        presenter?.getTasks()
    }
}

extension TaskListViewController {
    
    private func makeDiffableDataSource() -> UICollectionViewDiffableDataSource<Section, Item> {
        let cellRegistration = makeCellRegistration()
        return .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }
    
    private func makeCellRegistration() -> UICollectionView.CellRegistration<TaskListCollectionViewCell, Item> {
        .init { [unowned self] cell, indexPath, itemIdentifier in
            let task = tasks[indexPath.item]
            var configuration = cell.defaultContentConfiguration()
            configuration.isCompleted = task.isCompleted
            configuration.title = task.title
            configuration.description = task.description
            configuration.createdAt = dateFormatter.string(from: task.date)
            cell.configuration = configuration
        }
    }
    
    private func setupSnapshot(for items: [Int]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot)
    }
}

extension TaskListViewController: TaskListPresenterToViewProtocol {
    
    func displayTasks(_ tasks: [Task]) {
        self.tasks = tasks
        setupSnapshot(for: tasks.map(\.id))
    }
}

extension TaskListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider:  { _ in
            let actions = [
                UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")!, handler: { _ in }),
                UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")!, handler: { _ in }),
                UIAction(title: "Удалить", image: UIImage(systemName: "trash")!, attributes: .destructive, handler: { _ in }),
            ]
            return UIMenu(title: "", children: actions)
        })
    }
}

extension TaskListViewController {
    
    private enum Section {
        case main
    }
    
    private typealias Item = Int
}
