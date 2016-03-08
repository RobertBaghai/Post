//
//  ImagePostDetail.swift
//  Post!
//
//  Created by Robert Baghai on 2/17/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import Foundation

class ImagePostDetail {
    var commentId  : String?
    var imageId    : String?
    var username   : String?
    var userId     : String?
    var comment    : String?
    
    init(id commentId: String, imageId: String, username: String, userId: String, comment: String){
        self.commentId  = commentId
        self.imageId    = imageId
        self.username   = username
        self.userId     = userId
        self.comment    = comment
    }
    
    
}