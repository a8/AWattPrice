//
//  EnergyPriceSingleBar.swift
//  AWattPrice
//
//  Created by Léon Becker on 14.11.20.
//

import SwiftUI


/// Calculates multiple sizes which are needed to draw a single price bar.
/// - Returns: (Start height of bar,
///             is selected identifier,
///             height of the bar,
///             font size of the text,
///             font weight of the text)
func calcSingleBarSizes(_ indexSelected: Int?, _ startHeight: CGFloat,  _ ownIndex: Int, _ maxIndex: Int, _ height: CGFloat) -> (CGFloat, Int16, CGFloat, CGFloat, Font.Weight) {
    
    var height = height
    var isSelected: Int16 = 0
    var resultStartHeight: CGFloat = 0
    let barSpacingWhenSelected = 40 / Double(maxIndex - 2)
    var fontSize: CGFloat = 0
    var fontWeight: Font.Weight = .regular

    if indexSelected != nil {
        if indexSelected == ownIndex {
            isSelected = 1
        } else if ownIndex == indexSelected! - 1 || ownIndex == indexSelected! + 1 {
            isSelected = 2
        } else {
            isSelected = 0
        }
        
        if isSelected == 0 {
            height -= CGFloat(barSpacingWhenSelected)
            
            if ownIndex > indexSelected! {
                resultStartHeight += CGFloat(barSpacingWhenSelected * Double(maxIndex - (ownIndex - 1)))
            } else if ownIndex < indexSelected! {
                resultStartHeight -= CGFloat(Double(ownIndex) * barSpacingWhenSelected)
            }
        }
        
        if isSelected == 1 {
            resultStartHeight += 10
            resultStartHeight -= CGFloat(Double(ownIndex - 1) * barSpacingWhenSelected)
        }
        
        if isSelected == 2 {
            if ownIndex > indexSelected! {
                resultStartHeight += 30
                resultStartHeight -= CGFloat(Double(ownIndex - 2) * barSpacingWhenSelected)
            } else {
                resultStartHeight -= CGFloat(Double(ownIndex) * barSpacingWhenSelected)
            }
        }
    } else {
        isSelected = 0
    }

    if isSelected == 1 {
        height += 20
        resultStartHeight += startHeight
        
        fontSize = 17
        fontWeight = .bold
    } else if isSelected == 2 {
        height += 10
        resultStartHeight += startHeight
        
        fontSize = 11
        fontWeight = .semibold
    } else {
        resultStartHeight += startHeight
        fontSize = 8
        fontWeight = .regular
    }

    return (resultStartHeight, isSelected, height, fontSize, fontWeight)
}

/**
 A single bar with a certain length (representing the energy cost for this hour relative to other hours) and text which again shows the energy cost for this hour but helps to also show the energy price information in more legible and more accurate form.
 */
struct EnergyPriceSingleBar: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var currentSetting: CurrentSetting

    static func getPriceString(marketprice: Double, currentSetting: CurrentSetting) -> String {
        let centFormatter = NumberFormatter()
        centFormatter.numberStyle = .currency
        centFormatter.currencySymbol = "ct"
        centFormatter.maximumFractionDigits = 2
        centFormatter.minimumFractionDigits = 2
        
        if currentSetting.entity!.pricesWithTaxIncluded {
            return centFormatter.string(from: NSNumber(value: marketprice * currentSetting.currentVATToUse)) ?? "NaN"
        } else {
            return centFormatter.string(from: NSNumber(value: marketprice)) ?? "NaN"
        }
    }
    
    let fontSize: CGFloat
    let fontWeight: Font.Weight
    let singleBarSettings: SingleBarSettings
    let width: CGFloat
    let startWidthPadding: CGFloat // Padding to the left side
    var height: CGFloat
    var startHeight: CGFloat
    let isSelected: Int16 // 0 if not selected and 1 if main selected and 2 if co-selected (bars around the selected bar)
    let hourDataPoint: EnergyPricePoint

    init(singleBarSettings: SingleBarSettings,
         width: CGFloat,
         height: CGFloat,
         startHeight: CGFloat,
         indexSelected: Int?,
         ownIndex: Int,
         maxIndex: Int,
         hourDataPoint: EnergyPricePoint) {
        
        self.singleBarSettings = singleBarSettings

        if singleBarSettings.minPrice != 0 {
            self.startWidthPadding = 8 // Set padding to the left side
            self.width = width - 16 // Set padding to the right side
        } else {
            self.startWidthPadding = 3
            self.width = width - 19
        }
                
        let results = calcSingleBarSizes(indexSelected, startHeight, ownIndex, maxIndex, height)
        self.startHeight = results.0
        self.isSelected = results.1
        self.height = results.2
        self.fontSize = results.3
        self.fontWeight = results.4
        
        self.hourDataPoint = hourDataPoint
    }

    var body: some View {
        let maximalNegativePriceBarWidth = (
            singleBarSettings.minPrice == 0
                ? startWidthPadding : CGFloat(abs(singleBarSettings.minPrice) / (abs(singleBarSettings.minPrice) + abs(singleBarSettings.maxPrice))) * width + startWidthPadding)

        let negativePriceBarWidth = (
            singleBarSettings.minPrice != 0
                ? CGFloat(abs(hourDataPoint.marketprice) / (abs(singleBarSettings.minPrice) + abs(singleBarSettings.maxPrice))) * width : 0)

        let positivePriceBarWidth = (
            singleBarSettings.maxPrice != 0
                ? CGFloat(abs(hourDataPoint.marketprice) / (abs(singleBarSettings.minPrice) + abs(singleBarSettings.maxPrice))) * width + maximalNegativePriceBarWidth : 0)

        let currentDividerLineWidth: CGFloat = (
            maximalNegativePriceBarWidth == 0 ? 0 : 1
        )

        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
            // Draw the bar shape
            
            if hourDataPoint.marketprice > 0 {
                BarShape(isSelected: (isSelected == 1 ? true : false), startWidth: maximalNegativePriceBarWidth, startHeight: startHeight, widthOfBar: positivePriceBarWidth + currentDividerLineWidth, heightOfBar: height, lookToSide: .right)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(hue: 0.0849, saturation: 0.6797, brightness: 0.9059), Color(hue: 0.9978, saturation: 0.7163, brightness: 0.8431)]), startPoint: .leading, endPoint: .trailing))
            } else if hourDataPoint.marketprice < 0 {
                BarShape(isSelected: (isSelected == 1 ? true : false), startWidth: maximalNegativePriceBarWidth, startHeight: startHeight, widthOfBar: maximalNegativePriceBarWidth - negativePriceBarWidth, heightOfBar: height, lookToSide: .left)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.gray]), startPoint: .leading, endPoint: .trailing))
            }

            // If there are negative energy price values a vergtical divider line shape is displayed to mark the point where costs go from positive values to negative values
            if maximalNegativePriceBarWidth - startWidthPadding != 0 {
                VerticalDividerLineShape(width: currentDividerLineWidth, height: height, startWidth: maximalNegativePriceBarWidth, startHeight: startHeight)
                    .foregroundColor(colorScheme == .light ? Color.black : Color.white)
            }

            // Show the energy price as text with or without VAT/tax included
            Text(EnergyPriceSingleBar.getPriceString(marketprice: hourDataPoint.marketprice, currentSetting: currentSetting))
            .foregroundColor(Color.black)
            .animatableFont(size: fontSize + 1, weight: fontWeight)
            .padding(1)
                .padding([.leading, .trailing], (isSelected == 1 || isSelected == 2) ? 2 : 1)
                .background(
                    RoundedRectangle(cornerRadius: (isSelected == 1 || isSelected == 2) ? 3 : 2)
                        .fill(Color.clear)
                        .background(Color.white)
                        .cornerRadius((isSelected == 1 || isSelected == 2) ? 3 : 2)
                )
            .position(x: ((isSelected == 1 || isSelected == 2) ?  startWidthPadding + 25 + fontSize : startWidthPadding + 20), y: startHeight + (height / 2))

            // Show start to end time of the hour in which the certain energy price applies
            HStack(spacing: 5) {
                Text(singleBarSettings.hourFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(hourDataPoint.startTimestamp))))
                Text("-")
                Text(singleBarSettings.hourFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(hourDataPoint.endTimestamp))))
            }
            .foregroundColor(Color.black)
            .animatableFont(size: fontSize + 2, weight: fontWeight)
            .padding(1)
            .padding([.leading, .trailing], (isSelected == 1 || isSelected == 2) ? 2 : 1)
            .background(
                RoundedRectangle(cornerRadius: (isSelected == 1 || isSelected == 2) ? 3 : 2)
                    .fill(Color.clear)
                    .background(Color.white)
                    .cornerRadius((isSelected == 1 || isSelected == 2) ? 3 : 2)
            )
            .position(x: ((isSelected == 1 || isSelected == 2) ? width - 20 - fontSize : width - 20), y: startHeight + (height / 2))
        }
    }
}
