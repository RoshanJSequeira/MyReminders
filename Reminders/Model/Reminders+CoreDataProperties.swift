//
//  Reminders+CoreDataProperties.swift
//  Reminders
//
//  Created by Roshan on 10/04/18.
//  Copyright © 2018 Roshan. All rights reserved.
//
//

import Foundation
import CoreData


extension Reminders {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminders> {
        return NSFetchRequest<Reminders>(entityName: CoreDataConstants.TableName)
    }

    @NSManaged public var text: String?
    @NSManaged public var time: String?
}
