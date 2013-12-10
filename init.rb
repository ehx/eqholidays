Redmine::Plugin.register :eqholidays do
  name 'EqHolidays'
  author 'Eloy Colella'
  description 'Plugins para vacaciones'
  version '0.0.5'
  url 'http://www.equality.coop'
  author_url 'http://www.equality.coop'
  
  menu :top_menu, :eqholidays, { :controller => 'holidays', :action => 'show' }, :caption => 'Eqholidays'
end
