//
//  RegionAndVatSelection.swift
//  AWattPrice
//
//  Created by Léon Becker on 21.11.20.
//

import SwiftUI

struct RegionAndVatSelection: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var currentSetting: CurrentSetting
    
    @State var selectedRegion: Int = 0
    @State var pricesWithTaxIncluded = true
    
    @State var firstAppear = true
    
    var body: some View {
        CustomInsetGroupedListItem(
            header: Text("region"),
            footer: Text("regionToGetPrices")
        ) {
            VStack(alignment: .leading, spacing: 20) {
                Picker(selection: $selectedRegion.animation(), label: Text("")) {
                    Text("🇩🇪 Germany")
                        .tag(0)
                    Text("🇦🇹 Austria")
                        .tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .ifTrue(firstAppear == false) { content in
                    content
                        .onChange(of: selectedRegion) { newRegionSelection in
                            currentSetting.changeRegionSelection(newRegionSelection: Int16(newRegionSelection))
                            
                            if newRegionSelection == 1 {
                                currentSetting.changeTaxSelection(newTaxSelection: false)
                            }
                        }
                }
                .onAppear {
                    selectedRegion = Int(currentSetting.setting!.regionSelection)
                    firstAppear = false
                }
                
                if selectedRegion == 0 {
                    HStack(spacing: 10) {
                        Text("priceWithVat")
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                        
                        Toggle(isOn: $pricesWithTaxIncluded) {
                            
                        }
                        .labelsHidden()
                        .onAppear {
                            pricesWithTaxIncluded = currentSetting.setting!.pricesWithTaxIncluded
                            firstAppear = false
                        }
                        .ifTrue(firstAppear == false) { content in
                            content
                                .onChange(of: pricesWithTaxIncluded) { newValue in
                                    currentSetting.changeTaxSelection(newTaxSelection: newValue)
                                }
                        }
                    }
                }
            }
        }
        .customBackgroundColor(colorScheme == .light ? Color(hue: 0.6667, saturation: 0.0202, brightness: 0.9886) : Color(hue: 0.6667, saturation: 0.0340, brightness: 0.1424))
    }
}

struct RegionSelection_Previews: PreviewProvider {
    static var previews: some View {
        RegionAndVatSelection()
            .environmentObject(CurrentSetting(managedObjectContext: PersistenceManager().persistentContainer.viewContext))
    }
}
