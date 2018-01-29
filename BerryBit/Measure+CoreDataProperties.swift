//
//  Measure+CoreDataProperties.swift
//  
//
//  Created by 杨峰 on 2018/1/28.
//
//

import Foundation
import CoreData


extension Measure {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Measure> {
        return NSFetchRequest<Measure>(entityName: "Measure")
    }

    @NSManaged public var data: String?
    @NSManaged public var mac: String?
    @NSManaged public var time: String?
    @NSManaged public var type: String?
}


