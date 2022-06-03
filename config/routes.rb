Rails.application.routes.draw do
  root "site#index"
  get '/:row_id/:column_id', to: 'site#index'
end
