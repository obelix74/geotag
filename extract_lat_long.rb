require 'rexml/document'
require 'tzinfo'
require 'yaml'

# A class that geotags RAW Images by reading lat / long from a GPX file
RAW_DIRECTORY="/Volumes/Data/Data/Pictures/2021/JMT"
GPX_FILE=RAW_DIRECTORY+"/Silver_lake_Rush_Creek_to_Bishop_Pass_Le_Conte_Canyon_.gpx"
# GPX_FILE=RAW_DIRECTORY+"/test.gpx"

file = File.new(GPX_FILE)
doc = REXML::Document.new(file)
trkseg = doc.elements['gpx'].elements['trk'].elements['trkseg']
elements = trkseg.elements
all_lat_long = {}
elements.each do |element|
    lat = element['lat']
    lon = element['lon']
    ele = element.elements['ele'][0]
    time = element.elements['time'][0]
    one_entry = {}
    one_entry[:lat] = lat
    one_entry[:lon] = lon
    one_entry[:ele] = ele.to_s
    d = Time.parse(time.to_s)
    all_lat_long[d] = one_entry
end
yaml_file = "#{RAW_DIRECTORY}/lat_long.yaml"
File.open(yaml_file, 'w') do |file|
    file.write all_lat_long.to_yaml
end 
