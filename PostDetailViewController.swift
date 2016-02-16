//
//  PostDetailViewController.swift
//  Post!
//
//  Created by Robert Baghai on 2/12/16.
//  Copyright © 2016 Robert Baghai. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {
    var imagePost:          ImagePost?
    @IBOutlet weak var selectedPostedImage: UIImageView!
    @IBOutlet weak var selectedPostedImageDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageUrl:NSURL? = NSURL(string: "\(self.imagePost!.postedImage!.url!)")
        if let url = imageUrl {
            self.selectedPostedImage.sd_setImageWithURL(url)
        }
        self.selectedPostedImageDescription.text = self.imagePost?.description
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    

}
