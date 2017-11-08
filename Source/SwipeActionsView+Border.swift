// Not elegant, at all, but this will do for now. Should refactor later when we have more time.
extension SwipeActionsView {
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let rgbValue: CGFloat = 230/255
        self.layer.borderColor = UIColor(red: rgbValue, green: rgbValue, blue: rgbValue, alpha: 1).cgColor
        self.backgroundColor = UIColor.blue
        self.layer.borderWidth = 0.5
    }

}
