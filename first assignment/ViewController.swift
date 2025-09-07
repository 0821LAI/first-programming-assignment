//
//  ViewController.swift
//  first assignment
//
//  Created by lai Tang on 9/5/25.
//

// ViewController.swift
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
    
    // Like Button
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Like", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 10
        return button
    }()
    
    // View My Likes Button
    private let viewLikesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View My Likes", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    // Current URL
    private var currentImageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Enable to see on the Screen
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(refreshButton)
        view.addSubview(likeButton)
        view.addSubview(viewLikesButton)
        
        // Set frames
        titleLabel.frame = CGRect(x: 20, y: 150, width: view.frame.width - 40, height: 40)
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.center = view.center
        refreshButton.frame = CGRect(x: 50, y: view.frame.height - 200, width: view.frame.width - 100, height: 50)
        likeButton.frame = CGRect(x: 50, y: view.frame.height - 140, width: (view.frame.width - 120) / 2, height: 40)
        viewLikesButton.frame = CGRect(x: 70 + (view.frame.width - 120) / 2, y: view.frame.height - 140, width: (view.frame.width - 120) / 2, height: 40)
        
        // Button actions
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        viewLikesButton.addTarget(self, action: #selector(viewLikesButtonTapped), for: .touchUpInside)
        
        getRandomPhoto()
    }
    
    @objc private func refreshButtonTapped() {
        getRandomPhoto()
    }
    
    // Like button function
    @objc private func likeButtonTapped() {
        guard let imageUrl = currentImageUrl else { return }
        
        // Save
        var likedImages = UserDefaults.standard.array(forKey: "likedImages") as? [String] ?? []
        if !likedImages.contains(imageUrl) {
            likedImages.append(imageUrl)
            UserDefaults.standard.set(likedImages, forKey: "likedImages")
            
            // Pop up screen
            let alert = UIAlertController(title: "👍", message: "Added to likes!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    //
    @objc private func viewLikesButtonTapped() {
        let likesVC = LikesViewController()
        present(likesVC, animated: true)
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
            
            // Save Image URL
            self?.currentImageUrl = imageUrlString
            
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

// LikesViewController.swift
class LikesViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Liked Foods"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 8
        return button
    }()
    
    // Liked Picture Layout
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private var likedImages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // loading liked images
        likedImages = UserDefaults.standard.array(forKey: "likedImages") as? [String] ?? []
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(collectionView)
        
        titleLabel.frame = CGRect(x: 20, y: 80, width: view.frame.width - 40, height: 40)
        closeButton.frame = CGRect(x: view.frame.width - 80, y: 50, width: 60, height: 30)
        collectionView.frame = CGRect(x: 20, y: 140, width: view.frame.width - 40, height: view.frame.height - 200)
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        collectionView.dataSource = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

// CollectionView
extension LikesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let imageUrlString = likedImages[indexPath.item]
        cell.loadImage(from: imageUrlString)
        return cell
    }
}

// Image Cell
class ImageCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }.resume()
    }
}
