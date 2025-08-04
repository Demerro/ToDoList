//
//  NavigationBar.swift
//  ToDoList
//
//  Created by Nikita Prokhorchuk on 4.08.25.
//

import UIKit

final class NavigationBar: UINavigationBar {
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var largeTitleView: UIView = {
        subviews.first(where: { String(describing: type(of: $0)) == Self.UINavigationBarLargeTitleView})!
    }()
    
    private var oldConstraints = [NSLayoutConstraint]()
    
    private var largeTitleViewInitialHeight: CGFloat!
    
    override static var requiresConstraintBasedLayout: Bool { true }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if largeTitleViewInitialHeight == nil, largeTitleView.frame.height != .zero {
            largeTitleViewInitialHeight = largeTitleView.frame.height
        } else if largeTitleViewInitialHeight != nil {
            changeLabelAlpha(forHeight: largeTitleView.frame.height)
        }
        
        setupConstraints()
    }
}

extension NavigationBar {
    
    private func setupConstraints() {
        guard let largeTitleLabel = largeTitleView.subviews.first as? UILabel else { return }
        
        if !subtitleLabel.isDescendant(of: self) {
            addSubview(subtitleLabel)
        }
        let constraints = [
            subtitleLabel.leadingAnchor.constraint(equalTo: largeTitleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: largeTitleLabel.bottomAnchor),
        ]
        NSLayoutConstraint.deactivate(oldConstraints)
        NSLayoutConstraint.activate(constraints)
        oldConstraints = constraints
    }
    
    private func changeLabelAlpha(forHeight height: CGFloat) {
        if largeTitleViewInitialHeight - 10.0 > height, subtitleLabel.alpha != 0.0 {
            subtitleLabel.alpha = 0.0
        } else if largeTitleViewInitialHeight - 10.0 <= height, height <= largeTitleViewInitialHeight {
            let normalizedValue = (height - (largeTitleViewInitialHeight - 10.0)) / 10.0
            subtitleLabel.alpha = normalizedValue
        } else if height > largeTitleViewInitialHeight, subtitleLabel.alpha != 1.0 {
            subtitleLabel.alpha = 1.0
        }
    }
}

extension NavigationBar {
    
    fileprivate static let UINavigationBarLargeTitleView = ["_", "UI", "Navigation", "Bar", "Large", "Title", "View"].joined()
}
