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
    
    var scope: UISegmentedControl!
    var level: UISegmentedControl!
    
    var myCitizenScores: [Result]! = []
    var myPatriotScores: [Result]! = []
    var myFoundingFatherScores: [Result]! = []
    var allCitizenScores: [Result]! = []
    var allPatriotScores: [Result]! = []
    var allFoundingFatherScores: [Result]! = []
    
    var aiv: UIActivityIndicatorView!
    
    var currentScores: [Result]! = []
    
    var resultArrays: [[[Result]]]!
    var alreadyLoaded: [[Bool]]!
    
    override func viewDidLoad() {
        
        let width = screenRect.width
        let height = screenRect.height
        
        scope = UISegmentedControl(items: ["My Scores", "All Scores"])
        scope.frame = CGRect(x: 10, y: 30, width: width - 20, height: 25)
        scope.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for:.valueChanged)
        scope.selectedSegmentIndex = 0
        
        level = UISegmentedControl(items: ["Citizen", "Patriot", "Founding Father"])
        level.frame = CGRect(x: 10, y: 65, width: width - 20, height: 25)
        level.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for:.valueChanged)
        level.selectedSegmentIndex = 0
        
        aiv = UIActivityIndicatorView(frame: CGRect(x:width/2-10,y: 120, width: 20, height: 20))
        aiv.hidesWhenStopped = true
        aiv.color = .lightGray
        
        resultArrays = [[myCitizenScores,myPatriotScores,myFoundingFatherScores],[allCitizenScores,allPatriotScores,allFoundingFatherScores]]
        alreadyLoaded = [[false, false, false], [false, false, false]]
        
        myTableView.frame = CGRect(x: 0, y: 100, width: width, height: height-100)
        
        
        self.view.addSubview(scope)
        self.view.addSubview(level)
        self.view.addSubview(aiv)
        
        myTableView.isHidden = true
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
            cell.detailTextLabel?.text = currentScores[indexPath.row].score
        }
        return cell
    }
    
    func segmentedControlValueChanged(_ sender: AnyObject) {
        myTableView.isHidden = true
        aiv.startAnimating()
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
