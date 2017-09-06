//
//  ErrorHandlingTableViewController.swift
//  Example-iOS
//
//  Created by Eleni Papanikolopoulou on 05/08/2017.
//  Copyright © 2017 Workable. All rights reserved.
//

import UIKit
import ErrorHandler
import Alamofire

class ErrorHandlingTableViewController: UITableViewController {
    
    private let errorsAndTitles: [(Error, String)] = [
        (AFError(statusCode: 401), "401 Unauthorized error"),
        (NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: [NSLocalizedDescriptionKey: "Not connected to the internet"]) , "Offline Error"),
        (AFError(statusCode: 400), "400 (4xx client errors)"),
        (AFError(statusCode: 402), "401 (4xx client errors)"),
        (AFError(statusCode: 500), "500"),
        (CustomError.parsingError, "Parsing error")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return errorsAndTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "errorCell", for: indexPath)
        cell.textLabel?.text = errorsAndTitles[indexPath.row].1
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let error: Error = errorsAndTitles[indexPath.row].0
        
        switch indexPath.row {
        case 3:
            // Lets say thatin this case as a single exception in our app we want to provide for 401 errors
            //  the more generic error message about 4xx errors
            ErrorHandler.default
                .onAFError(withStatus: 401, do: { (error) -> MatchingPolicy in
                    return .continueMatching
                })
                .handle(error)
        case 4:
            // Let's say that in this case we also want to do some additional action if it is any invalid http status error
            ErrorHandler.default
                .on(tag: "http", do: { (_) -> MatchingPolicy in
                    print("Oh dear! They tapped on the 5th row and also got an invalid http status!")
                    return .continueMatching
                })
                .handle(error)
        default:
            ErrorHandler.default
                .handle(error)
        }
    }
}
