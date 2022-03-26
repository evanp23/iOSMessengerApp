import UIKit

class ContactsViewController : UIViewController{
    var testLabel: UILabel
    
    init(message: String){
        self.testLabel = {
            let lbl = UILabel(frame: CGRect(x: 0, y: 88, width: UIScreen.main.bounds.width, height: 60))
            lbl.text = message
            lbl.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.medium)
            lbl.textColor = UIColor.systemRed
            lbl.textAlignment = NSTextAlignment.center
            return lbl
        }()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(testLabel)
    }
}
