//
//  ViewController.swift
//  Yandex Course
//
//  Created by Vitaliy Pyatnikov on 15.07.2019.
//  Copyright © 2019 Vitaliy Pyatnikov. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    @IBAction func editNoteAction(_ sender: Any) {
        performSegue(withIdentifier: "EditNoteSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditNoteSegue" {
            guard let _ = segue.destination as? EditNoteViewController else {
                return
            }
        }
    }
}

