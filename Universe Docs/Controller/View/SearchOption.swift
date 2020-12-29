//
//  SearchOption.swift
//  Universe Docs
//
//  Created by Kumar Muthaiah on 09/02/19.
//  Copyright © 2019 Universe Docs. All rights reserved.
//
//Copyright 2020 Kumar Muthaiah
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
import UIKit

class SearchOption: UIViewController {
    @IBOutlet weak var byOption4Label: UILabel!
    @IBOutlet weak var byOption3Label: UILabel!
    @IBOutlet weak var byOption2Label: UILabel!
    @IBOutlet weak var byOption1Label: UILabel!
    @IBOutlet weak var byOption4: UISwitch!
    @IBOutlet weak var byOption3: UISwitch!
    @IBOutlet weak var byOption1: UISwitch!
    @IBOutlet weak var byOption2: UISwitch!
    public var width: Int = 0
    public var height: Int = 0
    public var optionLabel = [String]()
    public var optionSelection = [Bool]()
    public var delegate: SearchOptionDelegate?
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func getOptionSelection() {
        optionSelection[0] = byOption1.isOn
        optionSelection[1] = byOption2.isOn
        optionSelection[2] = byOption3.isOn
        optionSelection[3] = byOption4.isOn
    }

    public func setOptionSelection(optionSelection: [Bool]) {
        self.optionSelection.append(contentsOf: optionSelection)
    }

    public func setOptionLabel(optionLabel: [String]) {
        self.optionLabel.append(contentsOf: optionLabel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: width, height: height)
        byOption1Label.text = optionLabel[0]
        byOption2Label.text = optionLabel[1]
        byOption3Label.text = optionLabel[2]
        byOption4Label.text = optionLabel[3]
        byOption1.setOn(optionSelection[0], animated: true)
        byOption2.setOn(optionSelection[1], animated: true)
        byOption3.setOn(optionSelection[2], animated: true)
        byOption4.setOn(optionSelection[3], animated: true)
        byOption1.addTarget(self, action: #selector(handleButtonPressed(_:)), for: .touchUpInside)
        byOption2.addTarget(self, action: #selector(handleButtonPressed(_:)), for: .touchUpInside)
        byOption3.addTarget(self, action: #selector(handleButtonPressed(_:)), for: .touchUpInside)
        byOption4.addTarget(self, action: #selector(handleButtonPressed(_:)), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @objc private func handleButtonPressed(_ sender: UISwitch) {
        getOptionSelection()

        delegate!.searchOptionsSelected(options: optionSelection)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
