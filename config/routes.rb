Rails.application.routes.draw do
  root "site#index"
  get '/site/index', to: 'site#index'
  get '/:row_id/:column_id', to: 'site#index', :constraints => { :row_id => /[0-9]+(\%7C[0-9]+)*/, :column_id => /[0-9]+(\%7C[0-9]+)*/ }
  resources :results, only: [:create, :show, :index] do
    collection do 
      get '/view_game_board/:id', to: 'results#view_game_board'
    end
  end
  get '/mode/:type', to: 'site#mode'
  get '/custom', to: 'site#custom'
end
