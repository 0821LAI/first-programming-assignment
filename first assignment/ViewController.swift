//
//  ViewController.swift
//  first assignment
//
//  Created by lai Tang on 9/5/25.
//

import UIKit

class ViewController: UIViewController {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true // Add this to prevent image overflow
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        view.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.center = view.center
        
        getRandomPhoto()
    }
    
    func getRandomPhoto() {
        let baseURL = "https://api.unsplash.com/photos/random"
        let accessKey = "LqGBgAw6UCbhjpxEC2v5Fto7cqx29XHR8VELKunT3kw"
        let urlString = "\(baseURL)?client_id=\(accessKey)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        //Fetching JSON Data
        
        // Uses the system's shared network session, and creates a data task to send a request to the specified URL (Weak reference to prevent memory retain cycles)
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                   
                    //JSONSerialization.jsonObject: Converts the data into a JSON object
                    //data!: Force unwraps the network response data (assumes data exists)
                    //as! [String: Any]: Force cast to dictionary type
                    let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                    
                    //Extracts the "urls" key value from the JSON dictionary,Force cast to dictionary type (because URLs contain multiple image sizes)
                    let urls = json["urls"] as! [String: Any]
            
                    //Converts the string to a URL object, ! force unwrap, assumes the URL format is correct
                    let imageUrlString = urls["regular"] as! String
                    
                    //Converts the string to a URL object, ! force unwrap, assumes the URL format is correct
                    let imageUrl = URL(string: imageUrlString)!
            
                    //Calls the image download function, self? safe call because there is a weak sel
                    self?.downloadImage(from: imageUrl)
                }.resume()
            }
    
            //Downloading Image
            private func downloadImage(from url: URL) {
                //Another network request, this time to download the actual image data
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    
                    //Two ! marks indicate force unwrapping of both data and image creation
                    let image = UIImage(data: data!)!
                    
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }.resume()
    }
}
