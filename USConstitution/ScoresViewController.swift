//
//  ScoresViewController.swift
//  USConstitution
//
//  Created by Adam Zarn on 1/1/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class ScoresViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myTableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let screenRect = UIScreen.main.bounds
    var backgroundImage: UIImageView!
    
    var scope: UISegmentedControl!
    var level: UISegmentedControl!
    var levelIndex = 0
    var homeButton: UIButton!
    var label: UILabel!
    
    var myCitizenScores: [Result]! = []
    var myPatriotScores: [Result]! = []
    var myFoundingFatherScores: [Result]! = []
    var allCitizenScores: [Result]! = []
    var allPatriotScores: [Result]! = []
    var allFoundingFatherScores: [Result]! = []
    
    var scoreTypes = ["My", "All"]
    var quizTypes = ["Citizen", "Patriot", "Founding Father"]
    
    var aiv: UIActivityIndicatorView!
    
    var currentScores: [Result]! = []
    
    var resultArrays: [[[Result]]]!
    var alreadyLoaded: [[Bool]]!
    
    override func viewDidLoad() {
        
        backgroundImage = UIImageView(frame: CGRect(x: -20, y: -20, width: screenRect.width + 40, height: screenRect.height + 40))
        backgroundImage.image = UIImage(named: "ConstitutionBackground")
        self.view.addSubview(backgroundImage)
        
        let width = screenRect.width
        let height = screenRect.height
        
        scope = UISegmentedControl(items: ["My Scores", "All Scores"])
        scope.backgroundColor = .white
        scope.frame = CGRect(x: 10, y: 30, width: width - 20, height: 25)
        scope.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for:.valueChanged)
        scope.selectedSegmentIndex = 0
        
        level = UISegmentedControl(items: quizTypes)
        level.backgroundColor = .white
        level.frame = CGRect(x: 10, y: 65, width: width - 20, height: 25)
        level.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for:.valueChanged)
        level.selectedSegmentIndex = levelIndex
        
        aiv = UIActivityIndicatorView(frame: CGRect(x:width/2-10,y: 150, width: 20, height: 20))
        aiv.hidesWhenStopped = true
        aiv.color = .black
        
        resultArrays = [[myCitizenScores,myPatriotScores,myFoundingFatherScores],[allCitizenScores,allPatriotScores,allFoundingFatherScores]]
        alreadyLoaded = [[false, false, false], [false, false, false]]
        
        homeButton = UIButton(frame: CGRect(x:10,y:screenRect.height-50,width:screenRect.width-20, height: 40))
        homeButton.setTitle("Home", for: .normal)
        homeButton.backgroundColor = .red
        homeButton.layer.borderWidth = 1
        homeButton.layer.borderColor = UIColor.red.cgColor
        homeButton.layer.cornerRadius = 5
        homeButton.addTarget(self, action: #selector(self.homeButtonPressed(_:)), for: .touchUpInside)
        
        self.view.addSubview(homeButton)
        self.view.addSubview(scope)
        self.view.addSubview(level)
        self.view.addSubview(aiv)
        
        label = UILabel(frame: CGRect(x: 20, y: 95, width: screenRect.width-40, height: 40))
        label.text = "My \(quizTypes[levelIndex]) Scores"
        label.textAlignment = .center
        label.font = UIFont(name: "Canterbury", size: 30.0)
        self.view.addSubview(label)
        
        myTableView.frame = CGRect(x: 0, y: 135, width: width, height: height - 135 - homeButton.frame.height - 20)
        
        myTableView.isHidden = true
        myTableView.backgroundColor = .clear
        self.view.addSubview(myTableView)
        view.bringSubview(toFront: myTableView)
        aiv.startAnimating()
        getDataForSelectedIndices(scope: scope.selectedSegmentIndex, level: level.selectedSegmentIndex)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentScores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        if scope.selectedSegmentIndex == 0 {
            cell.textLabel?.text = "\(indexPath.row + 1). \(currentScores[indexPath.row].score)"
            cell.detailTextLabel?.text = formattedTimestamp(ts: currentScores[indexPath.row].timestamp)
        } else {
            cell.textLabel?.text = "\(indexPath.row + 1). \(currentScores[indexPath.row].displayName)"
            cell.detailTextLabel?.text = String(currentScores[indexPath.row].score)
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func segmentedControlValueChanged(_ sender: AnyObject) {
        myTableView.isHidden = true
        aiv.startAnimating()
        label.text = "\(scoreTypes[scope.selectedSegmentIndex]) \(quizTypes[level.selectedSegmentIndex]) Scores"
        getDataForSelectedIndices(scope: scope.selectedSegmentIndex, level: level.selectedSegmentIndex)
    }
    
    func formattedTimestamp(ts: String) -> String {
        let year = ts.substring(with: 2..<4)
        let month = Int(ts.substring(with: 4..<6))
        let day = Int(ts.substring(with: 6..<8))
        var hour = Int(ts.substring(with: 9..<11))
        let minute = ts.substring(with: 12..<14)
        var suffix = "AM"
        if hour! > 11 {
            suffix = "PM"
        }
        if hour! > 12 {
            hour = hour! - 12
        }
        if hour! == 0 {
            hour = 12
        }
        
        return "\(month!)/\(day!)/\(year) \(hour!):\(minute) \(suffix)"
    }
    
    func getDataForSelectedIndices(scope: Int, level: Int) {
        
        var path: String!
        
        if scope == 0 {
            path = "Users/\(appDelegate.uid!)"
            if level == 0 {
                path = "\(path!)/citizenResults"
            } else if level == 1 {
                path = "\(path!)/patriotResults"
            } else {
                path = "\(path!)/foundingFatherResults"
            }
        } else {
            path = "TopScores"
            if level == 0 {
                path = "\(path!)/citizen"
            } else if level == 1 {
                path = "\(path!)/patriot"
            } else {
                path = "\(path!)/foundingFather"
            }
        }
        
        print(path!)
        
        if alreadyLoaded[scope][level] {
            currentScores = resultArrays[scope][level]
            myTableView.reloadData()
            myTableView.isHidden = false
            aiv.stopAnimating()
        } else {
            FirebaseClient.sharedInstance.getScores(path: path!, completion: { (scores, error) -> () in
                if let scores = scores {
                    self.resultArrays[scope][level] = scores
                    self.resultArrays[scope][level].sort { $0.score > $1.score }
                    self.currentScores = self.resultArrays[scope][level]
                    self.myTableView.reloadData()
                    self.myTableView.isHidden = false
                    self.aiv.stopAnimating()
                    self.alreadyLoaded[scope][level] = true
                } else {
                    print(error!)
                }
            })
        }
    
    }
    
    func homeButtonPressed(_ sender: AnyObject) {
        appDelegate.level = "None"
        let slvc = storyboard?.instantiateViewController(withIdentifier: "SelectLevelViewController") as! SelectLevelViewController
        self.present(slvc, animated: false, completion: nil)
    }


}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}
