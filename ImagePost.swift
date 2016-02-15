//
//  ImagePost.swift
//  Post!
//
//  Created by Robert Baghai on 2/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import Foundation
import UIKit

class ImagePost {
    var postedImage: UIImage?
    var userId:      String?
    var imageId:     String?
    var description: String?
    var username:    String?
    
    init(image:UIImage, userId:String, imageId:String, description: String, username: String ) {
        self.postedImage = image
        self.userId      = userId
        self.imageId     = imageId
        self.description = description
        self.username    = username
    }
    
}