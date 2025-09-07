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
    }
}
