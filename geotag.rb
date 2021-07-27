require 'yaml'
require 'mini_exiftool'

# A class that geotags RAW Images by reading lat / long from a GPX file
RAW_DIRECTORY="/Volumes/Data/Data/Pictures/2021/JMT"
YAML_FILE = "#{RAW_DIRECTORY}/lat_long.yaml"

latLongHash = YAML.load_file(YAML_FILE)

Dir.glob("#{RAW_DIRECTORY}/*.NEF") do |raw_file|
    exif = MiniExiftool.new(raw_file)
    dateTime = exif.date_time_original
    p dateTime
    # Ugly. EXIF does not tell you time zone, so hack it to tell we are in PDT
    time = Time.new(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.min, dateTime.sec, "-07:00")
    latLongResult = latLongHash[time]

    if (latLongResult)
        p "Updating #{raw_file}"
        exif.GPSLatitude = latLongResult[:lat]
        exif.GPSLongitude = latLongResult[:lon]
        exif.GPSLongitudeRef = "West"
        exif. GPSLatitudeRef = "North"
        exif.save 
    else
        p "Setting lat / lon to nil for #{raw_file}"
        exif.GPSLatitude = nil
        exif.GPSLongitude = nil
        exif.GPSLongitudeRef = nil
        exif. GPSLatitudeRef = nil
        exif.save 
    end 
end 
