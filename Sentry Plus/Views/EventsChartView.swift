//
//  EventsChartView.swift
//  Sentry Plus
//
//  Created by Onur Altun on 19.04.2024.
//

import SwiftUI
import Charts

struct SentryEvent: Identifiable {
    var eventDate: Date
    var state: String
    var duration: Int
    var id = UUID()
}

struct EventsChartView: View {
    @State var sentryEvents: [SentryEvent] = [
        SentryEvent(eventDate: Date(), state: "off", duration: 10),
        SentryEvent(eventDate: Date().addingTimeInterval(864), state: "online", duration: 20),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 2), state: "off", duration: 30),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 3), state: "online", duration: 40),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 4), state: "Aware", duration: 10),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 5), state: "online", duration: 60),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 6), state: "Aware", duration: 2),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 7), state: "online", duration: 10),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 8), state: "off", duration: 10),
        SentryEvent(eventDate: Date().addingTimeInterval(864 * 9), state: "online", duration: 10),
    ]

    let vin: String?
    
    var body: some View {
        Chart(sentryEvents, id: \.eventDate) { element in
          BarMark(
            x: .value("Date", element.eventDate),
            width: MarkDimension(integerLiteral: element.duration),
            stacking: MarkStackingMethod.unstacked
          )
          .foregroundStyle(by: .value("State", element.state))
        }
    }
}

struct EventsChartView_Previews: PreviewProvider {
    static var previews: some View {
        EventsChartView(vin: nil)
    }
}
