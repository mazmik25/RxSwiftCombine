//
//  RxSwiftViewController.swift
//  RxSwiftCombine
//
//  Created by Azmi Muhammad on 28/11/20.
//

import UIKit
import RxSwift

class RxSwiftViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  private let disposeBag: DisposeBag = DisposeBag()
  var items: [MoviesOutput] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    request()
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .none
    tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    tableView.rowHeight = UITableView.automaticDimension
  }
  
  private func request() {
    HTTPClient<GetMoviesBodyResponse>(
      parameters: [
        "api_key" : "44755119354772a89e87cfd9ccef85f3",
        "page": 1
      ], path: "https://api.themoviedb.org/3/movie/now_playing",
      method: .GET).requestWithRxSwift()
      .map { responses -> [MoviesOutput] in
        let items: [MoviesOutput] = responses.results.compactMap {
          MoviesOutput(title: $0.title, description: $0.overview, posterPath: $0.posterPath)
        }
        return items
      }
      .subscribe { event in
        switch event {
        case .success(let response):
          self.items = response
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        case .error(let error): print(error)
        }
      }.disposed(by: disposeBag)
  }
}

extension RxSwiftViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as? MovieCell else { return UITableViewCell() }
    let item: MoviesOutput = items[indexPath.row]
    cell.movieTitleLabel.text = item.title
    cell.movieDescriptionLabel.text = item.description
    cell.movieBannerImageView.loadPoster(path: item.posterPath)
    cell.movieBannerImageView.contentMode = .scaleAspectFill
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
