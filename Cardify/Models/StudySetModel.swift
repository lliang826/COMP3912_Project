//
//  StudySetModel.swift
//  Cardify
//
//  Created by user218033 on 7/11/22.
//

import Foundation
import RealmSwift
import Combine

final class StudySetModel: ObservableObject {
    
    static let shared = StudySetModel()
    
    @Published var studySets: [StudySet] = []
    
    private var token: NotificationToken?
    
    private init() {
        setupObserver()
    }
    
    deinit {
        token?.invalidate()
    }
    
    private func setupObserver() {
        do {
            let realm = try Realm()
            let results = realm.objects(StudySetObject.self)
            
            token = results.observe({ [weak self] changes in
                self?.studySets = results.map(StudySet.init).sorted(by: { a, b in
                    a.title < b.title
                })
            })
        } catch let error {
            print(String(describing: error))
        }
    }
    
    func findStudySet(id: String) -> StudySet? {
        for s in studySets {
            if s.id == id {
                return s
            }
        }
        return nil
    }
    
    func addStudySet(title: String, content: [String]) {
        let studySetObject = StudySetObject(value: [
            "title": title,
            "content": content,
        ])
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(studySetObject)
            }
        } catch let error {
            print(String(describing: error))
        }
    }
    
    func remove(id: String) {
        do {
            let realm = try Realm()
            let objectId = try ObjectId(string: id)
            if let studySet = realm.object(ofType: StudySetObject.self, forPrimaryKey: objectId) {
                try realm.write {
                    realm.delete(studySet)
                }
            }
        } catch let error {
            print(String(describing: error))
        }
    }
    
    func removeContent(id: String, content: String) {
        do {
            let realm = try Realm()
            let objectId = try ObjectId(string: id)
            if let studySet = realm.object(ofType: StudySetObject.self, forPrimaryKey: objectId) {
                try realm.write {
                    for i in 0..<studySet.content.count {
                        if studySet.content[i] == content {
                            studySet.content.remove(at: i)
                        }
                    }
                }
            }
        } catch let error {
            print(String(describing: error))
        }
    }
    
    func updateTitle(id: String, title: String) {
        do {
            let realm = try Realm()
            let objectId = try ObjectId(string: id)
            let studySet = realm.object(ofType: StudySetObject.self, forPrimaryKey: objectId)
            try realm.write {
                studySet?.title = title
            }
        } catch let error {
            print(String(describing: error))
        }
    }
    
    func updateContent(id: String, content: String) {
        do {
            let realm = try Realm()
            let objectId = try ObjectId(string: id)
            let studySet = realm.object(ofType: StudySetObject.self, forPrimaryKey: objectId)
            try realm.write {
                studySet?.content.append(content)
            }
        } catch let error {
            print(String(describing: error))
        }
    }
}
