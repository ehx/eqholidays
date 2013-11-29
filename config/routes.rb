# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'holidays', :to => 'holidays#show'

post 'holidays/create' , :to => 'holidays#create'
post 'holidays/create_freeday' , :to => 'holidays#create_freeday'


post 'holidays/update' , :to => 'holidays#update'
post 'holidays/update_freeday' , :to => 'holidays#update_freeday'

get 'holidays/new/:id', :to => 'holidays#new'
get 'holidays/free/new' , :to => 'holidays#new_freeday'

get 'holidays/free/edit/:id_freeday' , :to => 'holidays#edit_freeday'
get 'holidays/edit/:id/:id_holidays' , :to => 'holidays#edit'
get 'holidays/free/delete/:id_freeday' , :to => 'holidays#delete_freeday'
get 'holidays/delete/:id_holidays' , :to => 'holidays#delete'