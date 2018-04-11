//
//  CoreDataHandler.swift
//  Reminders
//
//  Created by Roshan on 10/04/18.
//  Copyright © 2018 Roshan. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class CoreDataHandler: NSObject {
    
    class func getContext() -> NSManagedObjectContext
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveReminder(remiderText :String , time : String)
    {
        
        //type 1 , use value for key
        let context = CoreDataHandler.getContext()
        let entity = NSEntityDescription.entity(forEntityName: CoreDataConstants.TableName, in: context)
        let note = Reminders(entity: entity!, insertInto: context)
        note.time = time 
        note.text = remiderText
        
        do
        {
            try context.save()
        }
        catch(let err)
        {
            print(err)
        }
    }
    
    class func fetchReminders() -> [Reminders]?
    {
        let context = CoreDataHandler.getContext()
        
        let request : NSFetchRequest<Reminders> = Reminders.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        var notes:[Reminders]? = nil
        do
        {
            //notes = try  context.fetch(Notes.fetchRequest())
            notes = try  context.fetch(request)
            
        }
        catch(let err)
        {
            print(err)
        }
        return notes
    }
    
    

    
    class func fetchObjectWithredicate() -> Reminders?
    {
        let context = CoreDataHandler.getContext()
        
        do
        {
            try  context.fetch(Reminders.fetchRequest())
        }
        catch(let err)
        {
            print(err)
        }
        return nil
    }
    

    
    class func deleteReminder(reminder:Reminders)
    {
        let context = getContext()
        context.delete(reminder)

        do
        {
            try context.save()
        }
        catch
        {
            
        }
    }
}

