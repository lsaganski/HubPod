//
//  HubCalendarEvent.swift
//  HubPod
//
//  Created by Mac on 20/12/19.
//  Copyright © 2019 ItauBBA. All rights reserved.
//

import Foundation

public struct HubCalendarEvent {
    public let date: Date
    public let title: String
    public let description: String
    public init(date: Date = Date(), title: String = "", description: String = ""){
        self.date = date
        self.title = title
        self.description = description
    }
}
