require 'clash'

count = Clash::Tests.new().tests.size
FileUtils.mkdir_p('_output')

(1..count).each do |t|
  system("clash #{t} > _output/#{t}")
end

# substitute paths output from Jekyll
%w{1 2}.each do |f|
  content = File.open("_output/#{f}").read
  content = content.gsub(/Configuration file: .+\//, 'Configuration file: ') 
    .gsub(/Source: .+\//, 'Source: ') 
    .gsub(/Destination: .+\//, 'Destination: ')

  File.open("_output/#{f}", 'w') { |f| f.write(content) }
end

