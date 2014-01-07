# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'holidays', :to => 'holidays#show'

post 'holidays/create' , :to => 'holidays#create'
post 'holidays/create_freeday' , :to => 'holidays#create_freeday'


post 'holidays/update' , :to => 'holidays#update'
post 'holidays/update_freeday' , :to => 'holidays#update_freeday'
post 'holidays/update_holidays_add' , :to => 'holidays#update_holidays_add'

get 'holidays/new/:id', :to => 'holidays#new'
get 'holidays/free/new' , :to => 'holidays#new_freeday'

get 'holidays/close' , :to => 'holidays#close_period'



get 'holidays/eloy' , :to => 'holidays#eloy'

get 'holidays/eloy2' , :to => 'holidays#eloy2'

get 'holidays/end' , :to => 'holidays#close_period2'


get 'holidays/edit/:id/:id_holidays' , :to => 'holidays#edit'
get 'holidays/delete/:id_holidays' , :to => 'holidays#delete'

get 'holidays/free/edit/:id_freeday' , :to => 'holidays#edit_freeday'
get 'holidays/free/delete/:id_freeday' , :to => 'holidays#delete_freeday'


#Holidays_add
get 'holidays_add/index' , :to => 'holidays_add#index'
get 'holidays_add/edit/:id_holidays_add/:id_user' , :to => 'holidays_add#edit'
get 'holidays_add/delete/:id_holidays_add/:id_user' , :to => 'holidays_add#delete'

post 'holidays_add/create' , :to => 'holidays_add#create'
post 'holidays_add/update' , :to => 'holidays_add#update'