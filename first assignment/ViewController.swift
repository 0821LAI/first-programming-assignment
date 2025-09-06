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
        let urlString = "https://source.unsplash.com/random/600x600"
        guard let url = URL(string: urlString),
              let data = try? Data(contentsOf: url) else {
            return
        }
        imageView.image = UIImage(data: data)
    }
}

