//
//  ViewController.swift
//  azureSample
//
//  Created by REO HARADA on 2019/12/01.
//  Copyright © 2019 reo harada. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var translateTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!
    
    let urlIssue = "https://api.cognitive.microsoft.com/sts/v1.0/issueToken"
    let urlTranslate = "https://api.cognitive.microsofttranslator.com/translate"
    
    //let subscriptionKey = "<赤坂さんのキーに書き換える>"
    let subscriptionKey = "8813c554371a48efb5612c3d827a941c"
    let contentType = "application/json; charset=UTF-8"
    let authorization = "Bearer "
    let apiVersion = "api-version=3.0"
    let from = "from=ja"
    let to = "to=en"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tapSendButton(_ sender: Any) {
        if let issueUrl = URL(string: urlIssue) {
            var request = URLRequest(url: issueUrl)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = ["Ocp-Apim-Subscription-Key": subscriptionKey]
            let session = URLSession.shared
            session.dataTask(with: request) { (data, res, error) in
                print(error)
                print(String(data: data!, encoding: .utf8))
                print(res)
                if let d = data {
                    self.requestTranslate(authString: String(data: d, encoding: .utf8)!)
                }
            }.resume()
        }
    }
    
    func requestTranslate(authString: String) {
        guard let text = self.translateTextField.text else {
            return
        }
        if let translateURL = URL(string: urlTranslate+"?"+apiVersion+"&"+from+"&"+to) {
            var request = URLRequest(url: translateURL)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = [
                "Authorization": authorization+authString,
                "Ocp-Apim-Subscription-Region": "japaneast",
                "Ocp-Apim-Subscription-Key": subscriptionKey,
                "Content-Type": contentType,
            ]
            request.httpBody = "[{'Text':'\(text)'}]".data(using: .utf8)
            let session = URLSession.shared
            session.dataTask(with: request) { (data, res, error) in
                print(error)
                print(String(data: data!, encoding: .utf8))
                print(res)
                let object = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [Any]
                print(object)
                let objectChild = object?.first as? [String:Any]
                print(objectChild)
                let objectChildTranslations = objectChild?["translations"] as! [Any]
                print(objectChildTranslations)
                let objectChildTranslationsChild = objectChildTranslations.first as? [String:String]
                print(objectChildTranslationsChild)
                print(objectChildTranslationsChild!["text"])
                DispatchQueue.main.async {
                    self.resultTextView.text = objectChildTranslationsChild!["text"]
                }
            }.resume()
        }
    }
    
}

