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
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.center = view.center
        
        getRandomPhoto()
    }
    
    func getRandomPhoto() {
        let baseURL = "https://api.unsplash.com/photos/random"
        let accessKey = "LqGBgAw6UCbhjpxEC2v5Fto7cqx29XHR8VELKunT3kw"
        let foods = ["pizza", "burger", "sushi", "pasta", "tacos", "ramen", "curry"]
        let query = foods.randomElement() ?? "food"
        let urlString = "\(baseURL)?client_id=\(accessKey)&query=\(query)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let urls = json["urls"] as! [String: Any]
            let imageUrlString = urls["regular"] as! String
            let imageUrl = URL(string: imageUrlString)!
            
            self?.downloadImage(from: imageUrl)
        }.resume()
    }
    
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = UIImage(data: data!)!
            
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }.resume()
    }
}
