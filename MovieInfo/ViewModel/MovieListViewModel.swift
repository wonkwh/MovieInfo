//
//  MovieListViewModel.swift
//  MovieInfo
//
//  Created by wonkwh on 02/04/2019.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MovieListViewModel {
    private let movieService: MovieService
    private let bag = DisposeBag()
    
    private let _movies = BehaviorRelay<[Movie]>(value: [])
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    private let _error = BehaviorRelay<String?>(value: nil)
    
    var isFetching: Driver<Bool> {
        return _isFetching.asDriver()
    }
    
    var movies: Driver<[Movie]> {
        return _movies.asDriver()
    }
    
    var error: Driver<String?> {
        return _error.asDriver()
    }
    
    var hasError: Bool {
        return _error.value != nil
    }
    
    var numberOfMovies: Int {
        return _movies.value.count
    }
    
    init(endpoint: Driver<Endpoint>, movieService: MovieService) {
        self.movieService = movieService
        endpoint.drive(onNext: { [weak self] (endpoint) in
            self?.fetchMovies(endpoint: endpoint)
        }).disposed(by: bag)
    }
    
    private func fetchMovies(endpoint: Endpoint) {
        self._movies.accept([])
        self._isFetching.accept(true)
        self._error.accept(nil)
        
        movieService.fetchMovies(from: endpoint, params: nil, successHandler: {[weak self] (response) in
            self?._isFetching.accept(false)
            self?._error.accept(nil)
            self?._movies.accept(response.results)
        }) { [weak self] (error) in
            self?._isFetching.accept(false)
            self?._error.accept(error.localizedDescription)
        }
    }
    
    func viewModelForMovie(at index: Int) -> MovieViewModel? {
        guard index < _movies.value.count else {
            return nil
        }
        
        return MovieViewModel(movie: _movies.value[index])
    }
}
