//
//  EventsChartView.swift
//  Sentry Plus
//
//  Created by Onur Altun on 19.04.2024.
//

import SwiftUI
import Charts

struct EventsChartView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let vin: String?
    
    var body: some View {
        EventChart(headerTitle: "Events",
                   events: getSentryEvents(),
                   chartXScaleRangeStart: getStartOfEvents(),
                   chartXScaleRangeEnd: getEndOfEvents())
    }
    
    func getSentryEvents() -> [SentryData] {
        let firstDate = Date()
        
        var sentryEvents = [
            SentryData(vin: vin ?? "", state: "Aware", createdAt: firstDate, finishedAt: firstDate),
            SentryData(vin: vin ?? "", state: "Armed", createdAt: firstDate, finishedAt: firstDate),
            SentryData(vin: vin ?? "", state: "Idle", createdAt: firstDate, finishedAt: firstDate),
            SentryData(vin: vin ?? "", state: "Off", createdAt: firstDate, finishedAt: firstDate)
        ]
        
        if let index = self.appViewModel.sentryData.firstIndex(where: { $0.0 == vin }) {
            sentryEvents.append(contentsOf: self.appViewModel.sentryData[index].1)
            
            return sentryEvents
        } else {
            return sentryEvents
        }
    }
    
    func getStartOfEvents() -> Date {
        if let events = getSentryEvents().sorted(by: { $0.createdAt < $1.createdAt }).first {
            return events.createdAt
        } else {
            return Date()
        }
    }
    
    func getEndOfEvents() -> Date {
        if let events = getSentryEvents().sorted(by: { $0.finishedAt ?? Date() < $1.finishedAt ?? Date() }).last {
            return events.createdAt
        } else {
            return Date()
        }
    }
}

struct EventsChartView_Previews: PreviewProvider {
    static var previews: some View {
        EventsChartView(vin: nil)
    }
}
