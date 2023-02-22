//
//  Noise+CoreDataProperties.swift
//  RelaxPlayer
//
//  Created by Павел Кривцов on 23.02.2023.
//
//

import Foundation
import CoreData


extension Noise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Noise> {
        return NSFetchRequest<Noise>(entityName: "Noise")
    }

    @NSManaged public var name: String?
    @NSManaged public var volume: NSNumber?
    @NSManaged public var mix: Mix?

}

extension Noise : Identifiable {

}
