//
//  data.swift
//  ToDoApp
//
//  Created by RastaOnAMission on 17/09/2018.
//  Copyright © 2018 ronyquail. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
}
