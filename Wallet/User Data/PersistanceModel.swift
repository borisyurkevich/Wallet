//
//  PersistanceModel.swift
//  Wallet
//
//  Created by Boris Yurkevich on 30/09/2017.
//  Copyright © 2017 Boris Yurkevich. All rights reserved.
//

import Foundation
import CoreData

struct PersistanceModel {
    
    mutating func fetchUser() -> User {
        if let existingUser = fetchExistingUser() {
            return existingUser
        } else {
            print("Creating new user")
            return createNewUser()
        }
    }
    
    private mutating func createNewUser() -> User {
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "User", into: managedObjectContext) as! User
        
        let usdAccount = createAccount(type: .usd, balance: 100.0)
        let gbpAccount = createAccount(type: .gbp, balance: 100.0)
        let euroAccount = createAccount(type: .eur, balance: 100.0)
        
        newUser.accounts = NSSet(array: [usdAccount, gbpAccount, euroAccount])

        return newUser
    }
    
    private mutating func createAccount(type: CurrencyType, balance: Double) -> Account {
        let account = NSEntityDescription.insertNewObject(forEntityName: "Account", into: managedObjectContext) as! Account
        account.balance = 100.0
        account.currencyType = type.rawValue
        return account
    }
    
    private mutating func fetchExistingUser() -> User? {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        
        do {
            let fetchedUsers = try managedObjectContext.fetch(fetch) as! [User]
            return fetchedUsers.first
        } catch {
            fatalError("Failed to fetch user: \(error)")
        }
    }
    
    // MARK: - Core Data Saving support
    
    mutating func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Core Data stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Wallet")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    private lazy var managedObjectContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
}
