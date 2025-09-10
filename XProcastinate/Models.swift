//
//  Models.swift
//  XProcrastinate
//
//  Created by Nayan Kasireddi on 8/11/25.
//

import Foundation

struct MyReminder: Codable {
    let title: String
    let date: Date
    let identifier: String
}

struct FocusSession: Codable {
    let startTime: Date
    let duration: Int // in seconds
    let taskName: String?
    
    init(startTime: Date, duration: Int, taskName: String? = nil) {
        self.startTime = startTime
        self.duration = duration
        self.taskName = taskName
    }
}
