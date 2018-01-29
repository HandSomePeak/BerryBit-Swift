//
//  CoreDataHelper.swift
//  BerryBit
//
//  Created by 杨峰 on 2018/1/25.
//  Copyright © 2018年 BerryBit. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper: NSObject {
    // 托管对象上下文
    var context : NSManagedObjectContext!
    // 托管对象模型
    var model : NSManagedObjectModel!
    // 持久化存储协调器
    var coordinator : NSPersistentStoreCoordinator!
    // 持久化存储区
    var store : NSPersistentStore!
    
    // 专用队列上下文
    var parentContext : NSManagedObjectContext!
    // 存储持久化存储区的文件名
    let storeFilename = "Measure.sqlite"
    
    // MARK: PATHS
    
    // MARK: 返回应用程序文档目录的路径
    func applicationDocumentDirectory() -> String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        print("返回应用程序文档目录的路径 = \(path)")
        return path
    }
    
    // MARK: 向应用程序文档目录中添加名位Stores的子目录，并将其路径放在NSURL中返回
    func applicationStoreDirectory() -> URL {
        let path = self.applicationDocumentDirectory()
        let storeDirectory = URL.init(fileURLWithPath: path).appendingPathComponent("Stores")
        
        let fileManager : FileManager = FileManager.default
        // 判断Document目录下Stores文件夹是否存在
        if !fileManager.fileExists(atPath: storeDirectory.path) {
            // 创建Stores文件夹
            if let _ = try? fileManager.createDirectory(at: storeDirectory, withIntermediateDirectories: true, attributes: nil) {
                print("成功创建存储目录")
            }
            else {
                print("创建存储目录失败。")
            }
        }
        else {
            print("Stores文件夹已经存在，不需要重复创建")
        }
        return storeDirectory
    }
    
    // MARK: 把持久化存储区的文件名添加到Stores目录的路径中
    func storeURL() -> URL {
        return self.applicationStoreDirectory().appendingPathComponent(storeFilename)
    }
    
    static let shareInstance = CoreDataHelper()
    
    // MARK: SETUP
    override init() {
        print("CoreDataHelper init 只能执行一次")
        super.init()
        self.model = NSManagedObjectModel.mergedModel(from: nil)
        self.coordinator = NSPersistentStoreCoordinator.init(managedObjectModel: self.model)
        self.parentContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        self.parentContext.performAndWait {
            self.parentContext.persistentStoreCoordinator = self.coordinator
            self.parentContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
        self.context = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        self.context.parent = self.parentContext
        self.context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        self.setupCoreData()
    }
    
    func loadStore() {
        
        if (self.store != nil) {
            return;
        }
        let options : Dictionary<String,Dictionary<String,String>> = [NSSQLitePragmasOption : ["journal_mode" : "DELETE"]]
        
        self.store = try? self.coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL(), options: options)

        if self.store == nil {
            print("未能添加持久化存储区。")
            abort();
        }
        else {
            print("成功添加持久化存储区 = \(self.store)")
        }
    }
    
    func setupCoreData() {
        self.loadStore()
    }
    
    // MARK: SAVING
    func saveContext() {
        if self.context.hasChanges {
            if let _ = try? self.context.save() {
                print("context 保存更改到持久化存储区 -- 成功")
            }
            else {
                print("context 保存更改到持久化存储区 -- 失败")
            }
        }
        else {
            print("context 不用保存, 没有更改")
        }
    }
    
    // MARK: 后台保存
    func backgroundSaveContext() {
        self.saveContext()
        self.parentContext.perform {
            if self.parentContext.hasChanges {
                if let _ = try? self.parentContext.save() {
                    print("parentContext 保存更改到持久化存储区 -- 成功")
                }
                else {
                    print("parentContext 保存更改到持久化存储区 -- 失败")
                }
            }
            else {
                print("parentContext 不用保存, 没有更改")
            }
        }
    }

    func addCoreData(time: String, data: String, type: String, mac: String) {
        
        // 查找是否是相同的数据
        let request : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        let entity1 = NSEntityDescription.entity(forEntityName: "Measure", in: CoreDataHelper.shareInstance.parentContext)
        let pre = NSPredicate.init(format: "time=%@", time)
        request.predicate = pre
        request.entity = entity1
        if let a = try? CoreDataHelper.shareInstance.parentContext.fetch(request) as! [Measure] as Array {
            if a.count <= 0 {
                let entity = NSEntityDescription.insertNewObject(forEntityName: "Measure", into: CoreDataHelper.shareInstance.parentContext) as! Measure
                entity.data = data
                entity.time = time
                entity.type = type
                entity.mac = mac
            }
            else {
                print("发现相同数据，不添加到数据库 = \(a)")
            }
        }
    }
    
    func selectDataFromCoreData() -> Array<Measure> {
        
        var dataSource = Array<Measure>()
        let request : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        let entity = NSEntityDescription.entity(forEntityName: "Measure", in: CoreDataHelper.shareInstance.parentContext)
        let sort = NSSortDescriptor.init(key: "time", ascending: false)
        request.sortDescriptors = [sort]
        request.entity = entity
        if let s = try? CoreDataHelper.shareInstance.parentContext.fetch(request) as! [Measure] as Array {
            dataSource = s
        }
        return dataSource
    }
    
}
