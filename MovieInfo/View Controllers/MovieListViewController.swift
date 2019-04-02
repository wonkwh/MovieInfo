//
//  MovieListViewController.swift
//  MovieInfo
//
//  Modified by Kwanghyun.won on 01/04/19.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift

class MovieListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var viewModel: MovieListViewModel!
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel =
            MovieListViewModel(endpoint:
                segmentedControl.rx.selectedSegmentIndex
                .map({ Endpoint(index: $0) ?? .nowPlaying             }).asDriver(onErrorJustReturn: .nowPlaying),
                                       movieService:    MovieStore.shared)

        viewModel.movies.drive(onNext: { [unowned self] (_) in
            self.tableView.reloadData()
        }).disposed(by:bag)
        
        viewModel.isFetching
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: bag)
        viewModel.error.drive(onNext: { [unowned self] (error) in
            self.infoLabel.text = error
            self.infoLabel.isHidden = self.viewModel.hasError
        }).disposed(by: bag)
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
}

extension MovieListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        if let viewModel = viewModel.viewModelForMovie(at: indexPath.row) {
            cell.configure(viewModel: viewModel)
        }

        return cell
    }
}
