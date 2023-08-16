//
//  ViewController.swift
//  Multithreading
//
//  Created by Bekpayev Dias on 16.08.2023.
//

import UIKit
import SnapKit
import Alamofire

class ViewController: UIViewController, UICollectionViewDataSource {
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let colV = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return colV
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let aI = UIActivityIndicatorView()
        aI.transform = CGAffineTransform(scaleX: 4, y: 4)
        aI.startAnimating()
        return aI
    }()
    
    var imageUrls = [
        "https://random.dog/9f297526-70cc-432b-a00e-2198e9eccfe8.jpg",
        "https://random.dog/8f969962-5ca9-418c-95e0-7b37817294b1.jpg",
        "https://random.dog/C35XPEgVUAEUkCm.jpg",
        "https://random.dog/00186969-c51d-462b-948b-30a7e1735908.jpg",
        "https://random.dog/4e460068-825d-4277-a269-00e0675b0faf.jpg",
        "https://random.dog/046e5758-d1ef-436f-b7e2-530134562445.jpg",
        "https://random.dog/f355626a-5868-4a22-b173-a7c8571abb80.jpg",
        "https://random.dog/6129aa24-e224-4f7b-8058-e33cca8bfab0.JPG"
    ]
    
    var images: [UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints() {
             $0.centerX.centerY.equalToSuperview()
        }
        
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        let group = DispatchGroup()
        
        let itemSpacing: CGFloat = 10.0
        let numberOfColumns: CGFloat = 2.0
        let cellWidth = (view.bounds.width - (numberOfColumns - 1) * itemSpacing) / numberOfColumns
        let cellHeight = cellWidth
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumInteritemSpacing = itemSpacing
        layout.minimumLineSpacing = itemSpacing
        
        for imageUrl in imageUrls {
            group.enter()
            fetchImage(from: imageUrl) { image in
                self.images.append(image)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                    self.collectionView.reloadData()
        }
    }
    
    func fetchImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                let image = UIImage(data: data)
                completion(image)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let image = images[indexPath.item]
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = cell.contentView.bounds
        cell.contentView.addSubview(imageView)
        
        return cell
    }
}
    
