//
//  ViewController.swift
//  GlyphTester
//
//  Created by Aaron Madlon-Kay on 5/31/16.
//  Copyright © 2016 Aaron Madlon-Kay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var goButton: UIButton!

    @IBAction func didPressGo(_ sender: UIButton) {
        progressBar.setProgress(0.0, animated: false)
        progressBar.isHidden = false
        goButton.isEnabled = false
        DispatchQueue.global(qos: .userInitiated).async {
            let outfile = Glyphs.compileData { current, max in
                DispatchQueue.main.async {
                    let progress = Double(current) / Double(max)
                    self.progressBar.setProgress(Float(progress), animated: true)
                }
            }
            DispatchQueue.main.async {
                self.progressBar.isHidden = true
                self.goButton.isEnabled = true
                let controller = UIActivityViewController(activityItems: [outfile], applicationActivities: nil)
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

