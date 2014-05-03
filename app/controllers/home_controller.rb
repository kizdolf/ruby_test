class HomeController < ApplicationController

  helper_method :dump_ldap
  HOST = "ldap.42.fr"
  PORT = 636
  BASE = "ou=2013,ou=people,dc=42,dc=fr"
  FN = "first-name"
  LN = "last-name"

  def view
  	if user_signed_in?
  	  redirect_to home_intra_path
  	end
    if Student.all.empty?
      @html = "DB is in creation... please wait!"
    else
      @html = "DB LOADED"
    end
  end

  def intra
  	if params[:login].blank? or params[:mdp].blank? and !user_signed_in?
  		redirect_to root_path
  		return
  	end
  	if user_signed_in?
  	  @infos = get_infos(current_user[:email])
   	  return
  	end
    c = conn_ldap(params[:login], params[:mdp])
    if log_as(params[:login], params[:mdp], c)
      @infos = search(c,  params[:login], params[:mdp])
    else
      redirect_to :back
    end
  end

  def dash
  end

  def dump_ldap
    c = conn_ldap("jburet", "public6542ENEMY")
    filter = Net::LDAP::Filter.eq("uid", "*")
    treebase = "dc=42,dc=fr"
    c.bind_as(:base => BASE,:filter => "(uid=jburet)", :password => "public6542ENEMY")
    ldap =  c.search( :base => treebase, :filter => filter,  :return_result => true)
  l = Array.new
  ldap.each do |e|
    l.push(:uid => e[:uid].first,
      :cn => e[:cn].first,
      :uidNumber => e[:uidnumber].first,
      :picture => "https://cdn.42.fr/userprofil/profilview/#{e[:uid].first}.jpg",
      :gidNumber => e[:gidnumber].first,
      :mail => e[:alias].first,
      :firstName => e[FN].first,
      :lastName => e[LN].first)
    end
    Student.create(l)
  end

  private
  def log_as(user, mdp, c)
    if c.bind_as(:base => BASE, :filter => "(uid=#{user})", :password => mdp)
      return true
    else
      return false
    end
  end

  private
  def search(c, query, mdp)
    filter = Net::LDAP::Filter.eq("uid", query)
    treebase = "dc=42,dc=fr"
    ldap = c.search( :base => treebase, :filter => filter,  :return_result => true)
    l = Hash.new
    ldap.each do |e|
      l["uid"] = e[:uid].first
      l["cn"] = e[:cn].first,
      l["uidNumber"] = e[:uidnumber].first
      l["picture"] = "https://cdn.42.fr/userprofil/profilview/#{e[:uid].first}.jpg"
      l["gidNumber"] = e[:gidnumber].first
      l["mail"] = e[:alias].first
      l["firstName"] = e[FN].first
      l["lastName"] = e[LN].first
    end
    u = User.where(:email => "#{query}@student.42.fr")
    u.each do |a|
      a.destroy
    end
    sign_in(User.create(:password => mdp, :email => "#{query}@student.42.fr"))	
    return l
  end

  private
  def conn_ldap(user, mdp)
  	 return (Net::LDAP.new(
      :host => HOST,
      :port => PORT,
      :base => BASE,
      :encryption => {:method => :simple_tls},
      :username => user,
      :password => mdp))
  end

  private
  def get_infos(mail)
  	 p = Student.where(:mail => mail)
  	  infos = Hash.new
  	  p.each do |v|
	  	  infos["uid"] = v[:uid]
	      infos["cn"] = v[:cn]
	      infos["uidNumber"] = v[:uidnumber]
	      infos["picture"] = "https://cdn.42.fr/userprofil/profilview/#{v[:uid]}.jpg"
	      infos["gidNumber"] = v[:gidnumber]
	      infos["mail"] = v[:alias]
	      infos["firstName"] = v[FN]
	      infos["lastName"] = v[LN]
  	  end
  	  return infos
  end
end
