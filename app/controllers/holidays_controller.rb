class HolidaysController < ApplicationController
  unloadable
  helper :custom_fields
  include CustomFieldsHelper
  require 'date'

  #año actual
  @@today_year = DateTime.now.year

    def show
        #Trae todos los feriados cargados
        @holidays_free_days = Holidays_free_days.order('date_free_day ASC').where('YEAR(date_free_day) = ?', @@today_year.to_s)
        
        sql =   "SELECT u.id , firstname, lastname, days, days_consumed, days_acum, days_free , diff , h.id
                 FROM `holidays` h
                 INNER JOIN users u ON u.id = user_id
                 WHERE u.id <> 1
                 AND period = " + @@today_year.to_s
        @holidays = ActiveRecord::Base.connection.execute(sql)
        
        @user = User.find(:first, :conditions => [ "id = ?", session['user_id']])
        render :template => "holidays/show", :formats => [:html]
        
    end
    
    def new
        @mode = 'create'
        @id_user = params[:id]
        @date_from = DateTime.new(@@today_year-1,8,31)   
        @date_to = DateTime.new(@@today_year,8,31)
        @holidays_user = Holidays_users.where("id_user = ? and (date_from >= ? and date_to <= ?)", @id_user, @date_from.strftime('%F'), @date_to.strftime('%F'))
        @user = User.find(:first, :conditions => [ "id = ?", @id_user])
        @holidays_add = Holidays_adds.order('date ASC').where("user_id = ? and (date > ? and date < ?)", @id_user , @date_from.strftime('%F'), @date_to.strftime('%F'))
        render :template => "holidays/form_holidays", :formats => [:html]
    end
    
    def new_freeday
        @mode = 'create'
        @free_days = Holidays_free_days.order('date_free_day ASC').where("enable = ?" , 1)
        render :template => "holidays/form_freeday", :formats => [:html]
    end
    
    def edit
        @mode = 'update'
        @id_user = params[:id]
        @id_holidays = params[:id_holidays]
        @holidays_user = Holidays_users.find(@id_holidays)
        @user = User.find(:first, :conditions => [ "id = ?", @id_user])
        render :template => "holidays/form_holidays", :formats => [:html]
    end
    
    def edit_freeday
        @mode = 'update'
        @id_freeday = params[:id_freeday]
        @holidays_freeday = Holidays_free_days.find(@id_freeday)
        render :template => "holidays/form_freeday", :formats => [:html]
    end
    
    def create
        days = 0
        @vacaciones = Holidays_users.new(params[:holidays_users])
        @vacaciones.id_user = params[:id_user]
        
        #valido que la fecha desde sea menor que la fecha hasta
        if @vacaciones.date_from <= @vacaciones.date_to then
            days = self.calculate(@vacaciones.date_from , @vacaciones.date_to )
            @vacaciones.days = days

            if @vacaciones.save then
            	self.update_holidays(@vacaciones.id_user , 'consumed')
                flash[:notice] = translate 'holidays_add' 
                redirect_to :controller=>'holidays', :action => 'new', :id => @vacaciones.id_user
            else
                flash[:error] = translate 'holidays_error_fields'
                redirect_to :controller=>'holidays', :action => 'new', :id => @vacaciones.id_user
            end
        else
            flash[:error] = translate 'holidays_error_date'
            redirect_to :controller=>'holidays', :action => 'new', :id => @vacaciones.id_user
        end
    end
    
    def create_freeday
        
        @free = Holidays_free_days.find(:first, :conditions => [ "date_free_day = ?", params[:holidays_free_days][:date_free_day] ])
        
        if @free.blank? then
            @freeday = Holidays_free_days.new()
            @freeday.date_free_day = params[:holidays_free_days][:date_free_day]
            @freeday.enable = params[:enable]
        
            if @freeday.save then
            	
                flash[:notice] = translate 'holidays_add' 
                redirect_to :controller=>'holidays', :action => 'show'
            else
                flash[:error] = translate 'holidays_error_fields'
                redirect_to :controller=>'holidays', :action => 'show'
            end
        else
            flash[:error] = translate 'holidays_error_duplicate'
            redirect_to :controller=>'holidays', :action => 'show'
        end
    end
    
    def update
        days = 0
        @holidays_user = Holidays_users.find(params[:id_holidays])
        
        if @holidays_user then
            @holidays_user.date_from = params[:holidays_users][:date_from]
            @holidays_user.date_to = params[:holidays_users][:date_to]
        
            #valido que la fecha desde sea menor que la fecha hasta
            if @holidays_user.date_from <= @holidays_user.date_to then   
                days = self.calculate(@holidays_user.date_from , @holidays_user.date_to)
                @holidays_user.days = days

                if @holidays_user.save then
                	self.update_holidays(@holidays_user.id_user , 'consumed')
                    flash[:notice] = translate 'holidays_update_ok'
                    redirect_to :controller=>'holidays', :action => 'new' , :id => params[:id_user]
                else
                    flash[:error] = translate 'holidays_error_fields'
                    redirect_to :controller=>'holidays', :action => 'form_holidays', :id => @vacaciones.id_user
                end
            else
                flash[:error] = translate 'holidays_error_date'
                redirect_to :controller=>'holidays', :action => 'new', :id => @holidays_user.id_user
            end
        end
    end
    
    def update_freeday
        @holidays_freeday = Holidays_free_days.find(params[:id_freeday])
    
        #Chequea que exista para poder actualizar
        if @holidays_freeday then
            
            #checkea valor del checkbox
            if params[:enable]
                @holidays_freeday.enable = 1
            else
                @holidays_freeday.enable = 0
            end
            
            @holidays_freeday.date_free_day = params[:holidays_free_days][:date_free_day]
            
            #Actualiza y muestra msj
            if @holidays_freeday.save then
                flash[:notice] = translate 'holidays_free_day_ok'
                redirect_to :controller=>'holidays', :action => 'show'
            else
                flash[:error] = translate 'holidays_free_day_error'
                redirect_to :controller=>'holidays', :action => 'new'
            end
        end
    end
    
    def delete
        #borra dia de vacaciones
        @id_holidays = params[:id_holidays]
        @holidays_user = Holidays_users.find(@id_holidays)

        if @holidays_user.delete then
        	self.update_holidays(@holidays_user.id_user , 'consumed')
        	
            flash[:notice] = translate 'holidays_delete' 
            redirect_to :controller=>'holidays', :action => 'new' , :id => @holidays_user.id_user
        else
            flash[:error] = translate 'holidays_error_id'
		    redirect_to :controller=>'holidays', :action => 'form_holidays', :id => @vacaciones.id_user
        end
    end
    
    def delete_freeday
        #borra dia feriado
        @id_freeday = params[:id_freeday]
        @holidays_freeday = Holidays_free_days.find(@id_freeday)
        
        if @holidays_freeday.delete then
            flash[:notice] = translate 'holidays_freeday_delete' 
            redirect_to :controller=>'holidays', :action => 'show'
        else
            flash[:error] = translate 'holidays_error_id'
            redirect_to :controller=>'holidays', :action => 'show'
        end
    end
    
    
    def calculate(date_from , date_to)
        ndays = 0
        weekend = 0
        @days = 0

        #Veo la diferencia entre los dias
        difference_days = (date_to - date_from).to_i + 1
        
        #Recorro todos los dias seleccionado de vacaciones , obtengo los sabados y domingos  
        first = DateTime.parse(params[:holidays_users][:date_from])
        last = DateTime.parse(params[:holidays_users][:date_to])
        
        first.upto(last) do |date|
            if  (date.strftime('%w') == '0') or (date.strftime('%w') == '6') then
                    weekend +=1
            end
        end

        #Cuento la cantidad de feriados que hay entre la fecha desde y hasta , sin contar los sabados y domingos
        sql_freedays = "SELECT count( * )
                        FROM `holidays_free_days`
                        WHERE `date_free_day` >= '" + date_from.to_s() + "' AND 
                              `date_free_day` <= '" + date_to.to_s()   + "' AND 
                              enable = 1 AND date_format( date_free_day, '%w' ) NOT IN ( 0, 6 )"
        free_days = ActiveRecord::Base.connection.execute(sql_freedays)
        free_days.each do | f |
            ndays = f[0]
        end
        
        days = difference_days - ndays - weekend
        
        #El numero de dias totales que se toma el usuario , sin contar los sabados domingos ni feriados
        return days
    end
    
    def close_period

        if @flagerror == 0 then
            flash[:notice] = translate 'holidays_close_ok'
            redirect_to :controller=>'holidays', :action => 'show'
        else    
            flash[:error] = translate 'holidays_close_error'
            redirect_to :controller=>'holidays', :action => 'show'
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
    
    #Actualiza tabla general de vacaciones
    def update_holidays(id_usr , mode)
        #Trae todos los usuarios activos
        @users = User.find(id_usr)
        
        #Busca registro del usuario en tabla general
        holidays_general = Holidays.find(:all , :conditions => ["period = ? and user_id = ?" , @@today_year , @users.id]).first
        
        
        if mode == 'consumed' then
            #Sql para recuperar dias de vacaciones en el periodo
            sql_days =" SELECT ifnull( sum( days ) , 0 )
                            FROM holidays_users
                            WHERE holidays_users.id_user = " + id_usr.to_s + "
                            AND (date_from >= '" + (@@today_year-1).to_s + "-10-31')
                            AND (date_to <= '" + @@today_year.to_s + "-10-31')"
                        
            #obtengo cantidad de dias del periodo
            sql_days_result = ActiveRecord::Base.connection.execute(sql_days)
            sql_days_result.each do | days |
                #Actualizo dias usados en el periodo
                holidays_general.days_consumed = days[0]
            end
        else
            #Sql para recuperar dias otorgados al usuario
            sql_free_days ="SELECT ifnull( sum( days ) , 0 )
                            FROM holidays_adds
                            WHERE user_id = " + id_usr.to_s + "
                            AND (date >= '" + (@@today_year-1).to_s + "-10-31')
                            AND (date <= '" + @@today_year.to_s + "-10-31')"
                        
            #obtengo cantidad de dias del periodo
            sql_free_days_result = ActiveRecord::Base.connection.execute(sql_free_days)
            sql_free_days_result.each do | days |
                #Actualizo dias otorgados en el periodo
                holidays_general.days_free = days[0]
            end
        end
        
        #Actualizo dias totales
        holidays_general.diff = holidays_general.days + holidays_general.days_acum + holidays_general.days_free - holidays_general.days_consumed
        #Guardo
        holidays_general.save
        
    end

    #Actualiza año actual con dias acumulados del año anterior
    def close_period2
    	
        #Trae todos los usuarios activos
        @users = User.logged.status(User::STATUS_ACTIVE).order('firstname ASC')
        
        #año siguiente        
        prev_year = @@today_year -1
        
        @users.each do |m|
            
            @holidays = Holidays.find(:all , :conditions => ["period = ? and user_id = ?" , prev_year , m.id])
            
            @holidays.each do |h|
                #busco vacaciones del periodo actual para actualizar
                holiday_update = Holidays.find(:first , :conditions => ["period = ? and user_id = ?" , @@today_year , m.id])
                if holiday_update then
                    #completo acumuladas del año anterior
                    holiday_update.days_acum = h.diff
                    #actualiza los dias que le quedan de vacaciones
                    holiday_update.diff = holiday_update.days + holiday_update.days_acum + holiday_update.days_free - holiday_update.days_consumed
    				holiday_update.save
    			end
            end
        end
    end
    
    def eloy
        #Trae todos los feriados cargados
        @holidays_free_days = Holidays_free_days.order('date_free_day ASC')
        
        #Trae todos los usuarios activos
        @users = User.logged.status(User::STATUS_ACTIVE).order('firstname ASC')
        
        #Trae la parametria de vacaciones
        holidays_parms = Holidays_parms.find(:all)
        
        #Variables
        date_by_user = ''
        date_by_user_view = ''
        @vacations_days = Hash.new
        @date_by_user2 = Hash.new
        @date_by_user_view = Hash.new
        @days_consumed = Hash.new
        @free_days = Hash.new
        @holidays_acum = Hash.new
        today_year = 0
        
        #año actual
        today_year = DateTime.now.year
        
        #Por cada uno de los usuarios activos
        @users.each do |m|
            
            #Sql para recuperar las fechas de campo personalizado , fecha extendida
            sql = " SELECT MIN(value)
                    FROM custom_fields a
                    INNER JOIN custom_values b ON a.id = b.custom_field_id
                    INNER JOIN users ON b.customized_id = users.id
                    WHERE users.id = " + m.id.to_s()
                    
            #Obtengo la fecha del usuario        
            date_user = ActiveRecord::Base.connection.execute(sql)
            
            date_user.each do | date_u |
                date_by_user = date_u[0]   
            end
        
            @date_by_user2[m.id] = DateTime.parse(date_by_user) 
            difference_days = (DateTime.now - @date_by_user2[m.id]).to_i
            #Sql para recuperar las fechas de campo personalizado , fecha de ingreso
            sql = " SELECT value
                    FROM custom_fields a
                    INNER JOIN custom_values b ON a.id = b.custom_field_id
                    INNER JOIN users ON b.customized_id = users.id
                    WHERE a.id = 10 AND users.id = " + m.id.to_s()
                    
            #Obtengo la fecha del usuario        
            date_user_view = ActiveRecord::Base.connection.execute(sql)
                
            date_user_view.each do | date_u |
                date_by_user_view = date_u[0]   
            end
                
            @date_by_user_view[m.id] = DateTime.parse(date_by_user_view)
                
            #Se fija en tabla de parametria cuanta cantidad de dias le pertenecen al usuario        
            holidays_parms.each do |parm|  
                if  difference_days > parm.days_min and 
                    difference_days <= parm.days_max  then
                    @vacations_days[m.id] = parm.days_holidays
                end
            end

            #Sql para recuperar el total de dias consumidos de vacaciones en este periodo
            sql_days = "SELECT IFNULL( sum( days ) , 0 )
                        FROM holidays_users
                        WHERE id_user = " + m.id.to_s() + " AND 
                        YEAR(date_from) = " + today_year.to_s + " AND 
                        YEAR(date_to) = " + today_year.to_s + "
                        GROUP BY id_user" 
                        
            days_consumed = ActiveRecord::Base.connection.execute(sql_days)
            
            days_consumed.each do | days |
                @days_consumed[m.id] = days[0]
            end
            
            #Sql para recuperar vacaciones antiguas
            sql_acum =" SELECT sum(days)
                        FROM `holidays_acums`
                        WHERE id_user = " + m.id.to_s() + "
                        AND period >= " + (today_year-2).to_s + "
                        GROUP BY `id_user`"
                    
            #Obtengo dias acumulados de los usuarios (2 periodos anteriores)
            days_acum = ActiveRecord::Base.connection.execute(sql_acum)
            
            days_acum.each do | day_a |
                @holidays_acum[m.id] = day_a[0]   
            end

            #Si tiene dias consumidos de vacaciones , se los descuenta de los dias disponibles  
            #Si tiene dias acumulados , se le suma a los disponibles
            if @days_consumed[m.id] then
                if @holidays_acum[m.id] then
                    if (@vacations_days[m.id] - @days_consumed[m.id]) > 0
                        @free_days[m.id] = @vacations_days[m.id] - @days_consumed[m.id] + @holidays_acum[m.id]
                    else
                        @free_days[m.id] = 0
                    end
                else
                    @free_days[m.id] = @vacations_days[m.id] - @days_consumed[m.id]
                end
            end

            if m.id != 1 then
                @holiday = Holidays.new()
                @holiday.period = today_year
                @holiday.user_id = m.id
                @holiday.days = @free_days[m.id]
                @holiday.days_consumed = @days_consumed[m.id]
                @holiday.save
            end
        end
    end


    def eloy2
        
        #Variables
        date_by_user = ''
        date_by_user_view = ''
        @vacations_days = Hash.new
        @date_by_user2 = Hash.new
        today_year = 0
        
        #Trae la parametria de vacaciones
        holidays_parms = Holidays_parms.find(:all)
        
        for i in 2014..2050
            
            #Trae todos los usuarios activos
            @users = User.logged.status(User::STATUS_ACTIVE).order('id ASC')
        
            #Por cada uno de los usuarios activos
            @users.each do |m|
    
                #Sql para recuperar las fechas de campo personalizado , fecha extendida
                sql = " SELECT MIN(value)
                        FROM custom_fields a
                        INNER JOIN custom_values b ON a.id = b.custom_field_id
                        INNER JOIN users ON b.customized_id = users.id
                        WHERE users.id = " + m.id.to_s()
                        
                #Obtengo la fecha del usuario        
                date_user = ActiveRecord::Base.connection.execute(sql)
                
                date_user.each do | date_u |
                    date_by_user = date_u[0]   
                end
            
                @date_by_user2[m.id] = DateTime.parse(date_by_user) 
                
                year = DateTime.new(i-1,8,31)

                difference_days = (year - @date_by_user2[m.id]).to_i

                #Se fija en tabla de parametria cuanta cantidad de dias le pertenecen al usuario        
                holidays_parms.each do |parm|  
                    if  difference_days > parm.days_min and 
                        difference_days <= parm.days_max  then
                        @vacations_days[m.id] = parm.days_holidays
                    end
                end

                @holidays = Holidays.where("user_id = ? AND period = ?", m.id , i).first

                if @holidays then
                    @holidays.days = @vacations_days[m.id]
                    @holidays.period = i
                    @holidays.save
                end
            end
        #end for
        end
    end

end