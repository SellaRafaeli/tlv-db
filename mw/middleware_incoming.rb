use Rack::Parser, :content_types => {
  'application/json'  => Proc.new { |body| ::MultiJson.decode body }
}

def request_expects_json?
  request.xhr? || request.path_info.starts_with?("/api") 
end

def request_is_public?
  request_fullpath.to_s.starts_with?('/css/','/js/','/img/') rescue false 
end

NUMERIC_PARAMS = [:price]

before do     
  @time_started_request = Time.now 

  NUMERIC_PARAMS.each {|p| params[p] = params[p].to_f if params[p].present? }
end

def cu 
  @cu = session && session[:user_id] && $users.get(session[:user_id]) rescue nil #for tux
end

def cuid 
  cu && cu['_id']
end

def cusername 
  cu && cu['username']
end

def cuemail
  cu && cu['email']
end

def request_path
  _req.path rescue nil #for tux
end

def request_fullpath
  _req.fullpath rescue nil #for tux 
end

def _req 
  request rescue OpenStruct.new #allows us to call 'request' safely, including within tux
end

def _params #allows us to call 'params' safely, including within tux
  params rescue {}
end

#get val from params
def params_num(key, opts = {})
  val = params[key]  
  
  return opts[:default] if !val.present? && opts[:default]  

  val = to_numeric(val)
  val = opts[:max] if opts[:max] && val > opts[:max].to_f
  val = opts[:min] if opts[:min] && val < opts[:min].to_f
  return val 
end

def params_val(key, opts = {})
  params[key].present? ? params[key] : ( (opts && opts[:default]) ? opts[:default] : nil )
end