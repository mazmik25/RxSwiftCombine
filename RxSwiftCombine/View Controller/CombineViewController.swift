//
//  CombineViewController.swift
//  RxSwiftCombine
//
//  Created by Azmi Muhammad on 28/11/20.
//

import UIKit

class CombineViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  var items: [MoviesOutput] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    requestData()
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .none
    tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    tableView.rowHeight = UITableView.automaticDimension
  }
  
  private func requestData() {
    HTTPClient<GetMoviesBodyResponse>(
      parameters: [
        "api_key" : "44755119354772a89e87cfd9ccef85f3",
        "page": 1
      ], path: "https://api.themoviedb.org/3/movie/now_playing",
      method: .GET
    ).requestWithCombine { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .success(let response):
        self.items = response.results.compactMap {
          MoviesOutput(title: $0.title,
                       description: $0.overview,
                       posterPath: $0.posterPath)
        }
        self.tableView.reloadData()
      case .failure(let error): print(error)
      }
    }
  }
}

extension CombineViewController: UITableViewDelegate, UITableViewDataSource {
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
