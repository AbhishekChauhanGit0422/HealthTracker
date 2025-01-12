//
//  HealthTracking+CoreDataProperties.swift
//  HealthTrackingApp
//
//  Created by Abhishek on 12/01/25.
//
//

import Foundation
import CoreData


extension HealthTracking {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HealthTracking> {
        return NSFetchRequest<HealthTracking>(entityName: "HealthTracking")
    }

    @NSManaged public var name: String?
    @NSManaged public var timeStamp: Date?
    @NSManaged public var value: Double

}

extension HealthTracking : Identifiable {

}
