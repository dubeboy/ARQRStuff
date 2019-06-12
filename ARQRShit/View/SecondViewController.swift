//
//  SecondViewController.swift
//  ARQRShit
//
//  Created by Divine Dube on 2019/06/07.
//  Copyright © 2019 DVT. All rights reserved.
//

import Foundation
import ARKit
import Vision

class SecondViewController: UIViewController {
	
	@IBOutlet weak var sceneView: ARSCNView!
	let updateQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).serialSCNQueue")
	var qrRequests = [VNRequest]()
	var detectedDataAnchor: ARAnchor?
	var scannedQRCodes: [Int: String] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
		sceneView.showsStatistics = true
		sceneView.autoenablesDefaultLighting = true
		sceneView.automaticallyUpdatesLighting = true
		sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
		sceneView.session.delegate = self
		sceneView.delegate = self
		setupQRCodeDetection()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let config = ARWorldTrackingConfiguration()
		 config.planeDetection = [.vertical]
		sceneView.session.run(config, options: [ .resetTracking, .removeExistingAnchors ])
	}
	
	
	
	private func setupQRCodeDetection() {
		// Create a Barcode Detection Request
		let request = VNDetectBarcodesRequest(completionHandler: self.requestHandler)
		// Set it to recognize QR code only
		request.symbologies = [.QR]
		self.qrRequests = [request]
	}
	
	
	func hitTestQrCode(center: CGPoint) {
		if let hitTestResults = sceneView?.hitTest(center, types: [.featurePoint] ),
			let hitTestResult = hitTestResults.first {
				self.detectedDataAnchor = ARAnchor(transform: hitTestResult.worldTransform)
				self.sceneView.session.add(anchor: self.detectedDataAnchor!)
		}
	}
	
	func requestHandler(request: VNRequest, error: Error?) {
		// Get the first result out of the results, if there are any
		if let results = request.results, let result = results.first as? VNBarcodeObservation {
			guard let payload = result.payloadStringValue else {return}
			// Get the bounding box for the bar code and find the center
			var rect = result.boundingBox
			// Flip coordinates
			rect = rect.applying(CGAffineTransform(scaleX: 1, y: -1))
			rect = rect.applying(CGAffineTransform(translationX: 0, y: 1))
			// Get center
			let center = CGPoint(x: rect.midX, y: rect.midY)
			
			do {
				let jsonRespose = try? JSONSerialization.jsonObject(with: Data(payload.utf8), options: []) as? [String: Any]
				DVTGradsManager.shared.grads = DVTGrad(data: jsonRespose)
				guard let dvtGradModel = DVTGradsManager.shared.grads else { return }
				let id = dvtGradModel.id
				if id != -1 && scannedQRCodes[id] == nil {
					scannedQRCodes[id] = jsonRespose?.description
					hitTestQrCode(center: center)
					print("Got one")
				} else {
					return
				}
			} catch {
				print("sorry could not deserialise this")
			}
		} else {
			
		}
	}
}

extension SecondViewController: ARSessionDelegate {
	func session(_ session: ARSession, didUpdate frame: ARFrame) {
		updateQueue.async {
			do {
				let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage,
																options: [:])
				try imageRequestHandler.perform(self.qrRequests)
			} catch {
				print("error")
			}
		}
	}
}

extension SecondViewController: ARSCNViewDelegate {
	private func addMoreUserInfoNode(anchor: ARAnchor, dvtGrad: DVTGrad) -> SCNNode? {
		let detailPlane = SCNPlane(width: 0.3, height: 0.3)
		//	detailPlane.cornerRadius = 0.25
		let detailNode = SCNNode(geometry: detailPlane)
		
		guard let scene = SKScene(fileNamed: "UxGrads")  else {return nil}
		print(scene.children)
		
		let gradProgrameName = scene.childNode(withName: "gradsTeam")
		let commaSeparatedGradsNames = scene.childNode(withName: "CSVGradsNames")
		let mascotNames = scene.childNode(withName: "mascotNames")
		let gradsImage = scene.childNode(withName: "image")
		
		(gradProgrameName as? SKLabelNode)?.text = dvtGrad.gradPrograme
		(commaSeparatedGradsNames as? SKLabelNode)?.text = dvtGrad.gradsInProgram
		(mascotNames as? SKLabelNode)?.text = dvtGrad.mascotName
		DVTGradsManager.shared.downloadImage {
			(gradsImage as? SKSpriteNode)?.texture = SKTexture(image: $0)
		}
		detailNode.geometry?.firstMaterial?.diffuse.contents = scene
		detailNode.geometry?.firstMaterial?.diffuse.contentsTransform
			= SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
		detailNode.opacity = 0
		sceneView.scene.rootNode.addChildNode(detailNode)
		let seq: [SCNAction] = [
			.wait(duration: 1.0),
			.fadeOpacity(to: 1.0, duration: 1.5),
			.moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
		]
		detailNode.runAction(.sequence(seq))
		return detailNode
	}
	
	func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
		// ARPlaneAnchor
		if !(anchor is ARPlaneAnchor) {
			print("grads before render \(DVTGradsManager.shared.grads)")
			return addMoreUserInfoNode(anchor: anchor, dvtGrad: DVTGradsManager.shared.grads)
		}
		return nil
	}
}
