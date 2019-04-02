//
//  MovieSearchViewModel.swift
//  MovieInfo
//
//  Created by wonkwh on 02/04/2019.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MovieSearchViewModel {
    private let movieService: MovieService
    private let disposeBag = DisposeBag()
    
    private let _movies = BehaviorRelay<[Movie]>(value: [])
    private let _isSearching = BehaviorRelay<Bool>(value: false)
    private let _info = BehaviorRelay<String?>(value: nil)
    
    var isSearching: Driver<Bool> {
        return _isSearching.asDriver()
    }
    var movies: Driver<[Movie]> {
        return _movies.asDriver()
    }
    var info: Driver<String?> {
        return _info.asDriver()
    }
    var hasInfo: Bool {
        return _info.value != nil
    }
    var numberOfMovies: Int {
        return _movies.value.count
    }
    
    init(query: Driver<String>, service: MovieService) {
        self.movieService = service
        
        query.throttle(1.0)
            .distinctUntilChanged()
            .drive(onNext: {[weak self] (query) in
                self?.searchMovie(query: query)
                if query.isEmpty {
                    self?._movies.accept([])
                    self?._info.accept("Start searching your favourite movies")
                }
                }).disposed(by: disposeBag)
    }
    
    func viewModelForMovie(at index:Int) -> MovieViewModel? {
        guard index < _movies.value.count else {
            return nil
        }
        return MovieViewModel(movie: _movies.value[index])
    }
    
    private func searchMovie(query: String?) {
        guard let query = query, !query.isEmpty else {
            return
        }
        
        self._movies.accept([])
        self._isSearching.accept(true)
        self._info.accept(nil)
        
        movieService.searchMovie(query: query, params: nil, successHandler: {[weak self] (response) in
            self?._isSearching.accept(false)
            if response.totalResults == 0 {
                self?._info.accept("No results for \(query)")
            }
            self?._movies.accept(Array(response.results.prefix(6)))
        }) { [weak self] (error) in
            self?._isSearching.accept(false)
            self?._info.accept(error.localizedDescription)
        }
    }
}
