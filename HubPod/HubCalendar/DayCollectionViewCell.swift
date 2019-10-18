//
//  DayCollectionViewCell.swift
//  HubPod
//
//  Created by Leonardo Saganski on 25/09/19.
//  Copyright © 2019 ItauBBA. All rights reserved.
//

import Foundation
import UIKit

class DayCollectionViewCell: UICollectionViewCell {
    let sepSize = CGFloat(1)
    var sepSizeConstraint: NSLayoutConstraint?
    var colorBackgroundSelected: UIColor?
    var colorTextSelected: UIColor? = .white
    var colorBackgroundNotSelected: UIColor? = .white
    var colorTextNotSelected: UIColor? = .itauGray

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let separator: UIView = {
        let sep = UIView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        return sep
    }()
    
    let viewDay: UIView = {
        let viewDay = UIView()
        viewDay.translatesAutoresizingMaskIntoConstraints = false
        return viewDay
    }()
    
    let labelHeader: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelDay: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let markerToday: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let markerSelected: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let markerEventA: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let markerEventB: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            markerSelected.backgroundColor = isSelected ? colorBackgroundSelected ?? .itauOrange : .clear
            labelDay.textColor = isSelected ? colorTextSelected ?? .white : colorTextNotSelected
        }
    }
    
    let event: HubCalendarEvent? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addViews() {
        backgroundColor = .clear
        addSubview(stack)
        addSubview(separator)
        separator.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.sepSizeConstraint = separator.widthAnchor.constraint(equalToConstant: self.sepSize)
        self.sepSizeConstraint?.isActive = true
        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: separator.leadingAnchor).isActive = true
        stack.addArrangedSubview(labelHeader)
        stack.addArrangedSubview(viewDay)
        stack.distribution = .fillEqually
        stack.alignment = .fill
        viewDay.addSubview(markerToday)
        viewDay.addSubview(markerSelected)
        viewDay.addSubview(markerEventA)
        viewDay.addSubview(markerEventB)
        viewDay.addSubview(labelDay)
        labelHeader.centerXAnchor.constraint(equalTo: stack.centerXAnchor).isActive = true
        labelDay.centerYAnchor.constraint(equalTo: viewDay.centerYAnchor).isActive = true
        labelDay.centerXAnchor.constraint(equalTo: viewDay.centerXAnchor).isActive = true
        markerToday.centerYAnchor.constraint(equalTo: viewDay.centerYAnchor, constant: 0).isActive = true
        markerToday.centerXAnchor.constraint(equalTo: viewDay.centerXAnchor, constant: 0).isActive = true
        markerToday.widthAnchor.constraint(equalTo: viewDay.widthAnchor, multiplier: 0.8).isActive = true
        markerToday.heightAnchor.constraint(equalTo: viewDay.heightAnchor, multiplier: 0.8).isActive = true

        markerSelected.centerYAnchor.constraint(equalTo: viewDay.centerYAnchor, constant: 0).isActive = true
        markerSelected.centerXAnchor.constraint(equalTo: viewDay.centerXAnchor, constant: 0).isActive = true
        markerSelected.widthAnchor.constraint(equalTo: viewDay.widthAnchor, multiplier: 0.8).isActive = true
        markerSelected.heightAnchor.constraint(equalTo: viewDay.heightAnchor, multiplier: 0.8).isActive = true

        markerEventA.centerYAnchor.constraint(equalTo: viewDay.centerYAnchor, constant: 0).isActive = true
        markerEventA.centerXAnchor.constraint(equalTo: viewDay.centerXAnchor, constant: 0).isActive = true
        markerEventA.widthAnchor.constraint(equalTo: viewDay.widthAnchor, multiplier: 0.8).isActive = true
        markerEventA.heightAnchor.constraint(equalTo: viewDay.heightAnchor, multiplier: 0.8).isActive = true
        markerEventB.topAnchor.constraint(equalTo: labelDay.bottomAnchor, constant: 0).isActive = true
        markerEventB.centerXAnchor.constraint(equalTo: viewDay.centerXAnchor, constant: 0).isActive = true
        markerEventB.widthAnchor.constraint(equalTo: viewDay.widthAnchor, multiplier: 0.2).isActive = true
        markerEventB.heightAnchor.constraint(equalTo: viewDay.heightAnchor, multiplier: 0.2).isActive = true
    }
    
    func showHeader(show: Bool) {
        labelHeader.isHidden = !show
        self.layoutIfNeeded()
    }
    
    func showSeparator(show: Bool) {
        self.sepSizeConstraint?.isActive = false
        self.sepSizeConstraint?.constant = show ? self.sepSize : 0
        self.sepSizeConstraint?.isActive = true
        self.layoutIfNeeded()
    }
}
