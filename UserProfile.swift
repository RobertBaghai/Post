//
//  UserProfile.swift
//  Post!
//
//  Created by Robert Baghai on 2/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import Foundation
import UIKit
import Parse

class UserProfile {
    var userProfileName:     String?
    var usersDescription:    String?
    var usersAvatar:         PFFile?
    var userId:              String?
    var userProfileObjectId: String?
    
    init(profileName: String, description: String, avatar: PFFile, usrId: String, profileObjId: String){
        self.userProfileName     = profileName
        self.usersDescription    = description
        self.usersAvatar         = avatar
        self.userId              = usrId
        self.userProfileObjectId = profileObjId
    }
}