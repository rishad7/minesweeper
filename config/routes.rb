Rails.application.routes.draw do
  root "site#index"
  get '/:row_id/:column_id', to: 'site#index', :constraints => { :row_id => /[0-9]+(\%7C[0-9]+)*/, :column_id => /[0-9]+(\%7C[0-9]+)*/ }
end
