import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var labelAccuracy: UILabel!
    @IBOutlet weak var sliderAccuracy: UISlider!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var sliderDistance: UISlider!
    @IBOutlet weak var labelRefreshRate: UILabel!
    @IBOutlet weak var sliderRefreshRate: UISlider!

    @IBAction func Logout(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject("", forKey: "username")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "score")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let accuracy = Float(NSUserDefaults.standardUserDefaults().integerForKey("accuracy"))

        sliderAccuracy.value = accuracy
        labelAccuracy.text = String(Int(accuracy))

        let distance = Float(NSUserDefaults.standardUserDefaults().integerForKey("distance"))

        sliderDistance.value = distance
        labelDistance.text = String(Int(distance))

        let refreshRate = NSUserDefaults.standardUserDefaults().integerForKey("refreshRate")

        sliderRefreshRate.value = Float(refreshRate)
        labelRefreshRate.text = String(refreshRate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    @IBAction func accuracyChanged(sender: UISlider) {
        let accuracy = Int(sender.value)

        self.labelAccuracy.text = String(accuracy)
        NSUserDefaults.standardUserDefaults().setInteger(accuracy, forKey: "accuracy")
    }

    @IBAction func distanceChanged(sender: UISlider) {
        let distance = Int(sender.value)

        self.labelDistance.text = String(distance)
        NSUserDefaults.standardUserDefaults().setInteger(distance, forKey: "distance")
    }

    @IBAction func refreshRateChanged(sender: UISlider) {
        let refreshRate = Int(sender.value)

        self.labelRefreshRate.text = String(refreshRate)
        NSUserDefaults.standardUserDefaults().setInteger(refreshRate, forKey: "refreshRate")
    }
}
