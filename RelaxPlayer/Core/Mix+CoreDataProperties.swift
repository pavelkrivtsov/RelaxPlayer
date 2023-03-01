//
//  Mix+CoreDataProperties.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 20.02.2023.
//
//

import Foundation
import CoreData


extension Mix {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Mix> {
        return NSFetchRequest<Mix>(entityName: "Mix")
    }

    @NSManaged public var createdAt: Date
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var noises: NSSet

}

// MARK: Generated accessors for noises
extension Mix {

    @objc(addNoisesObject:)
    @NSManaged public func addToNoises(_ value: Noise)

    @objc(removeNoisesObject:)
    @NSManaged public func removeFromNoises(_ value: Noise)

    @objc(addNoises:)
    @NSManaged public func addToNoises(_ values: NSSet)

    @objc(removeNoises:)
    @NSManaged public func removeFromNoises(_ values: NSSet)

}

extension Mix : Identifiable {

}
