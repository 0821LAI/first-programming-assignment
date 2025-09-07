//
//  ViewController.swift
//  first assignment
//
//  Created by lai Tang on 9/5/25.
//

import UIKit

class ViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "What should I eat today?"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change One", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Enable to see on the Screen
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(refreshButton)
        
        // Set frames
        titleLabel.frame = CGRect(x: 20, y: 150, width: view.frame.width - 40, height: 40)
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.center = view.center
        refreshButton.frame = CGRect(x: 50, y: view.frame.height - 200, width: view.frame.width - 100, height: 50)
        
        // Button action
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        
        getRandomPhoto()
    }
    
    @objc private func refreshButtonTapped() {
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
