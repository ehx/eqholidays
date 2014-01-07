class HolidaysAddController < ApplicationController
  unloadable
  helper :vacaciones
  
  #año actual
  @@today_year = DateTime.now.year

    def index
        @mode = 'create'
        #Trae todos los usuarios activos para llenar combo
        @users = User.logged.status(User::STATUS_ACTIVE).order('firstname ASC')
        render :template => "holidays_add/form", :formats => [:html]
    end
    
    def edit
        @mode = 'update'
        @id_holidays_add = params[:id_holidays_add]
        @id_user = params[:id_user]
        @users = User.where("id = ?", @id_user)
        @holidays_add = Holidays_adds.find(@id_holidays_add)
        render :template => "holidays_add/form", :formats => [:html]
    end
    
    def delete
        #borra dia de vacaciones añadido
        @id_user = params[:id_user]
        @id_holidays_add = params[:id_holidays_add]
        @holidays_add = Holidays_adds.find(@id_holidays_add)
        if @holidays_add.delete then
            self.update_general(@holidays_add.user_id)                        
            flash[:notice] = translate 'holidays_delete' 
            redirect_to :controller=>'holidays', :action => 'new' , :id => @id_user
        else
            flash[:error] = translate 'holidays_error_id'
            redirect_to :controller=>'holidays', :action => 'new', :id => @id_user
        end
    end
    
    def update
        #Actualiza vacaciones añadidas por usuario
        @id_holidays_add = params[:id_holidays_add]
        @holidays_add = Holidays_adds.find(@id_holidays_add)

        if @holidays_add then
            @holidays_add.user_id = params[:user_id]
            @holidays_add.date = params[:holidays_add][:date]
            @holidays_add.days = params[:holidays_add][:days]
            @holidays_add.comment = params[:holidays_add][:comment]
            @holidays_add.save
            self.update_general(@holidays_add.user_id)
            flash[:notice] = translate 'holidays_update_ok'
            redirect_to :controller=>'holidays', :action => 'new', :id => @holidays_add.user_id
        else
            flash[:error] = translate 'holidays_error_fields'
            redirect_to :controller=>'holidays', :action => 'new', :id => @holidays_add.user_id
        end
    end
    
    def create
        #Crea vacaciones añadidas por usuario
        @holidays_add = Holidays_adds.new(params[:holidays_add])
        @holidays_add.user_id = params[:user_id]

        if @holidays_add.save then
            self.update_general(@holidays_add.user_id)
            flash[:notice] = translate 'holidays_add' 
            redirect_to :controller=>'holidays_add', :action => 'index'
        else
            flash[:error] = translate 'holidays_error_fields'
            redirect_to :controller=>'holidays_add', :action => 'index'
        end
    end
    
    def update_general(id_usr)
        #Trae todos los usuarios activos
        @users = User.find(id_usr)
		#Busca registro del usuario en tabla general
        holidays_general = Holidays.find(:all , :conditions => ["period = ? and user_id = ?" , @@today_year , @users.id]).first
        
        #Actualizo dias
        holidays_general.diff = holidays_general.days + holidays_general.days_acum + holidays_general.days_free - holidays_general.days_consumed
        #Guardo
		holidays_general.save
    end

end
