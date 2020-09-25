//
//  HourPriceInfoView.swift
//  AwattarApp
//
//  Created by Léon Becker on 09.09.20.
//

import SwiftUI

struct HourPriceInfoView: View {
    let priceDataPoint: EnergyPricePoint
    var numberFormatter: NumberFormatter
    var dateFormatter: DateFormatter
    var hourFormatter: DateFormatter
    
    var priceInMWh: String?
    var priceInkWh: String?
    
    init(priceDataPoint: EnergyPricePoint) {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        self.priceDataPoint = priceDataPoint
        
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        priceInMWh = String(format: "%.2f", priceDataPoint.marketprice)
        priceInkWh = String(format: "%.2f", (priceDataPoint.marketprice * 100) * 0.001) // Price converted from MWh to kWh
        
        hourFormatter = DateFormatter()
        hourFormatter.locale = Locale(identifier: "de_DE")
        hourFormatter.dateStyle = .none
        hourFormatter.timeStyle = .short
    }
    
    var body: some View {
        if priceInkWh != nil && priceInMWh != nil {
            let startDate = Date(timeIntervalSince1970: TimeInterval(priceDataPoint.startTimestamp / 1000))
            let endDate = Date(timeIntervalSince1970: TimeInterval(priceDataPoint.endTimestamp / 1000))
            
            VStack(spacing: 50) {
                Image("awattarLogo")
                    .resizable()
                    .scaledToFit()

                VStack(spacing: 40) {
                    VStack(spacing: 10) {
                        Text(dateFormatter.string(from: startDate))
                            .font(.title2)
                        
                        HStack {
                            Text(hourFormatter.string(from: startDate))
                                .bold()
                                .font(.headline)
                            Text("-")
                            Text(hourFormatter.string(from: endDate))
                                .bold()
                                .font(.headline)
                            Text("Uhr")
                                .bold()
                                .font(.headline)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "bolt")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.green)
                            .frame(width: 25, alignment: .center)
                        
                        Text("Strompreis: ")
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .trailing, spacing: 10) {
                                Text(priceInkWh!)
                                    .bold()
                                Text(priceInMWh!)
                                    .bold()
                            }
                            
                            VStack(alignment: .trailing, spacing: 10) {
                                Text(priceDataPoint.unit[1])
                                Text(priceDataPoint.unit[0])
                            }
                        }
                        .foregroundColor(Color.green)
                        .padding(6)
                        .background(Color.white)
                        .cornerRadius(5)
                    }
                    
                    Spacer()
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
        }
    }
}

struct HourPriceInfoView_Previews: PreviewProvider {
    static var previews: some View {
            HourPriceInfoView(priceDataPoint: EnergyPricePoint(startTimestamp: 1599674400000, endTimestamp: 1599678000000, marketprice: 29.28, unit: ["Eur / MWh", "Eur / kWh"]))
    }
}
