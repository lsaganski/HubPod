//
//  HubCalendarViewController.swift
//  HubPodExamples
//
//  Created by Leonardo Saganski on 25/09/19.
//  Copyright © 2019 ItauBBA. All rights reserved.
//

import Foundation
import UIKit
import HubPod

class HubCalendarViewController: UIViewController {
    
    var viewCalendar: HubCalendar?
    var calendarViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        navigationController?.title = "HubCalendar"
        navigationController?.navigationBar.backItem?.title = "BACK"

        let img = UIImageView()
        img.image = #imageLiteral(resourceName: "calendar_background")
        img.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(img)
        NSLayoutConstraint.activate([
            img.topAnchor.constraint(equalTo: view.topAnchor),
            img.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            img.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            img.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        let viewC = HubCalendar()
        viewC.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewC)
        NSLayoutConstraint.activate([
            viewC.topAnchor.constraint(equalTo: view.topAnchor, constant: 140),
            viewC.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewC.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            
            ])
        self.calendarViewHeightConstraint = viewC.heightAnchor.constraint(equalToConstant: 380)
        self.calendarViewHeightConstraint?.isActive = true
        self.viewCalendar = viewC

        setupCalendar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewCalendar?.resizeCalendar()
    }
    
    func setupCalendar() {
        viewCalendar?.delegate = self
        viewCalendar?.backgroundColor = .clear
        viewCalendar?.containerBackgroundColor = .clear
        viewCalendar?.containerHorizontalPaddings = 0
        viewCalendar?.stackViewHeaderBackgroundColor = .clear
        viewCalendar?.buttonPriorText = ""
        viewCalendar?.buttonNextText = ""
        viewCalendar?.buttonPriorTextColor = .lightGray
        viewCalendar?.buttonNextTextColor = .lightGray
        viewCalendar?.buttonPriorImage = UIImage(named: "arrow_left")
        viewCalendar?.buttonNextImage = UIImage(named: "arrow_right")
        viewCalendar?.labelMonthFont = UIFont(name: "SFProDisplay-Regular", size: 16.0) ??
            UIFont.boldSystemFont(ofSize: 16.0)
        viewCalendar?.labelMonthTextColor = .white
        viewCalendar?.stackViewWeekdaysBackgroundColor = .clear
        viewCalendar?.labelWeekdaysTextColor = .white
        viewCalendar?.labelWeekdaysFont = UIFont(name: "SFProDisplay-Thin", size: 15.0) ??
            UIFont.boldSystemFont(ofSize: 15.0)
        viewCalendar?.cvBackgroundColor = .clear
        viewCalendar?.cellCurrentBackgroundColor = .clear
        viewCalendar?.cellNotCurrentBackgroundColor = .darkGray
        viewCalendar?.cellCurrentTextColor = .lightGray
        viewCalendar?.cellNotCurrentTextColor = .lightGray
        viewCalendar?.cellTodayBackgroundColor = .orange
        viewCalendar?.cellTodayTextColor = .white
        viewCalendar?.cellFont = UIFont(name: "SFProDisplay-Bold", size: 14.0) ?? UIFont.boldSystemFont(ofSize: 14.0)
        viewCalendar?.separatorColor = .lightGray
        viewCalendar?.buttonExpandTextColor = .lightGray
        viewCalendar?.buttonExpandImage = UIImage(named: "arrow_down")
        viewCalendar?.buttonExpandText = ""
    }
}

extension HubCalendarViewController: HubCalendarDelegate {
    func onResizeSked(expanding: Bool, height: CGFloat) {
        calendarViewHeightConstraint?.constant = height
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       usingSpringWithDamping: 2.0,
                       initialSpringVelocity: 2.0,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func onPressDate(date: Date) {
        let formatted: String = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
        let alertController = UIAlertController(title: "Date Picked !!", message: formatted, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
