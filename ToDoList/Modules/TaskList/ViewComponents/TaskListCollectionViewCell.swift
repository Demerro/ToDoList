//
//  TaskListCollectionViewCell.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 2.08.25.
//

import UIKit

final class TaskListCollectionViewCell: UICollectionViewCell {
    
    private static let circleImage = UIImage(systemName: "circle")!
    private static let checkmarkCircleImage = UIImage(systemName: "checkmark.circle")!
    
    private let isCompletedImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        return label
    }()
    
    private let createdAtLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private var oldConstraints = [NSLayoutConstraint]()
    
    var configuration: Configuration = Configuration() {
        didSet { applyConfiguration() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCommon()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension TaskListCollectionViewCell {
    
    private func setupCommon() {
        contentView.addSubview(isCompletedImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(createdAtLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            isCompletedImageView.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1.0),
            isCompletedImageView.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1.0),
            isCompletedImageView.widthAnchor.constraint(equalToConstant: 24.0),
            isCompletedImageView.heightAnchor.constraint(equalTo: isCompletedImageView.widthAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: isCompletedImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: isCompletedImageView.trailingAnchor, multiplier: 1.0),
            contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 1.0),
            
            descriptionLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: isCompletedImageView.trailingAnchor, multiplier: 1.0),
            contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: descriptionLabel.trailingAnchor, multiplier: 1.0),
            
            createdAtLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: isCompletedImageView.trailingAnchor, multiplier: 1.0),
            contentView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: createdAtLabel.trailingAnchor, multiplier: 1.0),
            contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: createdAtLabel.bottomAnchor, multiplier: 1.0),
        ])
    }
}

extension TaskListCollectionViewCell {
    
    private func applyConfiguration() {
        descriptionLabel.text = configuration.description
        createdAtLabel.text = configuration.createdAt
        if configuration.isCompleted {
            isCompletedImageView.image = Self.checkmarkCircleImage
            titleLabel.attributedText = NSAttributedString(
                string: configuration.title ?? "",
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            titleLabel.textColor = .secondaryLabel
            descriptionLabel.textColor = .secondaryLabel
        } else {
            isCompletedImageView.image = Self.circleImage
            titleLabel.attributedText = NSAttributedString(string: configuration.title ?? "")
            titleLabel.textColor = .label
            descriptionLabel.textColor = .label
        }
        
        let constraints = if configuration.description == nil {
            [createdAtLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0)]
        } else {
            [descriptionLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
             createdAtLabel.topAnchor.constraint(equalToSystemSpacingBelow: descriptionLabel.bottomAnchor, multiplier: 1.0),]
        }
        NSLayoutConstraint.deactivate(oldConstraints)
        NSLayoutConstraint.activate(constraints)
        oldConstraints = constraints
    }
}

extension TaskListCollectionViewCell {
    
    struct Configuration {
        var isCompleted: Bool = false
        var title: String?
        var description: String?
        var createdAt: String?
        
        fileprivate init() {
        }
    }
    
    func defaultContentConfiguration() -> Configuration {
        Configuration()
    }
}
