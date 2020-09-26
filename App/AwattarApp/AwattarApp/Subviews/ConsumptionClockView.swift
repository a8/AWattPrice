//
//  ConsumptionClockView.swift
//  AwattarApp
//
//  Created by Léon Becker on 25.09.20.
//

import SwiftUI

struct ConsumptionClockView: View {
    @State var currentLevel = 0
    @State var now = Date()
    
    let calendar = Calendar.current
    
    var hourDegree = (0, 0)
    
    init(cheapestHour: CheapestHourCalculator.HourPair) {
        // 15 degrees is the angle for one single hour

        let minItemIndex = 0
        let maxItemIndex = cheapestHour.associatedPricePoints.count - 1
        
        if cheapestHour.associatedPricePoints.count >= 2 {
            let startDegree = (30 * calendar.component(.hour, from: Date(timeIntervalSince1970: TimeInterval(cheapestHour.associatedPricePoints[minItemIndex].startTimestamp / 1000)))) - 90
            let endDegree = (30 * calendar.component(.hour, from: Date(timeIntervalSince1970: TimeInterval(cheapestHour.associatedPricePoints[maxItemIndex].endTimestamp / 1000)))) - 90
            
            // Subtract 90 degrees because actual 0 degree is at 90th degree
            
            hourDegree = (startDegree, endDegree)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.makeView(geometry)
        }
    }
    
    func makeView(_ geometry: GeometryProxy) -> some View {
        let width = geometry.size.width
        let height = geometry.size.height
        
        let circleLineWidth = CGFloat(2)
        let hourIndicatorLineWidth = CGFloat(3)
        let middlePointRadius = CGFloat(3)
        let hourMarkerLineWidth = CGFloat(4)
        
        let clockWidth = 2 * (width / 5)
        let hourBorderIndicatorWidth = CGFloat(4)
        let hourMarkerRadius = CGFloat(0.75 * (((clockWidth / 2) - circleLineWidth)))
        let minuteIndicatorWidth = CGFloat((clockWidth / 2) - hourBorderIndicatorWidth - 10)
        let hourIndicatorWidth = CGFloat((2 * ((clockWidth / 2) / 3)) - hourBorderIndicatorWidth  - 10)
        
        let clockRightSideStartWidth = ((width - clockWidth) / 2)
        let clockStartHeight = (height / 2) - (width / 2) + clockRightSideStartWidth
        
        let textPaddingToClock = CGFloat(15)
        let threeTextPaddingToClockAddition = CGFloat(3)

        let center = CGPoint(x: width / 2, y: height / 2)
        
        var hourNamesAndPositions = [(String, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)]()
        var currentDegree: Double = -60
        
        let currentMinute = Double(calendar.component(.minute, from: now))
        let currentMinuteXCoord = CGFloat(Double(minuteIndicatorWidth) * sin((6 * currentMinute * Double.pi) / 180)) + clockRightSideStartWidth + (clockWidth / 2)
        let currentMinuteYCoord = CGFloat(Double(minuteIndicatorWidth) * -cos((6 * currentMinute * Double.pi) / 180)) + clockStartHeight + (clockWidth / 2)
        
        var currentHour = Double(calendar.component(.hour, from: now))
        currentHour += (currentMinute / 60) // Add minutes
        
        if currentHour > 12 {
            currentHour -= 12
        }
        let currentHourXCoord = CGFloat(Double(hourIndicatorWidth) * sin((30 * currentHour * Double.pi) / 180)) + clockRightSideStartWidth + (clockWidth / 2)
        let currentHourYCoord = CGFloat(Double(hourIndicatorWidth) * -cos((30 * currentHour * Double.pi) / 180)) + clockStartHeight + (clockWidth / 2)
        
        for hourName in 1...12 {
            // Text
            let xCoordTextDiff = CGFloat(Double(clockWidth / 2) * cos(currentDegree * Double.pi / 180))
            let yCoordTextDiff = CGFloat(Double(clockWidth / 2) * sin(currentDegree * Double.pi / 180))
            
            var currentXCoordTextPadding: CGFloat = 0
            var currentYCoordTextPadding: CGFloat = 0
            
            if [1, 2, 3, 4, 5].contains(hourName) {
                currentXCoordTextPadding = textPaddingToClock
                
                if hourName == 3 {
                    currentXCoordTextPadding += threeTextPaddingToClockAddition
                }
            } else if [7, 8, 9, 10, 11].contains(hourName) {
                currentXCoordTextPadding = -textPaddingToClock
                
                if hourName == 9 {
                    currentXCoordTextPadding -= threeTextPaddingToClockAddition
                }
            }
            
            if [1, 2, 10, 11, 12].contains(hourName) {
                currentYCoordTextPadding = -textPaddingToClock
                
                if hourName == 12 {
                    currentYCoordTextPadding -= threeTextPaddingToClockAddition
                }
            } else if [4, 5, 6, 7, 8].contains(hourName) {
                currentYCoordTextPadding = textPaddingToClock
                
                if hourName == 6 {
                    currentYCoordTextPadding += threeTextPaddingToClockAddition
                }
            }
            
            let textXCoord = clockRightSideStartWidth + (clockWidth / 2) + currentXCoordTextPadding + xCoordTextDiff
            let textYCoord = clockStartHeight + (clockWidth / 2) + currentYCoordTextPadding + yCoordTextDiff
            
            // Lines
            let lineFirstXCoord = CGFloat(Double(clockWidth / 2 - circleLineWidth + hourBorderIndicatorWidth) * cos(currentDegree * Double.pi / 180)) + clockRightSideStartWidth + (clockWidth / 2)
            
            let lineFirstYCoord = CGFloat(Double(clockWidth / 2 - circleLineWidth + hourBorderIndicatorWidth) * sin(currentDegree * Double.pi / 180)) + clockStartHeight + (clockWidth / 2)
            
            let lineSecondXCoord = CGFloat(Double(clockWidth / 2 - hourBorderIndicatorWidth - circleLineWidth) * cos(currentDegree * Double.pi / 180)) + clockRightSideStartWidth + (clockWidth / 2)
            
            let lineSecondYCoord = CGFloat(Double(clockWidth / 2 - hourBorderIndicatorWidth - circleLineWidth) * sin(currentDegree * Double.pi / 180)) + clockStartHeight + (clockWidth / 2)
            
            hourNamesAndPositions.append((String(hourName), textXCoord, textYCoord, lineFirstXCoord, lineFirstYCoord, lineSecondXCoord, lineSecondYCoord))
            
            currentDegree += 30
        }
        
        return ZStack {
            Path { path in
                path.addArc(center: center, radius: (clockWidth / 2) - circleLineWidth, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
                path.addArc(center: center, radius: clockWidth / 2, startAngle: .degrees(360), endAngle: .degrees(0), clockwise: true)
            }
            .foregroundColor(Color.black)

            Path { path in
                path.addArc(center: center, radius: middlePointRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
            }
            .fill(Color.black)

            ForEach(hourNamesAndPositions, id: \.0) { hour in
                Text(hour.0)
                    .position(x: hour.1, y: hour.2)
                
                Path { path in
                    path.move(to: CGPoint(x: hour.3, y: hour.4))
                    path.addLine(to: CGPoint(x: hour.5, y: hour.6))
                }
                .strokedPath(.init(lineWidth: hourIndicatorLineWidth, lineCap: .round))
            }
            
            Path { path in
                path.addArc(center: center, radius: hourMarkerRadius, startAngle: .degrees(Double(hourDegree.0)), endAngle: .degrees(Double(hourDegree.1)), clockwise: false)
            }
            .strokedPath(.init(lineWidth: hourMarkerLineWidth, lineCap: .round))
            .foregroundColor(Color.green)

            Path { path in
                path.move(to: center)
                path.addLine(to: CGPoint(x: currentMinuteXCoord, y: currentMinuteYCoord))
            }
            .strokedPath(.init(lineWidth: 5, lineCap: .round))
            .foregroundColor(Color.black)
            
            Path { path in
                path.move(to: center)
                path.addLine(to: CGPoint(x: currentHourXCoord, y: currentHourYCoord))
            }
            .strokedPath(.init(lineWidth: 5, lineCap: .round))
            .foregroundColor(Color.black)

            Text(currentMinute.description)
                .offset(y: -130)
            Text(currentHour.description)
                .offset(y: -170)
            
        }
    }
}

struct ConsumptionClockView_Previews: PreviewProvider {
    static var previews: some View {
        ConsumptionClockView(cheapestHour: CheapestHourCalculator.HourPair(associatedPricePoints: [EnergyPricePoint(startTimestamp: 1601082000000, endTimestamp: 1601085600000, marketprice: 3, unit: ["Eur / MWh", "Eur / kWh"]), EnergyPricePoint(startTimestamp: 1601085600000, endTimestamp: 1601089200000, marketprice: 9, unit: ["Eur / MWh", "Eur / kWh"])]))
    }
}
