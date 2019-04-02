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
    
    var service: MovieService = MovieStore.shared
    // rx
    private var _movies = BehaviorRelay<[Movie]>(value: [])
    private let _isSearching = BehaviorRelay<Bool>(value: false)
    private let _info = BehaviorRelay<String?>(value: nil)

    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
        
        let movies = _movies.asDriver()
        movies.drive(onNext: { [unowned self] (_) in
            self.tableView.reloadData()
            }).disposed(by: bag)
        
        _isSearching.asDriver()
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: bag)
        
        _info.asDriver().drive(onNext: { [unowned self] (info) in
            self.infoLabel.text = info
            self.infoLabel.isHidden = (info != nil)
        }).disposed(by: bag)
        
        let searchBar = self.navigationItem.searchController!.searchBar
        searchBar.rx.searchButtonClicked
                .asDriver(onErrorJustReturn: ())
                .drive(onNext: {[unowned searchBar] in
                    searchBar.resignFirstResponder()
                    self.searchMovie(query: searchBar.text)
                    }).disposed(by: bag)
        
        searchBar.rx.cancelButtonClicked
                .asDriver(onErrorJustReturn: ())
            .drive(onNext: {[unowned searchBar] in
                searchBar.resignFirstResponder()
                self._movies.accept([])
                self._isSearching.accept(false)
                self._info.accept("Start searching your favourite movies")

                }).disposed(by: bag)
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        self.definesPresentationContext = true
        navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        
        navigationItem.searchController?.searchBar.sizeToFit()
        //navigationItem.searchController?.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
    
    private func searchMovie(query: String?) {
        guard let query = query, !query.isEmpty else {
            return
        }
        
        self._movies.accept([])
        self._isSearching.accept(true)
        self._info.accept(nil)
        service.searchMovie(query: query, params: nil, successHandler: {[unowned self] (response) in
            self._isSearching.accept(false)
            if response.totalResults == 0 {
                self._info.accept("No results for \(query)")
            }
            self._movies.accept(Array(response.results.prefix(6)))
        }) { [unowned self] (error) in
            self._isSearching.accept(false)
            self._info.accept(error.localizedDescription)
        }
        
    }
    
}

extension MovieSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _movies.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = _movies.value[indexPath.row]
        let movieViewModel = MovieViewModel(movie: movie)
        cell.configure(viewModel: movieViewModel)
        
        return cell
    }
}
