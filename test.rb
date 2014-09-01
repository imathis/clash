require 'clash'

count = Clash::Tests.new(path: 'test').tests.size
FileUtils.mkdir_p('test/_output')

(1..count).each do |t|
  system("clash test #{t} > test/_output/#{t}")
end

# substitute paths output from Jekyll
%w{1 2}.each do |f|
  content = File.open("test/_output/#{f}").read
  content = content.gsub(/Configuration file: .+\//, 'Configuration file: ') 
    .gsub(/Source: .+\//, 'Source: ') 
    .gsub(/Destination: .+\//, 'Destination: ')

  File.open("test/_output/#{f}", 'w') { |f| f.write(content) }
end

test = Clash::Tests.new(file: "test/.test.yml", path: 'test')
test.run

