//
// Copyright © 2022 Swift Charts Examples.
// Open Source - MIT License

import Charts
import SwiftUI

struct EventChart: View {
    @State private var selectedEvent: SentryData?
    @State private var plotWidth: CGFloat = 0

    var headerTitle: String
    var events: [SentryData]
    var chartXScaleRangeStart: Date
    var chartXScaleRangeEnd: Date
    
    let colors: [String: Color] = [
        "Off": .gray,
        "Idle": .yellow,
        "Armed": .green,
        "Aware": .red
    ]
    
    func getEventsTotalDuration(_ events: [SentryData]) -> String {
        var durationInSeconds: TimeInterval = 0
        for event in events {
            durationInSeconds += event.createdAt.distance(to: event.finishedAt ?? Date())
        }
        return getFormattedDuration(seconds: durationInSeconds)
    }

    func getFormattedDuration(seconds: Double) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute]

        return formatter.string(from: seconds) ?? "N/A"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(headerTitle)
                .font(.title3.bold())

            Chart {
                ForEach(events, id: \.createdAt) { event in
                    Plot {
                        BarMark(
                            xStart: .value("Started At", event.state == "Aware" && event.createdAt != event.finishedAt ?
                                           event.createdAt.addingTimeInterval(-600) : event.createdAt),
                            xEnd: .value("Finished At", event.finishedAt ?? Date()),
                            y: .value("State", event.state)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .foregroundStyle(getForegroundColor(state: event.state))
                        
                        if let selectedEvent, selectedEvent == event {
                            RuleMark(x: .value("Event Middle", getEventMiddle(start: selectedEvent.createdAt, end: selectedEvent.finishedAt ?? Date())))
                                .lineStyle(.init(lineWidth: 2, miterLimit: 2, dash: [2], dashPhase: 5))
                                .offset(x: (plotWidth / getEventMiddle(start: selectedEvent.createdAt, end: selectedEvent.finishedAt ?? Date()))) // Align with middle of bar
                                .annotation(position: .top) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Started at \(selectedEvent.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Text("Finished at \((selectedEvent.finishedAt ?? Date()).formatted(date: .abbreviated, time: .shortened))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Text("Duration: \(getEventsTotalDuration([selectedEvent]))")
                                            .font(.body.bold())
                                            .foregroundColor(.black)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background {
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(.white.shadow(.drop(radius: 2)))
                                    }
                                }
                        }
                    }
                    .accessibilityLabel("State: \(event.state)")
                    .accessibilityValue("Started at: \(event.createdAt.formatted(date: .abbreviated, time: .standard)), Finished at: \((event.finishedAt ?? Date()).formatted(date: .abbreviated, time: .standard))")
                }
            }
            .padding(.top, 10)
            .frame(height: 300)
            .chartXScale(domain: chartXScaleRangeStart...chartXScaleRangeEnd)
            .chartOverlay { proxy in
                GeometryReader { geoProxy in
                    Rectangle()
                        .fill(.clear).contentShape(Rectangle())
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { value in
                                    let location = value.location

                                    if let date: Date = proxy.value(atX: location.x) {
                                        if let event = events.first(where: { sentryData in
                                            date >= sentryData.createdAt && date <= (sentryData.finishedAt ?? Date())
                                        }) {
                                            self.selectedEvent = event
                                            // fixed warning
                                            self.plotWidth = proxy.plotSize.width
                                        }
                                    }
                                }
                        )
                }
            }
        }
    }

    private func getEventMiddle(start: Date, end: Date) -> Date {
        Date(timeInterval: (end.timeIntervalSince1970 - start.timeIntervalSince1970) / 2, since: start)
    }

    private func getEventMiddle(start: Date, end: Date) -> CGFloat {
        CGFloat((start.timeIntervalSince1970 + end.timeIntervalSince1970) / 2)
    }

    private func getForegroundColor(state: String) -> AnyGradient {
        if let color = colors[state] {
            return color.gradient
        }
        return Color.gray.gradient
    }
}

