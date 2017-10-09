//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Jarrod Parkes on 11/3/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController

class ViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var grabImageButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func grabNewImage(_ sender: AnyObject) {
        setUIEnabled(false)
        getImageFromFlickr()
    }
    
    // MARK: Configure UI
    
    private func setUIEnabled(_ enabled: Bool) {
        photoTitleLabel.isEnabled = enabled
        grabImageButton.isEnabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    
    // MARK: Make Network Request
    
    private func getImageFromFlickr() {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.GalleryID: Constants.FlickrParameterValues.GalleryID,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback];
        
        let session = URLSession.shared;
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(parameters: methodParameters as [String:AnyObject]);
        let url = URL(string: urlString)!;
        let request = URLRequest(url: url);
        
        hearthstone();
        return;
        
        let task = session.dataTask(with: request){(data, response, error) in
            
            func displayError(_ error: String){
                print(error);
                print("URL no momento do erro: \(url)")
                performUIUpdatesOnMain {
                    self.setUIEnabled(true);
                }
            }
            
            guard(error == nil) else {
                displayError("Houve um erro na sua requisição: \(String(describing: error))");
                return;
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Sua requisição retornou um código diferente de 2xx!");
                return;
            }
            
            guard let data = data else {
                displayError("Nenhum dado retornado pela sua requisição!");
                return;
            }
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Não é possível converter os dados para JSON: '\(data)'");
                return;
            }
            
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject],
                let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                    
                    displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)");
                    return;
            }
            
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)));
            
            guard let urlPhoto = photoArray[randomPhotoIndex][Constants.FlickrResponseKeys.MediumURL] as? String,
                let tituloPhoto = photoArray[randomPhotoIndex][Constants.FlickrResponseKeys.Title] as? String else {
                    displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)'");
                    return;
                    
            }
            self.carregarImagem(url: urlPhoto, titulo: tituloPhoto);
        }
        task.resume();
    }
    
    private func carregarImagem(url: String, titulo: String) {
        let imageURL = URL(string: url)!
        
        //        let task = URLSession.shared.dataTask(with: imageURL) {(data, response, error) in
        //guard if usuario?.endereco?.pais?.estado?.cidade? == "recife"
        //            print("task finished");
        //
        //            if error == nil{
        //                let downloadedImage = UIImage(data: data!);
        
        if let imageData = try? Data(contentsOf: imageURL){
            
            performUIUpdatesOnMain {
                //self.photoImageView.image = downloadedImage;
                self.photoImageView.image = UIImage(data: imageData);
                self.photoTitleLabel.text = titulo;
                self.setUIEnabled(true);
            }
        }
        
        //        task.resume();
        
    }
    
    private func escapedParameters(parameters: [String: AnyObject]) -> String{
        
        if !parameters.isEmpty{
            var keyValuePairs = [String]();
            
            for(key, value) in parameters{
                let stringValue = "\(value)";
                
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed);
                
                keyValuePairs.append(key + "=" + "\(escapedValue!)");
            }
            return "?\(keyValuePairs.joined(separator: "&"))";
        } else{
            return "";
        }
    }
    
    private func hearthstone() {
        guard let path = Bundle.main.path(forResource: "hearthstone", ofType: "json") else {
            print("Invalid filename/path.");
            return;
        }
        
        let jsonHearth: [String:AnyObject];
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped);
            jsonHearth = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject];
        } catch let error {
            print(error.localizedDescription);
            return;
        }
        
        guard let arrayHearth = jsonHearth["Basic"] as? [[String:AnyObject]] else{
            return;
        };
        
        var minionsCost5 = 0;
        var weaponsDurab = 0;
        var textBattlecry = 0;
        
        var minionsTotalCount = 0;
        var minionsTotalCost = 0;
        var minionsAverageCost = 0.0;
        
        var minionsTotalNonZeroCount = 0;
        var minionsTotalNonZeroCost = 0;
        var minionsTotalAttack = 0;
        var minionsTotalHealth = 0;
        var minionsAverageStatsCostRatio = 0.0;
        
        for (index, element) in arrayHearth.enumerated() {
            if let type = element["type"] as? String,
                type == "Minion",
                let cost = element["cost"] as? Int {
                
                if let rarity = element["rarity"] as? String,
                    rarity == "Common" {
                    minionsTotalCost += cost;
                    minionsTotalCount += 1;
                }
                
                if cost == 5 {
                    minionsCost5 += 1;
                    print("\(index): \(type) cost: \(cost)");
                }
                
                if cost != 0 {
                    if let attack = element["attack"] as? Int,
                        let health = element["health"] as? Int {
                        minionsTotalNonZeroCount += 1;
                        //minionsTotalNonZeroCost += cost;
                        //minionsTotalAttack += attack;
                        //minionsTotalHealth += health;
                        
                        minionsAverageStatsCostRatio += Double((health + attack) / cost);
                    }
                }
            }
            
            if let type = element["type"] as? String,
                type == "Weapon",
                let durability = element["durability"] as? Int,
                durability == 2 {
                weaponsDurab += 1;
                print("\(index): \(type) durability: \(durability)");
            }
            //round to the nearest hundredths place
            if let text = element["text"] as? String,
                (text.range(of:"Battlecry") != nil) {
                textBattlecry += 1;
                print("\(index): text contains Battlecry.");
            }
        }
        minionsAverageCost = Double(minionsTotalCost / minionsTotalCount);
        //minionsAverageStatsCostRatio = Double((minionsTotalHealth + minionsTotalAttack) / minionsTotalNonZeroCost);
        print("minions cost 5: \(minionsCost5)");
        print("weapons durability: \(weaponsDurab)");
        print("text Battlecry: \(textBattlecry)");
        print("minions average cost: \(minionsAverageCost)");
        print("minions average stats cost ratio: \(minionsAverageStatsCostRatio / Double(minionsTotalNonZeroCount))");
        print("terminado!");
    }
}
