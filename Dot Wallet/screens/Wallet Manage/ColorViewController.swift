//
//  ColorViewController
//  Dot Wallet
//
//  Created by Franky Aguilar on 8/7/18.
//  Copyright © 2018 Ninth Industries. All rights reserved.
//

import Foundation
import UIKit
class ColorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var ibo_collectionView:UICollectionView!
    
    
    var colors = ["696B7A",
                  "998AFF",
                  "64E5FF",
                  "0081FF",
                  "FF5757",
                  "FFB357",
                  "DCF14A",
                  "40E252",
                  "CDE6FF",
                  "DDDDDD",
                  "FF66C7",
                  "24294E",
                  "FFF100",
                  "BD10E0",
                  "1D1D1D",
                  "B8773C",
                  "7E3BA0",
                  "BFBFBF"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ColorViewCell
        
        cell.backgroundColor = UIColor.init(hexString: colors[indexPath.item])
        cell.layer.cornerRadius = 40
        cell.color = self.colors[indexPath.item]
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ColorViewCell        
        UserPreferenceManager.shared.setKey(key: "walletColor", object: cell.color!)
        self.navigationController?.popViewController(animated: true)
    }
    
}

class ColorViewCell : UICollectionViewCell {
    var color:String?
}
