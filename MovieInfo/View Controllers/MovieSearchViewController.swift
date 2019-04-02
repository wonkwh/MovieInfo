//
//  MovieSearchViewController.swift
//  MovieInfo
//
//  Modified by Kwanghyun.won on 01/04/19.
//

import UIKit
import RxCocoa
import RxSwift

class MovieSearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    var movieSearchViewModel: MovieSearchViewModel!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        let searchBar = self.navigationItem.searchController!.searchBar
        movieSearchViewModel = MovieSearchViewModel(query: searchBar.rx.text.orEmpty.asDriver(),
                                                    service: MovieStore.shared)
        
        movieSearchViewModel.movies.drive(onNext: { [unowned self] (_) in
            self.tableView.reloadData()
            }).disposed(by: bag)
        
        movieSearchViewModel.isSearching.asDriver()
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: bag)
        
        movieSearchViewModel.info.asDriver()
            .drive(onNext: { [unowned self] (info) in
                self.infoLabel.text = info
                self.infoLabel.isHidden = !self.movieSearchViewModel.hasInfo
            }).disposed(by: bag)
        

        searchBar.rx.searchButtonClicked
                .asDriver(onErrorJustReturn: ())
                .drive(onNext: {[unowned searchBar] in
                    searchBar.resignFirstResponder()
                    }).disposed(by: bag)
        
        searchBar.rx.cancelButtonClicked
                .asDriver(onErrorJustReturn: ())
            .drive(onNext: {[unowned searchBar] in
                searchBar.resignFirstResponder()
                }).disposed(by: bag)
        
        setupTableView()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        self.definesPresentationContext = true
        navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        
        navigationItem.searchController?.searchBar.sizeToFit()
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
}

extension MovieSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieSearchViewModel.numberOfMovies
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        if let movieViewModel = movieSearchViewModel.viewModelForMovie(at: indexPath.row) {
            cell.configure(viewModel: movieViewModel)
        }
        return cell
    }
}
