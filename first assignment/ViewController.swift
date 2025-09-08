//
//  ViewController.swift
//  first assignment
//
//  Created by lai Tang on 9/5/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseDatabase

class ViewController: UIViewController {
    
    // Firebase
    private let db = Firestore.firestore()
    private var userId: String = ""
    
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
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Like", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let viewLikesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View My Likes", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var currentImageUrl: String?
    private var currentImageInfo: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        initializeUser()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(refreshButton)
        view.addSubview(likeButton)
        view.addSubview(viewLikesButton)
        
        titleLabel.frame = CGRect(x: 20, y: 150, width: view.frame.width - 40, height: 40)
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.center = view.center
        refreshButton.frame = CGRect(x: 50, y: view.frame.height - 200, width: view.frame.width - 100, height: 50)
        likeButton.frame = CGRect(x: 50, y: view.frame.height - 140, width: (view.frame.width - 120) / 2, height: 40)
        viewLikesButton.frame = CGRect(x: 70 + (view.frame.width - 120) / 2, y: view.frame.height - 140, width: (view.frame.width - 120) / 2, height: 40)
        
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        viewLikesButton.addTarget(self, action: #selector(viewLikesButtonTapped), for: .touchUpInside)
    }
    
    private func initializeUser() {
        userId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        print("User ID: \(userId)")
        getRandomPhoto()
    }
    
    @objc private func refreshButtonTapped() {
        getRandomPhoto()
    }
    
    @objc private func likeButtonTapped() {
        guard let imageInfo = currentImageInfo else {
            showAlert(title: "Error", message: "No image to like")
            return
        }
        
        saveToFirebase(imageInfo: imageInfo)
    }
    
    @objc private func viewLikesButtonTapped() {
        let likesVC = LikesViewController()
        likesVC.userId = userId
        present(likesVC, animated: true)
    }
    
    // Save to Firebase
    private func saveToFirebase(imageInfo: [String: Any]) {
        let likeData: [String: Any] = [
            "userId": userId,
            "imageUrl": imageInfo["imageUrl"] as? String ?? "",
            "imageId": imageInfo["imageId"] as? String ?? "",
            "description": imageInfo["description"] as? String ?? "",
            "photographer": imageInfo["photographer"] as? String ?? "",
            "photographerUrl": imageInfo["photographerUrl"] as? String ?? "",
            "timestamp": FieldValue.serverTimestamp(),
            "foodType": imageInfo["foodType"] as? String ?? "food"
        ]
        
        //check if there is already been liked
        db.collection("likes")
            .whereField("userId", isEqualTo: userId)
            .whereField("imageId", isEqualTo: imageInfo["imageId"] as? String ?? "")
            .getDocuments { [weak self] (querySnapshot, error) in
                
                if let error = error {
                    print("Error checking existing like: \(error)")
                    return
                }
                
                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    DispatchQueue.main.async {
                        self?.showAlert(title: "👍", message: "Already in your likes!")
                    }
                    return
                }
                
                // add new likes
                self?.db.collection("likes").addDocument(data: likeData) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error adding like: \(error)")
                            self?.showAlert(title: "Error", message: "Failed to save like")
                        } else {
                            self?.showAlert(title: "👍", message: "Added to likes!")
                        }
                    }
                }
            }
    }
    
    func getRandomPhoto() {
        let baseURL = "https://api.unsplash.com/photos/random"
        let accessKey = "LqGBgAw6UCbhjpxEC2v5Fto7cqx29XHR8VELKunT3kw"
        let foods = ["pizza", "burger", "sushi", "pasta", "tacos", "ramen", "curry", "dessert", "soup", "sandwich"]
        let query = foods.randomElement() ?? "food"
        let urlString = "\(baseURL)?client_id=\(accessKey)&query=\(query)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let urls = json["urls"] as! [String: Any]
                let imageUrlString = urls["regular"] as! String
                let imageUrl = URL(string: imageUrlString)!
                
                //
                let user = json["user"] as? [String: Any]
                self?.currentImageInfo = [
                    "imageUrl": imageUrlString,
                    "imageId": json["id"] as? String ?? "",
                    "description": json["alt_description"] as? String ?? "Delicious \(query)",
                    "photographer": user?["name"] as? String ?? "Unknown",
                    "photographerUrl": (user?["links"] as? [String: Any])?["html"] as? String ?? "",
                    "foodType": query
                ]
                
                self?.downloadImage(from: imageUrl)
            } catch {
                print("JSON parsing error: \(error)")
            }
        }.resume()
    }
    
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to load image")
                return
            }
            
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }.resume()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// Firebase版本的LikesViewController
class LikesViewController: UIViewController {
    
    var userId: String = ""
    private let db = Firestore.firestore()
    
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
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private var likedImages: [LikedImage] = []
    private var noLikesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        loadLikedImages()
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
        collectionView.delegate = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        
        // No liked food label
        noLikesLabel = UILabel()
        noLikesLabel.text = "No liked foods yet!\nGo back and like some food! 🍕"
        noLikesLabel.font = UIFont.systemFont(ofSize: 18)
        noLikesLabel.textAlignment = .center
        noLikesLabel.numberOfLines = 0
        noLikesLabel.textColor = .gray
        noLikesLabel.frame = CGRect(x: 20, y: 300, width: view.frame.width - 40, height: 100)
        view.addSubview(noLikesLabel)
    }
    
    private func loadLikedImages() {
        db.collection("likes")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                
                if let error = error {
                    print("Error getting likes: \(error)")
                    return
                }
                
                var images: [LikedImage] = []
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let likedImage = LikedImage(
                        id: document.documentID,
                        imageUrl: data["imageUrl"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        photographer: data["photographer"] as? String ?? "",
                        foodType: data["foodType"] as? String ?? ""
                    )
                    images.append(likedImage)
                }
                
                DispatchQueue.main.async {
                    self?.likedImages = images
                    self?.collectionView.reloadData()
                    self?.updateLikesView()
                }
            }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func updateLikesView() {
        if likedImages.isEmpty {
            collectionView.isHidden = true
            noLikesLabel.isHidden = false
        } else {
            collectionView.isHidden = false
            noLikesLabel.isHidden = true
        }
    }
}

extension LikesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let likedImage = likedImages[indexPath.item]
        cell.loadImage(from: likedImage.imageUrl)
        return cell
    }
    
    // 长按删除功能
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let likedImage = likedImages[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title: "Remove from Likes", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.removeLike(at: indexPath)
            }
            return UIMenu(title: "", children: [deleteAction])
        }
    }
    
    private func removeLike(at indexPath: IndexPath) {
        let likedImage = likedImages[indexPath.item]
        
        db.collection("likes").document(likedImage.id).delete { [weak self] error in
            if let error = error {
                print("Error removing like: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.likedImages.remove(at: indexPath.item)
                    self?.collectionView.deleteItems(at: [indexPath])
                    self?.updateLikesView()
                }
            }
        }
    }
}

struct LikedImage {
    let id: String
    let imageUrl: String
    let description: String
    let photographer: String
    let foodType: String
}

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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    func loadImage(from urlString: String) {
        imageView.image = nil
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }.resume()
    }
}
