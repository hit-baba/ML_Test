//
//  ViewController.swift
//  MachineLearning
//
//  Created by bar2 on 2018/09/27.
//  Copyright © 2018 Bar2. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,
	UIImagePickerControllerDelegate,
	UINavigationControllerDelegate {

	@IBOutlet weak var ivImage: UIImageView!
	@IBOutlet weak var tvText: UITextView!

	// MARK: - UIImagePickerControllerDelegate メソッド
	
	// 画像の取得時
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		// 選択画像の取得・表示
		let img = info[.originalImage] as! UIImage
		ivImage.image = img
		
		// 画像の予測
        predictImage(inputImage: img)
		
		// イメージピッカー閉じる
		dismiss(animated: true, completion: nil)
	}
	
	// MARK: - Action メソッド
	
	// [画像の取得]ボタン押下
	@IBAction func getImage(_ sender: Any) {
		
		let pc = UIImagePickerController()
		
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			pc.sourceType = .camera
		} else {
			pc.sourceType = .savedPhotosAlbum
		}
		
		pc.delegate = self
		present(pc, animated: true, completion: nil)
	}
	
	// MARK: - Original メソッド
	
	// 画像の予測
	func predictImage(inputImage: UIImage) {
		
		tvText.text = ""

		// MLモデルオブジェクト生成
		//  他：MobileNet().model
        let mdl = try? VNCoreMLModel(for: Resnet50(configuration: MLModelConfiguration()).model)

		// リクエスト作成
		let mlReq = VNCoreMLRequest(model: mdl!) { (request, error) in
			
            let res2 = request.results as! [VNClassificationObservation]
            
			// 予測結果の表示（メインスレッド実行）
			for result in res2 {
                
                let name = result.identifier
                let per = Int(result.confidence * 100)

                // 確率1%以上の予測を採用
				if per < 1 { continue }
				
				DispatchQueue.main.async {
					self.tvText.text.append(
						"・\(name)（\(per)%）\n")
				}
			}
		}
		
		// 判定画像の設定
		let ciImage = CIImage(image: inputImage)
		let hnd = VNImageRequestHandler(ciImage: ciImage!)
		
		// 予測の実行（バックグラウンド実行）
		DispatchQueue.global(qos: .userInteractive).async {
			
			try? hnd.perform([mlReq])
		}
	}
}
