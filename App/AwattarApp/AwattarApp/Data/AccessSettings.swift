//
//  StoreSettings.swift
//  AwattarApp
//
//  Created by Léon Becker on 12.09.20.
//

import CoreData
import Foundation

func getSetting(managedObjectContext: NSManagedObjectContext) -> Setting? {
    let fetchRequest: NSFetchRequest<Setting> = Setting.fetchRequest()
    var fetchRequestResults = [Setting]()
    
    do {
        fetchRequestResults = try managedObjectContext.fetch(fetchRequest)
    } catch {
        print("Couldn't read stored settings.")
        return nil
    }
    
    if fetchRequestResults.count == 1 {
        // Settings file was found correctly
        return fetchRequestResults[0]
        
    } else if fetchRequestResults.count == 0 {
        // No Settings object is yet created. Create a new Settings object with default values and save it to the persistent store
        let newSetting = Setting(context: managedObjectContext)
        newSetting.awattarEnergyProfileIndex = 0
        newSetting.pricesWithTaxIncluded = true
        newSetting.awattarEnergyPrice = 0
        newSetting.splashScreensFinished = false
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Error storing new settings object.")
            return nil
        }
        
        return newSetting
    } else {
        // Shouldn't happen because would mean that there are multiple Settings objects stored in the persistent storage
        // Only one should exist
        print("Multiple Settings objects found in persistent storage. This shouldn't happen with Settings objects. Will delete all Settings objects except of the last which is kept.")
        
        for x in 0...(fetchRequestResults.count - 1) {
            // Deletes all Settings objects except of the last
            if !(x == fetchRequestResults.count - 1) {
                managedObjectContext.delete(fetchRequestResults[x])
            }
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Error storing new settings object.")
            return nil
        }
        
        return fetchRequestResults[fetchRequestResults.count - 1]
    }
}

func changeTaxSelection(newTaxSelection: Bool, settingsObject: Setting, managedObjectContext: NSManagedObjectContext) {
    settingsObject.pricesWithTaxIncluded = newTaxSelection
    do {
        try managedObjectContext.save()
    } catch {
        return
    }
    
    return
}

func changeEnergyProfileIndex(newProfileIndex: Int16, settingsObject: Setting, managedObjectContext: NSManagedObjectContext) {
    settingsObject.awattarEnergyProfileIndex = newProfileIndex
    do {
        try managedObjectContext.save()
    } catch {
        return
    }
    
    return
}

func changeSplashScreenFinished(newState: Bool, settingsObject: Setting, managedObjectContext: NSManagedObjectContext) {
    settingsObject.splashScreensFinished = newState
    do {
        try managedObjectContext.save()
    } catch {
        return
    }
    
    return
}

func changeEnergyCharge(newEnergyCharge: Float, settingsObject: Setting, managedObjectContext: NSManagedObjectContext) {
    settingsObject.awattarEnergyPrice = newEnergyCharge
    do {
        try managedObjectContext.save()
    } catch {
        return
    }
    
    return
}
