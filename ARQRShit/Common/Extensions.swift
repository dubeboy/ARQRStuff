//
//  Extensions.swift
//  ARQRShit
//
//  Created by Divine Dube on 2019/06/11.
//  Copyright © 2019 DVT. All rights reserved.
//

import UIKit

extension UIImageView {
	func dowloadFromServer(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
		contentMode = mode
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
				self.image = image
			}
			}.resume()
	}
	
	func dowloadFromServer(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
		guard let url = URL(string: link) else {
			return
		}
		dowloadFromServer(url: url, contentMode: mode)
	}
}
