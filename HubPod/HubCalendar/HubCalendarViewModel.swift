//
//  HubCalendarViewModel.swift
//  HubPod
//
//  Created by Leonardo Saganski on 25/09/19.
//  Copyright © 2019 ItauBBA. All rights reserved.
//

import Foundation
import UIKit

struct HubCalendarDay {
    let text: String
    let date: Date
    let events: [HubCalendarEvent]
    let isHolyday: Bool
    let currentMonth: Bool
    let isToday: Bool
    var isSelected: Bool
    var isLabel: Bool
}

struct CellColorUISpecs {
    let separatorColor: UIColor
    let labelWeekdaysTextColor: UIColor
    let labelWeekdaysFont: UIFont
    let cellCurrentBackgroundColor: UIColor
    let cellNotCurrentBackgroundColor: UIColor
    let cellTodayTextColor: UIColor
    let cellCurrentTextColor: UIColor
    let cellNotCurrentTextColor: UIColor
    let cellFont: UIFont
    let cellTodayBackgroundColor: UIColor
    let cellSelectedBackgroundColor: UIColor
    let cellSelectedTextColor: UIColor
    let showMarkerA: Bool
    let showMarkerB: Bool
    let colorMarkerA: UIColor
    let colorMarkerB: UIColor
}

protocol HubCalendarViewModelDelegate: AnyObject {
    func updateLabelMonth(text: String)
    func onPressDate(date: Date, events: [HubCalendarEvent])
    func onReloadData()
}

class HubCalendarViewModel: NSObject {
    var currentSetE: [HubCalendarDay] = []
    var currentSetC: [HubCalendarDay] = []
    var events: [HubCalendarEvent] = [] {
        didSet {
            
        }
    }
//    var eventsForCurrentDate: [HubCalendarEvent] = []

    var viewController: UIViewController?
    var delegate: HubCalendarViewModelDelegate?
    // Data
    let weekDays = ["S", "M", "T", "W", "T", "F", "S"]
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let cellReuseIdentifier = "calendarCell"
    var calendar: Calendar = Calendar.current
    var currentDate: Date = Date()
    var today: Date = Date()
    var currentMonthDC = DateComponents()
    var priorMonthDC = DateComponents()
    var nextMonthDC = DateComponents()
    var requestedComponents: Set<Calendar.Component> = [
        .year,
        .month,
        .day,
        .weekday
    ]
    var labelMonth: String = "" {
        didSet {
            delegate?.updateLabelMonth(text: labelMonth)
        }
    }
    let numberOfItemsPerRow: Int = 7
    var isExpanded = true
    var cellSpecs: CellColorUISpecs?
    var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }

    var isCurrentMonth: Bool {
        let currentMonth = self.calendar.component(.month, from: self.currentDate)
        let todayMonth = self.calendar.component(.month, from: self.today)

        return currentMonth == todayMonth
    }
    
    var indexPathForFirstDayOfThisWeek: IndexPath {
//        var c = DateComponents()
//        c.day = 30
//        c.month = 12
//        c.year = 2019
//        let ddd = Calendar.current.date(from: c)!
        let weekday = calendar.component(.weekday, from: today)
        return IndexPath(row: indexForToday+1-weekday, section: 0)
    }
    
    var indexForToday: Int {
        for index in 0..<currentSetC.count {
            if calendar.dateComponents(self.requestedComponents, from: currentSetC[index].date) ==
               calendar.dateComponents(self.requestedComponents, from: today) {
                return index
            }
        }
        return -1
    }
    
    func loadPriorMonth() {
        if let date = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = date
            loadComponent()
        }
    }
    
    func loadNextMonth() {
        if let date = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = date
            loadComponent()
        }
    }
    
    func loadComponent() {
        prepareData()
        loadDaysFromPriorCurrentAndNextMonths()
        delegate?.onReloadData()
    }
    
    func prepareData() {
        self.calendar.locale = Locale.current
//        self.calendar.date(byAdding: <#T##DateComponents#>, to: <#T##Date#>)
//        var comp = DateComponents()
//        comp.hour = 0
//        currentDate = NSDate.now // calendar.date(from: comp)!
//        today = NSDate.now //  calendar.date(from: comp)!
        
        let month = calendar.component(.month, from: currentDate)
        let year = calendar.component(.year, from: currentDate)
        labelMonth = "\(months[month-1]) \(year)"
        currentMonthDC = calendar.dateComponents(requestedComponents, from: currentDate)
        currentMonthDC.setValue(1, for: .day)
        let date = calendar.date(from: currentMonthDC) ?? today
        currentMonthDC = calendar.dateComponents(requestedComponents, from: date)
        let newPriorDate = calendar.date(byAdding: .day, value: -1, to: date) ?? today
        priorMonthDC = calendar.dateComponents(requestedComponents, from: newPriorDate)
        let newNextDate = calendar.date(byAdding: .month, value: 1, to: date) ?? today
        nextMonthDC = calendar.dateComponents(requestedComponents, from: newNextDate)
    }
    
    func loadDaysFromPriorCurrentAndNextMonths() {
        if var numberOfDaysFromLastMonth = currentMonthDC.weekday {
            numberOfDaysFromLastMonth -= 1
            currentSetE = []
            currentSetC = []
            for day in weekDays {
                let label = HubCalendarDay(text: day, date: Date(), events: [], isHolyday: false, currentMonth: false, isToday: false, isSelected: false, isLabel: true)
                self.currentSetE.append(label)
            }
            for index in stride(from: numberOfDaysFromLastMonth, to: 0, by: -1) {
                let date = calendar.date(from: priorMonthDC) ?? today
                let newDate = calendar.date(byAdding: .day, value: -(index-1), to: date) ?? today
                let result = calendar.compare(newDate, to: today, toGranularity: .day)
                let isToday = result == .orderedSame
                let eventList = events.filter { calendar.compare(newDate, to: $0.initialDate, toGranularity: .day) == ComparisonResult.orderedSame }
                let text = String(calendar.component(.day, from: newDate))
                let day = HubCalendarDay(text: text, date: newDate, events: eventList, isHolyday: false, currentMonth: false, isToday: isToday, isSelected: false, isLabel: false)
                currentSetC.append(day)
                currentSetE.append(day)
            }
            let date = calendar.date(from: nextMonthDC) ?? today
            let lastDateFromCurrentMonth = calendar.date(byAdding: .day, value: -1, to: date) ?? today
            let lastDCFromCurrentMonth = calendar.dateComponents(requestedComponents, from: lastDateFromCurrentMonth)
            let day = lastDCFromCurrentMonth.day ?? 0
            for index in 0..<day {
                let date = calendar.date(from: currentMonthDC) ?? today
                let newDate = calendar.date(byAdding: .day, value: index, to: date) ?? today
                let result = calendar.compare(newDate, to: today, toGranularity: .day)
                let isToday = result == .orderedSame
                let eventList = events.filter { calendar.compare(newDate, to: $0.initialDate, toGranularity: .day) == ComparisonResult.orderedSame }
                let text = String(calendar.component(.day, from: newDate))
                let day = HubCalendarDay(text: text, date: newDate, events: eventList, isHolyday: false, currentMonth: true, isToday: isToday, isSelected: false, isLabel: false)
                currentSetC.append(day)
                currentSetE.append(day)
            }
            let weekDay = lastDCFromCurrentMonth.weekday ?? 0
            let numberOfDaysFromNextMonth = 7 - weekDay
            for index in 0..<numberOfDaysFromNextMonth {
                let date = calendar.date(from: nextMonthDC) ?? today
                let newDate = calendar.date(byAdding: .day, value: index, to: date) ?? today
                let result = calendar.compare(newDate, to: today, toGranularity: .day)
                let isToday = result == .orderedSame
                let eventList = events.filter { calendar.compare(newDate, to: $0.initialDate, toGranularity: .day) == ComparisonResult.orderedSame }
                let text = String(calendar.component(.day, from: newDate))
                let day = HubCalendarDay(text: text, date: newDate, events: eventList, isHolyday: false, currentMonth: false, isToday: isToday, isSelected: false, isLabel: false)
                currentSetC.append(day)
                currentSetE.append(day)
            }
        }
    }
}

extension HubCalendarViewModel: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isExpanded {
            if collectionView.tag == 1 {
                return currentSetE.count
            }
        } else {
            if collectionView.tag == 2 {
                return currentSetC.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier,
                                                            for: indexPath) as? DayCollectionViewCell else {
                                                                fatalError()
        }
        guard let cellSpecs = cellSpecs else {
            fatalError()
        }
        let obj = isExpanded ? currentSetE[indexPath.row] : currentSetC[indexPath.row]
        cell.colorBackgroundSelected = obj.isLabel ? .clear : cellSpecs.cellSelectedBackgroundColor
        cell.colorBackgroundNotSelected = obj.isLabel ? .clear : cellSpecs.cellCurrentBackgroundColor
        cell.colorTextSelected = obj.isLabel ? cellSpecs.labelWeekdaysTextColor : cellSpecs.cellSelectedTextColor
        cell.colorTextNotSelected = obj.isLabel ? cellSpecs.labelWeekdaysTextColor : cellSpecs.cellCurrentTextColor
        cell.showHeader(show: !isExpanded)
        cell.separator.backgroundColor = cellSpecs.separatorColor
        cell.showSeparator(show: !isExpanded || (isExpanded && (((indexPath.row + 1) % numberOfItemsPerRow) != 0)))
        let dateToShow = obj.date
//        let day = calendar.component(.day, from: dateToShow)
        let weekday = calendar.component(.weekday, from: dateToShow)
        if !isExpanded {
            cell.labelHeader.text = weekDays[weekday-1]
            cell.labelHeader.textColor = cellSpecs.labelWeekdaysTextColor
            cell.labelHeader.backgroundColor = .clear // self.stackViewWeekdaysBackgroundColor
            cell.labelHeader.font = cellSpecs.labelWeekdaysFont
            cell.labelHeader.textAlignment = .center
        }
        cell.backgroundColor = obj.isLabel ? .clear : obj.currentMonth ? cellSpecs.cellCurrentBackgroundColor : cellSpecs.cellNotCurrentBackgroundColor
        cell.labelDay.text = "\(obj.text)"
        let notTodayTextColor = obj.isLabel ? cellSpecs.labelWeekdaysTextColor : obj.isSelected ?
            cellSpecs.cellSelectedTextColor : obj.currentMonth ? cellSpecs.cellCurrentTextColor : cellSpecs.cellNotCurrentTextColor
        cell.labelDay.textColor = obj.isToday ? cellSpecs.cellTodayTextColor : notTodayTextColor
        cell.labelDay.font = obj.isLabel ? cellSpecs.labelWeekdaysFont : cellSpecs.cellFont
        cell.markerToday.backgroundColor = obj.isToday ? cellSpecs.cellTodayBackgroundColor : .clear
        cell.markerToday.layer.cornerRadius = (cell.frame.width * 0.4)
//        cell.markerSelected.backgroundColor = obj.isSelected ? cellSpecs?.cellSelectedBackgroundColor : .clear
        cell.markerSelected.layer.cornerRadius = (cell.frame.width * 0.4)
        if obj.events.count > 0 {
            if (cellSpecs.showMarkerA) {
                cell.markerEventA.isHidden = !cellSpecs.showMarkerA
                cell.markerEventA.backgroundColor = .clear
                //let borderColor = obj.currentMonth ? cellSpecs.cellCurrentTextColor : cellSpecs.cellNotCurrentTextColor
                cell.markerEventA.layer.borderColor = (obj.isToday ? .clear : cellSpecs.colorMarkerA).cgColor
                cell.markerEventA.layer.borderWidth = 1
                cell.markerEventA.layer.cornerRadius = (cell.frame.width * 0.4)
                cell.labelDay.textColor = obj.isToday ? cellSpecs.cellTodayTextColor : cellSpecs.colorMarkerA
            } else if (cellSpecs.showMarkerB) {
                cell.markerEventB.isHidden = !cellSpecs.showMarkerB
                cell.markerEventB.backgroundColor = cellSpecs.colorMarkerB
                cell.markerEventB.layer.cornerRadius = (cell.frame.width * 0.10)
            }
        } else {
            cell.markerEventA.isHidden = true
            cell.markerEventB.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = isExpanded ? currentSetE[indexPath.row] : currentSetC[indexPath.row]
        delegate?.onPressDate(date: day.date, events: day.events)
    }
}
