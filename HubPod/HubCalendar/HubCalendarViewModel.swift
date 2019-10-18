//
//  HubCalendarViewModel.swift
//  HubPod
//
//  Created by Leonardo Saganski on 25/09/19.
//  Copyright © 2019 ItauBBA. All rights reserved.
//

import Foundation
import UIKit

struct HubCalendarEvent {
    let date: Date
    let title: String
    let description: String
}

struct HubCalendarDay {
    let date: Date
    let events: [HubCalendarEvent]
    let isHolyday: Bool
    let currentMonth: Bool
    let isToday: Bool
    var isSelected: Bool
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
}

protocol HubCalendarViewModelDelegate: AnyObject {
    func updateLabelMonth(text: String)
    func onPressDate(date: Date)
    func onReloadData()
}

class HubCalendarViewModel: NSObject {
    var currentSet: [HubCalendarDay] = []
    var events: [HubCalendarEvent] = []
    //        [
    //        HubCalendarEvent(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, title: "Aniversário", description: "Festa de aniversário do Joao."),
    //        HubCalendarEvent(date: Calendar.current.date(byAdding: .day, value: 6, to: Date())!, title: "Reunião", description: "Reunião com a diretoria."),
    //        HubCalendarEvent(date: Calendar.current.date(byAdding: .day, value: 9, to: Date())!, title: "Viagem", description: "Viagem para Florianópolis."),
    //        HubCalendarEvent(date: Calendar.current.date(byAdding: .day, value: 12, to: Date())!, title: "Inauguração", description: "Inauguração da nova filial em Curitiba."),
    //        HubCalendarEvent(date: Calendar.current.date(byAdding: .day, value: 15, to: Date())!, title: "Apresentação", description: "Apresentação dos resultados do mês."),
    //    ]
    var viewController: UIViewController?
    var delegate: HubCalendarViewModelDelegate?
    // Data
    let weekDays = ["S", "M", "T", "W", "T", "F", "S"]
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let cellReuseIdentifier = "calendarCell"
    var calendar: Calendar { return Calendar.current }
    var currentDate: Date = Date()
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
        let month = self.calendar.component(.month, from: self.currentDate)
        let year = self.calendar.component(.year, from: self.currentDate)
        self.labelMonth = "\(self.months[month-1]) \(year)"
        self.currentMonthDC = calendar.dateComponents(self.requestedComponents, from: self.currentDate)
        self.currentMonthDC.setValue(1, for: .day)
        let date = calendar.date(from: self.currentMonthDC) ?? Date()
        self.currentMonthDC = calendar.dateComponents(self.requestedComponents, from: date)
        let newPriorDate = calendar.date(byAdding: .day, value: -1, to: date) ?? Date()
        self.priorMonthDC = calendar.dateComponents(self.requestedComponents, from: newPriorDate)
        let newNextDate = calendar.date(byAdding: .month, value: 1, to: date) ?? Date()
        self.nextMonthDC = calendar.dateComponents(self.requestedComponents, from: newNextDate)
    }
    
    func loadDaysFromPriorCurrentAndNextMonths() {
        if var numberOfDaysFromLastMonth = self.currentMonthDC.weekday {
            numberOfDaysFromLastMonth -= 1
            self.currentSet = []
            for index in stride(from: numberOfDaysFromLastMonth, to: 0, by: -1) {
                let date = calendar.date(from: self.priorMonthDC) ?? Date()
                let newDate = calendar.date(byAdding: .day, value: -(index-1), to: date) ?? Date()
                let result = calendar.compare(newDate, to: Date(), toGranularity: .day)
                let isToday = result == .orderedSame
                let eventList = events.filter { calendar.compare(newDate, to: $0.date, toGranularity: .day) == ComparisonResult.orderedSame }
                let day = HubCalendarDay(date: newDate, events: eventList, isHolyday: false, currentMonth: false, isToday: isToday, isSelected: false)
                self.currentSet.append(day)
            }
            let date = calendar.date(from: self.nextMonthDC) ?? Date()
            let lastDateFromCurrentMonth = calendar.date(byAdding: .day, value: -1, to: date) ?? Date()
            let lastDCFromCurrentMonth = calendar.dateComponents(self.requestedComponents, from: lastDateFromCurrentMonth)
            let day = lastDCFromCurrentMonth.day ?? 0
            for index in 0..<day {
                let date = calendar.date(from: self.currentMonthDC) ?? Date()
                let newDate = calendar.date(byAdding: .day, value: index, to: date) ?? Date()
                let result = calendar.compare(newDate, to: Date(), toGranularity: .day)
                let isToday = result == .orderedSame
                let eventList = events.filter { calendar.compare(newDate, to: $0.date, toGranularity: .day) == ComparisonResult.orderedSame }
                let day = HubCalendarDay(date: newDate, events: eventList, isHolyday: false, currentMonth: true, isToday: isToday, isSelected: false)
                self.currentSet.append(day)
            }
            let weekDay = lastDCFromCurrentMonth.weekday ?? 0
            let numberOfDaysFromNextMonth = 7 - weekDay
            for index in 0..<numberOfDaysFromNextMonth {
                let date = calendar.date(from: self.nextMonthDC) ?? Date()
                let newDate = calendar.date(byAdding: .day, value: index, to: date) ?? Date()
                let result = calendar.compare(newDate, to: Date(), toGranularity: .day)
                let isToday = result == .orderedSame
                let eventList = events.filter { calendar.compare(newDate, to: $0.date, toGranularity: .day) == ComparisonResult.orderedSame }
                let day = HubCalendarDay(date: newDate, events: eventList, isHolyday: false, currentMonth: false, isToday: isToday, isSelected: false)
                self.currentSet.append(day)
            }
        }
    }
}

extension HubCalendarViewModel: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isExpanded {
            if collectionView.tag == 1 {
                return currentSet.count
            }
        } else {
            if collectionView.tag == 2 {
                return currentSet.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier,
                                                            for: indexPath) as? DayCollectionViewCell else {
                                                                fatalError()
        }
        cell.colorBackgroundSelected = cellSpecs?.cellSelectedBackgroundColor
        cell.colorBackgroundNotSelected = cellSpecs?.cellCurrentBackgroundColor
        cell.colorTextSelected = cellSpecs?.cellSelectedTextColor
        cell.colorTextNotSelected = cellSpecs?.cellCurrentTextColor
        cell.showHeader(show: !isExpanded)
        cell.separator.backgroundColor = cellSpecs?.separatorColor
        cell.showSeparator(show: !isExpanded || (isExpanded && (((indexPath.row + 1) % numberOfItemsPerRow) != 0)))
        let obj = currentSet[indexPath.row]
        let dateToShow = obj.date
        let day = calendar.component(.day, from: dateToShow)
        let weekday = calendar.component(.weekday, from: dateToShow)
        if !isExpanded {
            cell.labelHeader.text = weekDays[weekday-1]
            cell.labelHeader.textColor = cellSpecs?.labelWeekdaysTextColor
            cell.labelHeader.backgroundColor = .clear // self.stackViewWeekdaysBackgroundColor
            cell.labelHeader.font = cellSpecs?.labelWeekdaysFont
            cell.labelHeader.textAlignment = .center
        }
        cell.backgroundColor = obj.currentMonth ? cellSpecs?.cellCurrentBackgroundColor : cellSpecs?.cellNotCurrentBackgroundColor
        cell.labelDay.text = "\(day)"
        let notTodayTextColor = obj.isSelected ?
            cellSpecs?.cellSelectedTextColor : obj.currentMonth ? cellSpecs?.cellCurrentTextColor : cellSpecs?.cellNotCurrentTextColor
        cell.labelDay.textColor = obj.isToday ? cellSpecs?.cellTodayTextColor : notTodayTextColor
        cell.labelDay.font = cellSpecs?.cellFont
        cell.markerToday.backgroundColor = obj.isToday ? cellSpecs?.cellTodayBackgroundColor : .clear
        cell.markerToday.layer.cornerRadius = (cell.frame.width * 0.4)
//        cell.markerSelected.backgroundColor = obj.isSelected ? cellSpecs?.cellSelectedBackgroundColor : .clear
        cell.markerSelected.layer.cornerRadius = (cell.frame.width * 0.4)
        if obj.events.count > 0 {
            cell.markerEventA.isHidden = false
            cell.markerEventB.isHidden = false
            cell.markerEventA.backgroundColor = .clear
            let borderColor = obj.currentMonth ? cellSpecs?.cellCurrentTextColor : cellSpecs?.cellNotCurrentTextColor
            cell.markerEventA.layer.borderColor = (obj.isToday ? .clear : borderColor)?.cgColor
            cell.markerEventA.layer.borderWidth = 1
            cell.markerEventA.layer.cornerRadius = (cell.frame.width * 0.4)
            cell.markerEventB.backgroundColor = cellSpecs?.cellTodayBackgroundColor
            cell.markerEventB.layer.cornerRadius = (cell.frame.width * 0.10)
        } else {
            cell.markerEventA.isHidden = true
            cell.markerEventB.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var day = currentSet[indexPath.row]
       // day.isSelected = true
//        currentSet[indexPath.row].isSelected = true
//        collectionView.reloadData()
//        if let cell = collectionView.cellForItem(at: indexPath) as? DayCollectionViewCell {
//            cell.markerSelected.backgroundColor = cellSpecs?.cellSelectedBackgroundColor
//            cell.labelDay.textColor = cellSpecs?.cellSelectedTextColor
//        }
        //        if day.events.count > 0 {
        delegate?.onPressDate(date: day.date)
        
        //        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//  //      var day = currentSet[indexPath.row]
//        currentSet[indexPath.row].isSelected = false
//      //  day.isSelected = false
//        collectionView.reloadData()
////        if let cell = collectionView.cellForItem(at: indexPath) as? DayCollectionViewCell {
////            cell.markerSelected.backgroundColor = .clear
////            cell.labelDay.textColor = cellSpecs?.cellCurrentTextColor
////        }
//    }
}
