require 'sinatra'

configure do
  mime_type :m3u8, 'application/x-mpegURL'
end


get '/*.*' do |path, ext|
  [path, ext]
  if (ext == 'ts')
    content_type 'video/mp2t'
    redirect '/' + path
  end
end


# get '/*.*' do |path, ext|
#   [path, ext]
#   if (ext == 'm4a')
#     content_type 'audio/mp4'
#     redirect '/' + path
#   end
# end


get '/' do
  erb :index
end



