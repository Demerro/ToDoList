//
//  TaskListViewController.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 1.08.25.
//

import UIKit

protocol TaskListViewToPresenterProtocol: AnyObject {
    func getTasks()
    func showEditTask(for task: Task)
    func deleteTask(_ task: Task)
    func shareTask(_ task: Task)
    func completeTask(_ task: Task)
}

final class TaskListViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        var layoutConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfiguration.leadingSwipeActionsConfigurationProvider = { indexPath in
            let completeAction = UIContextualAction(style: .normal, title: nil) { [unowned self] _, _, completion in
                let task = tasks[indexPath.item]
                presenter.completeTask(task)
                completion(true)
            }
            completeAction.image = UIImage(systemName: "checkmark")!
            completeAction.backgroundColor = .systemYellow
            return UISwipeActionsConfiguration(actions: [completeAction])
        }
        layoutConfiguration.trailingSwipeActionsConfigurationProvider = { indexPath in
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { [unowned self] _, _, _ in
                presenter.deleteTask(tasks[indexPath.item])
            }
            deleteAction.image = UIImage(systemName: "trash")
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
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
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var tasks = [Task]()
    
    private lazy var dataSource = makeDiffableDataSource()
    
    let presenter: TaskListViewToPresenterProtocol
    
    init(presenter: TaskListViewToPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Задачи"
        collectionView.delegate = self
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        presenter.getTasks()
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
    
    func reconfigureTask(_ task: Task) {
        var snapshot = dataSource.snapshot()
        tasks[snapshot.indexOfItem(task.id)!] = task
        snapshot.reconfigureItems([task.id])
        dataSource.apply(snapshot)
    }
    
    func deleteTask(with id: Int) {
        tasks.removeAll { $0.id == id }
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([id])
        dataSource.apply(snapshot)
    }
}

extension TaskListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        presenter.showEditTask(for: tasks[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider: { _ in
            let actions = [
                UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")!, handler: { [unowned self] _ in
                    if let indexPath = indexPaths.first {
                        presenter.showEditTask(for: tasks[indexPath.item])
                    }
                }),
                UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")!, handler: { [unowned self] _ in
                    if let indexPath = indexPaths.first {
                        presenter.shareTask(tasks[indexPath.item])
                    }
                }),
                UIAction(title: "Удалить", image: UIImage(systemName: "trash")!, attributes: .destructive, handler: { [unowned self] _ in
                    if let indexPath = indexPaths.first {
                        presenter.deleteTask(tasks[indexPath.item])
                    }
                }),
            ]
            return UIMenu(title: "", children: actions)
        })
    }
}

extension TaskListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else { return }
        let filteredTasks = tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        filteredTasks.isEmpty ? setupSnapshot(for: tasks.map(\.id)) : setupSnapshot(for: filteredTasks.map(\.id))
    }
}

extension TaskListViewController {
    
    private enum Section {
        case main
    }
    
    private typealias Item = Int
}
