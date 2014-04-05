module Sinatra::UrlHandle
  def build_url(host, port, path, query)
    return URI::HTTP.build({:host => host, :path => path, :query => query}) if port.nil?
    return URI::HTTP.build({:host => host, :port => port, :path => path, :query => query}) unless port.nil?
  end

  def get_status(uri)
    uri_response = Net::HTTP.get_response(uri)
    uri_response.code
  end

  def get_content(uri)
    request = Net::HTTP::Get.new(uri.request_uri)
    uri_response = Net::HTTP.start(uri.host,uri.port) {|http| http.request(request)}

    uri_response
  end

  def post_data(content,uri,content_type)
    post = Net::HTTP::Post.new(uri.request_uri,content_type)
    post.body = content.force_encoding("utf-8")
    uri_response = Net::HTTP.start(uri.host,uri.port) {|http| http.request(post)}

    uri_response
  end

  def delete_file(uri)
    path = "#{uri.path}/?#{uri.query}"
    request = Net::HTTP::Delete.new(path)
    uri_response = Net::HTTP.start(uri.host) {|http| http.request(request)}
  
    uri_response.code
  end
end

