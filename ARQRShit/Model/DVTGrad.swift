//
//  DVTGrad.swift
//  ARQRShit
//
//  Created by Divine Dube on 2019/06/11.
//  Copyright © 2019 DVT. All rights reserved.
//

import UIKit

struct DVTGrad {
	var id: Int
	var gradPrograme: String
	var gradsInProgram: String
	var mascotName: String
	var imageURL: String
	
	init( id: Int,
	 gradPrograme: String,
	 gradsInProgram: String,
	 mascotName: String, imageURL: String) {
		self.id = id
		self.gradPrograme = gradPrograme
		self.gradsInProgram = gradsInProgram
		self.mascotName = mascotName
		self.imageURL = imageURL
	}
	
	init?(data: [String: Any]?) {
		let id = data?["id"] as? Int ?? -1
		let gradPrograme = data?["gradProgramme"] as? String ?? "N/A"
		let gradsInProgram = data?["gradsInProgram"] as? String ?? "N/A"
		let mascotName = data?["mascotName"] as? String ?? "N/A"
		let imageURL = data?["imageURL"] as? String ?? "N/A"
		guard id != -1, gradPrograme != "N/A", gradsInProgram != "N/A", mascotName != "N/A", imageURL != "N/A" else { return nil }
		self.init(id: id, gradPrograme: gradPrograme, gradsInProgram: gradsInProgram, mascotName: mascotName, imageURL: imageURL )
	}
}
