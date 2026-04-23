//
//  ContentView.swift
//  declock
//
//  Created by fukuyori on 2026/04/23.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ContentView: View {
    private let baseClockSize: CGFloat = 220

    var body: some View {
        GeometryReader { geometry in
            let clockSize = min(geometry.size.width, geometry.size.height)
            let scale = clockSize / baseClockSize

            TimelineView(.animation) { timeline in
                AnalogClockFrameView(currentDate: timeline.date)
                    .frame(width: baseClockSize, height: baseClockSize)
                    .scaleEffect(scale)
                    .frame(width: clockSize, height: clockSize)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(minWidth: 160, minHeight: 160)
        .aspectRatio(1, contentMode: .fit)
        .background(Color.clear)
        #if os(macOS)
        .background(ClockWindowConfigurator())
        #endif
    }
}

#if os(macOS)
struct ClockWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        DispatchQueue.main.async {
            configure(window: view.window)
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configure(window: nsView.window)
        }
    }

    private func configure(window: NSWindow?) {
        guard let window else { return }
        window.isOpaque = false
        window.backgroundColor = .clear
        window.contentAspectRatio = NSSize(width: 1, height: 1)
        window.contentMinSize = NSSize(width: 160, height: 160)
    }
}
#endif

struct AnalogClockFrameView: View {
    let currentDate: Date

    private let majorTickCount = 5

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.16, green: 0.13, blue: 0.10),
                            Color(red: 0.45, green: 0.34, blue: 0.22),
                            Color(red: 0.12, green: 0.09, blue: 0.07)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.6)
                .padding(4)

            Circle()
                .fill(Color(red: 0.96, green: 0.94, blue: 0.87))
                .padding(9)

            Circle()
                .strokeBorder(Color(red: 0.28, green: 0.22, blue: 0.15).opacity(0.22), lineWidth: 0.8)
                .padding(16)

            mediumTicks
                .padding(24)

            minorTicks
                .padding(28)

            majorTicks
                .padding(23)

            numerals
                .padding(44)

            mediumNumerals
                .padding(58)

            Circle()
                .strokeBorder(Color(red: 0.63, green: 0.49, blue: 0.28).opacity(0.42), lineWidth: 0.6)
                .padding(50)

            HourHand(angle: hourHandAngle(for: currentDate))
                .padding(48)

            MinuteHand(angle: minuteHandAngle(for: currentDate))
                .padding(34)

            SecondHand(angle: secondHandAngle(for: currentDate))
                .padding(56)

            Circle()
                .fill(Color(red: 0.18, green: 0.13, blue: 0.09))
                .frame(width: 13, height: 13)
                .overlay {
                    Circle()
                        .strokeBorder(Color(red: 0.92, green: 0.74, blue: 0.38).opacity(0.45), lineWidth: 1)
                }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel("丸いアナログ時計の枠")
    }

    private var majorTicks: some View {
        ForEach(0..<majorTickCount, id: \.self) { index in
            TickMark(width: 3.5, height: 16)
                .fill(Color(red: 0.25, green: 0.19, blue: 0.12))
                .rotationEffect(.degrees(Double(index) * 360 / Double(majorTickCount)))
        }
    }

    private var mediumTicks: some View {
        ForEach(0..<majorTickCount, id: \.self) { index in
            TickMark(width: 2.2, height: 11)
                .fill(Color(red: 0.29, green: 0.22, blue: 0.14).opacity(0.82))
                .rotationEffect(.degrees((Double(index) + 0.5) * 360 / Double(majorTickCount)))
        }
    }

    private var minorTicks: some View {
        ForEach(0..<(majorTickCount * 2), id: \.self) { index in
            TickMark(width: 1.1, height: 6)
                .fill(Color(red: 0.30, green: 0.24, blue: 0.17).opacity(0.58))
                .rotationEffect(.degrees((Double(index) + 0.5) * 360 / Double(majorTickCount * 2)))
        }
    }

    private var numerals: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ForEach(0..<majorTickCount, id: \.self) { number in
                let angle = Angle.degrees(Double(number) * 360 / Double(majorTickCount) - 90)
                let position = CGPoint(
                    x: center.x + cos(angle.radians) * radius * 0.92,
                    y: center.y + sin(angle.radians) * radius * 0.92
                )

                Text("\(number)")
                    .font(.system(size: 23, weight: .semibold, design: .serif))
                    .foregroundStyle(Color(red: 0.24, green: 0.18, blue: 0.11))
                    .position(position)
            }
        }
    }

    private var mediumNumerals: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let labels = [10, 30, 50, 70, 90]

            ForEach(labels.indices, id: \.self) { index in
                let angle = Angle.degrees((Double(index) + 0.5) * 360 / Double(majorTickCount) - 90)
                let position = CGPoint(
                    x: center.x + cos(angle.radians) * radius * 1.15,
                    y: center.y + sin(angle.radians) * radius * 1.15
                )

                Text("\(labels[index])")
                    .font(.system(size: 11, weight: .medium, design: .serif))
                    .foregroundStyle(Color(red: 0.31, green: 0.23, blue: 0.15).opacity(0.76))
                    .position(position)
            }
        }
    }

    private func hourHandAngle(for date: Date) -> Angle {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let elapsedSeconds = date.timeIntervalSince(startOfDay)
        let secondsPerDay: TimeInterval = 24 * 60 * 60
        let rotationsPerDay = 2.0

        return .degrees(elapsedSeconds / secondsPerDay * rotationsPerDay * 360)
    }

    private func minuteHandAngle(for date: Date) -> Angle {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let elapsedSeconds = date.timeIntervalSince(startOfDay)
        let secondsPerDay: TimeInterval = 24 * 60 * 60
        let rotationsPerDay = 10.0

        return .degrees(elapsedSeconds / secondsPerDay * rotationsPerDay * 360)
    }

    private func secondHandAngle(for date: Date) -> Angle {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let elapsedSeconds = date.timeIntervalSince(startOfDay)
        let secondsPerDay: TimeInterval = 24 * 60 * 60
        let rotationsPerDay = 1000.0

        return .degrees(elapsedSeconds / secondsPerDay * rotationsPerDay * 360)
    }
}

struct HourHand: View {
    let angle: Angle

    var body: some View {
        GeometryReader { geometry in
            let handWidth: CGFloat = 8
            let handLength = min(geometry.size.width, geometry.size.height) * 0.34
            let tailLength = min(geometry.size.width, geometry.size.height) * 0.08

            ZStack {
                Capsule()
                    .fill(Color(red: 0.15, green: 0.10, blue: 0.06))
                    .frame(width: handWidth, height: handLength)
                    .offset(y: -handLength / 2)

                Capsule()
                    .fill(Color(red: 0.15, green: 0.10, blue: 0.06))
                    .frame(width: handWidth * 0.7, height: tailLength)
                    .offset(y: tailLength / 2)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .rotationEffect(angle)
        }
    }
}

struct MinuteHand: View {
    let angle: Angle

    var body: some View {
        GeometryReader { geometry in
            let handWidth: CGFloat = 4.5
            let handLength = min(geometry.size.width, geometry.size.height) * 0.42
            let tailLength = min(geometry.size.width, geometry.size.height) * 0.10

            ZStack {
                Capsule()
                    .fill(Color(red: 0.48, green: 0.29, blue: 0.12))
                    .frame(width: handWidth, height: handLength)
                    .offset(y: -handLength / 2)

                Capsule()
                    .fill(Color(red: 0.48, green: 0.29, blue: 0.12))
                    .frame(width: handWidth * 0.8, height: tailLength)
                    .offset(y: tailLength / 2)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .rotationEffect(angle)
        }
    }
}

struct SecondHand: View {
    let angle: Angle

    var body: some View {
        GeometryReader { geometry in
            let handWidth: CGFloat = 2
            let handLength = min(geometry.size.width, geometry.size.height) * 0.47

            ZStack {
                RoundedRectangle(cornerRadius: handWidth / 2)
                    .fill(Color(red: 0.70, green: 0.20, blue: 0.10))
                    .frame(width: handWidth, height: handLength)
                    .offset(y: -handLength / 2)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .rotationEffect(angle)
        }
    }
}

struct TickMark: Shape {
    let width: CGFloat
    let height: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let centerX = rect.midX
        let topY = rect.minY

        path.addRoundedRect(
            in: CGRect(
                x: centerX - width / 2,
                y: topY,
                width: width,
                height: height
            ),
            cornerSize: CGSize(width: width / 2, height: width / 2)
        )

        return path
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
