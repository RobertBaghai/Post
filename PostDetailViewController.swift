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
        self.imagePost!.postedImage!.getDataInBackgroundWithBlock({
            (data:NSData?, error:NSError?) -> Void in
            if error == nil {
                if let imageData       = data {
                    let retrievedImage = UIImage(data: imageData)
                    self.selectedPostedImage.image = retrievedImage
                }
            }
        })
        self.selectedPostedImageDescription.text = self.imagePost?.description
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
