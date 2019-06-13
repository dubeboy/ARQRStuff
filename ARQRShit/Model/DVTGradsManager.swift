//
//  DVTGradsManager.swift
//  ARQRShit
//
//  Created by Divine Dube on 2019/06/11.
//  Copyright © 2019 DVT. All rights reserved.
//

import UIKit

class DVTGradsManager {
	static let shared = DVTGradsManager()
    var grads: DVTGrad?
	private init() {}
	
	func downloadImage(complete: @escaping (_ image: UIImage) -> Void) {
		
		guard let imageUrl = grads?.imageURL, let url = URL(string: imageUrl) else {
			return
		}
		
		URLSession.shared.dataTask(with: url) { data, response, error in
			guard
				let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
				let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
				let data = data, error == nil,
				let image = UIImage(data: data)
				else {
					return
			}
			DispatchQueue.main.async() {
				complete(image)
			}
		}.resume()
	}
}


