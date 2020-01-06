//
//  HubCalendarEvent.swift
//  HubPod
//
//  Created by Mac on 20/12/19.
//  Copyright © 2019 ItauBBA. All rights reserved.
//

import Foundation

public struct HubCalendarEvent {
    public let id: Int
    public let initialDate: Date
    public let finalDate: Date
    public let title: String
    public let description: String
    public let aux1: String
    public let aux2: String
    public let aux3: String
    public let aux4: String
    public init(id: Int = 0,
                initialDate: Date = Date(),
                finalDate: Date = Date(),
                title: String = "",
                description: String = "",
                aux1: String = "",
                aux2: String = "",
                aux3: String = "",
                aux4: String = ""
                ){
        self.id = id
        self.initialDate = initialDate
        self.finalDate = finalDate
        self.title = title
        self.description = description
        self.aux1 = aux1
        self.aux2 = aux2
        self.aux3 = aux3
        self.aux4 = aux4
    }
}
