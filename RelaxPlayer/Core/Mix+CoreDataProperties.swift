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

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?

}

extension Mix : Identifiable {

}
