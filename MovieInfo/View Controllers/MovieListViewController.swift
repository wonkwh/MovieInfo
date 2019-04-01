//
//  MovieListViewController.swift
//  MovieInfo
//
//  Modified by Kwanghyun.won on 01/04/19.
//

import UIKit
import Kingfisher

class MovieListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let movieService: MovieService = MovieStore.shared
    var movies = [Movie]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var endpoint = Endpoint.nowPlaying {
        didSet {
            fetchMovies()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        setupTableView()
        fetchMovies()
    }
    
    private func fetchMovies() {
        self.movies = []
        activityIndicatorView.startAnimating()
        infoLabel.isHidden = true
        
        movieService.fetchMovies(from: endpoint, params: nil, successHandler: {[unowned self] (response) in
            self.activityIndicatorView.stopAnimating()
            self.movies = response.results
        }) { [unowned self] (error) in
            self.activityIndicatorView.stopAnimating()
            self.infoLabel.text = error.localizedDescription
            self.infoLabel.isHidden = false
        }
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "MovieCell")
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        endpoint = sender.endpoint
    }
}

extension MovieListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let viewModel = MovieViewModel(movie: movies[indexPath.row])
        cell.configure(viewModel: viewModel)

        return cell
    }
}
