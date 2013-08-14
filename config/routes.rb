Flow::Application.routes.draw do
  devise_for :users
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  focused_controller_routes do
    resources :boards do
      resources :stories, only: :index
      member { get :events }

      # You can re-synchronize the board with Pivotal Tracker by visiting the
      # /boards/{id}/synchronize url. This will update all local stories with
      # the data gathered from Pivotal Tracker. This link is not visible in the
      # ui and should only be used when absolutely neccesary.
      #
      member { get :synchronize }
    end

    post 'remote/activity' => 'remote#activity'

    root to: 'boards#show', id: '1'
  end
end
