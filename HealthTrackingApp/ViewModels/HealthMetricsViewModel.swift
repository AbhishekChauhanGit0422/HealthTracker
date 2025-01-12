//
//  HealthMetricsViewModel.swift
//  HealthTrackingApp
//
//  Created by Abhishek on 12/01/25.
//


import Foundation
import CoreData

class HealthMetricsViewModel {
    private let coreDataStack = CoreDataStack.shared

    func fetchMetrics(filterType: String? = nil, ascending: Bool = false, timeFilter: String? = nil, completion: @escaping ([HealthTracking]) -> Void) {
        let fetchRequest: NSFetchRequest<HealthTracking> = HealthTracking.fetchRequest()
        var predicates: [NSPredicate] = []
        
        // Filter by name
        if let filterType = filterType {
            predicates.append(NSPredicate(format: "name == %@", filterType))
        }
        
        // Filter by time of day
        if let timeFilter = timeFilter {
            let calendar = Calendar.current
            
            let morningStart = calendar.date(bySettingHour: 6, minute: 0, second: 0, of: Date())!
            let afternoonStart = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
            let eveningStart = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!
            let nightStart = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
            
            switch timeFilter {
            case "Morning":
                predicates.append(NSPredicate(format: "timeStamp >= %@ AND timeStamp < %@", morningStart as NSDate, afternoonStart as NSDate))
            case "Afternoon":
                predicates.append(NSPredicate(format: "timeStamp >= %@ AND timeStamp < %@", afternoonStart as NSDate, eveningStart as NSDate))
            case "Evening":
                predicates.append(NSPredicate(format: "timeStamp >= %@ AND timeStamp < %@", eveningStart as NSDate, nightStart as NSDate))
            default:
                break
            }
        }
        
        // Combine predicates
        fetchRequest.predicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: ascending)]
        
        do {
            let metrics = try coreDataStack.context.fetch(fetchRequest)
            completion(metrics)
        } catch {
            print("Failed to fetch metrics: \(error)")
            completion([])
        }
    }


    func fetchMetricsForLast24Hours(filterType: String? = nil, completion: @escaping ([HealthTracking]) -> Void) {
        let fetchRequest: NSFetchRequest<HealthTracking> = HealthTracking.fetchRequest()
        var predicates: [NSPredicate] = []

        let now = Date()
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: now)!

        predicates.append(NSPredicate(format: "timeStamp >= %@", twentyFourHoursAgo as NSDate))

        if let filterType = filterType {
            predicates.append(NSPredicate(format: "name == %@", filterType))
        }

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        do {
            let metrics = try coreDataStack.context.fetch(fetchRequest)
            completion(metrics)
        } catch {
            print("Failed to fetch metrics for last 24 hours: \(error)")
            completion([])
        }
    }
    
    func addMetric(type: String, value: Double, timestamp: Date) {
        let metric = HealthTracking(context: coreDataStack.context)
        metric.name = type
        metric.value = value
        metric.timeStamp = timestamp

        coreDataStack.saveContext()
    }

    func updateMetric(id: NSManagedObjectID, newType: String, newValue: Double, newTimestamp: Date) {
        do {
            if let metric = try coreDataStack.context.existingObject(with: id) as? HealthTracking {
                metric.name = newType
                metric.value = newValue
                metric.timeStamp = newTimestamp
                coreDataStack.saveContext()
            }
        } catch {
            print("Error updating metric: \(error)")
        }
    }
    
    func deleteMetric(metric: HealthTracking, completion: @escaping (Bool) -> Void) {
        // Assuming you're using CoreData or another data store, handle the deletion
        let context = coreDataStack.context
        context.delete(metric)
        
        do {
            try context.save()
            completion(true)
        } catch {
            print("Failed to delete metric: \(error)")
            completion(false)
        }
    }
    
}
