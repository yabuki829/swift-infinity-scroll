import UIKit
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource ,UIScrollViewDelegate{
    
    
    let tableView: UITableView = {
        let tb = UITableView(frame: .zero, style: .plain)
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tb
    }()
    
    var data = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        APIManager.shared.fetchData { [weak self]result in
            switch result {
                case .success(let resultData):
                    self?.data = resultData
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                    
                case .failure(let error):
                    print(error)
            }
        }
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let max = tableView.contentSize.height-100-scrollView.frame.size.height
        if position > max {
        
            guard APIManager.shared.isLoading == false else{
                return
            }
            // loading を表示する
            tableView.tableFooterView = createFooterLoadingSpinnerView()
            //取得したらisLoadingをFalseにする
            APIManager.shared.fetchData(pagenation: true) { [weak self]result in
                print("追加でデータを取得する")
                switch result{
                case .success(let resultData):
                    //loadingを止める
                    DispatchQueue.main.async {
                        self?.tableView.tableFooterView = nil
                    }
                    self?.data.append(contentsOf:resultData)
                    DispatchQueue.main.async {
                        self?.tableView.tableFooterView = nil
                        self?.tableView.reloadData()
                        
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
            
            
        }
    }
    
    private func createFooterLoadingSpinnerView() -> UIView {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        let spinnerView = UIActivityIndicatorView()
        spinnerView.center = footer.center
        footer.addSubview(spinnerView)
        spinnerView.startAnimating()
        return footer
    }

}


class APIManager{
    
    static let shared = APIManager()
    
    var isLoading = false
    
    func fetchData(pagenation:Bool = false,comleation: @escaping (Result<[String],Error>) -> Void){
        if pagenation {
            isLoading = true
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now()+1) {
            let originalData = [
              "Apple",
              "Google",
              "Amazon",
              "Facebook",
              "Apple",
              "Google",
              "Amazon",
              "Facebook",
              "Apple",
              "Google",
              "Amazon",
              "Facebook",
              "Apple",
              "Google",
              "Amazon",
              "Facebook",
              "最後"
            ]
            
            let newData = [
              "Merucari","Yahoo!","Rakuten","Line","Twitter","最後"
            ]
            comleation(.success(pagenation ? newData :originalData))
            if self.isLoading {
                self.isLoading = false
            }
        }
    }
}



