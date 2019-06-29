//
//  SwiftExtensions.swift
//  NewYorkTimes
//
//  Created by Mukesh on 23/06/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func showSimpleAlert ( message: String , inViewController: UIViewController){
        let title = "NYTimes"
        let okayButtonTitle = "Okay"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: okayButtonTitle, style: .default, handler: nil))
        
        inViewController.present(alert, animated: true , completion: nil)
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension Data {
    
    func getDataFor(url: URL) -> Data {
        let imageData = try! Data(contentsOf: url)
        return imageData
    }
}

extension UILabel {
    class func heightWithContent(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
}

extension Date {
    
    func UTCToLocalTime(pubTime:String) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        if let publishedDate = dateFormatter.date(from: pubTime) {
            
            // change to a readable time format and change to local time zone
            dateFormatter.dateFormat = "MMM dd"
            dateFormatter.timeZone = TimeZone.current
            let localTime = dateFormatter.string(from: publishedDate)
            return localTime
        }
        return ""
    }
}

extension UIActivityIndicatorView {
    
    func showActivityIndicator() {
        self.startAnimating()
        self.isHidden = false
    }
    
    func hideActivity() {
        
        DispatchQueue.main.async {
            self.stopAnimating()
            self.isHidden = true
        }
    }
}
