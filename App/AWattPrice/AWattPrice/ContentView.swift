//
//  TabBar.swift
//  AWattPrice
//
//  Created by Léon Becker on 28.11.20.
//

import SwiftUI

/// Start of the application.
struct ContentView: View {
    @EnvironmentObject var currentSetting: CurrentSetting

    @ObservedObject var tabBarItems = TBItems()
    
    var body: some View {
        VStack {
            if currentSetting.setting != nil {
                if currentSetting.setting!.splashScreensFinished == true {
                    ZStack {
                        HomeView()
                            .opacity(tabBarItems.selectedItemIndex == 0 ? 1 : 0)
                                
                        ConsumptionComparisonView()
                            .opacity(tabBarItems.selectedItemIndex == 1 ? 1 : 0)
                            .environmentObject(tabBarItems)
                    }
                    
                    Spacer(minLength: 0)
                    
                    TabBar()
                        .environmentObject(tabBarItems)
                } else {
                    SplashScreenStartView()
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}
