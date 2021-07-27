require 'yaml'
require 'mini_exiftool'

class Geotag
    # A class that geotags RAW Images by reading lat / long from a GPX file
    RAW_DIRECTORY="/Volumes/Data/Data/Pictures/2021/JMT"
    YAML_FILE = "#{RAW_DIRECTORY}/lat_long.yaml"

    def initialize
        @latLongHash = YAML.load_file(YAML_FILE)
    end

    def geotag
        Dir.glob("#{RAW_DIRECTORY}/*.NEF") do |raw_file|
            exif = MiniExiftool.new(raw_file)
            dateTime = exif.date_time_original
            p dateTime
            # Ugly. EXIF does not tell you time zone, so hack it to tell we are in PDT
            time = Time.new(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.min, dateTime.sec, "-07:00")
            latLongResult = getLatLong(time)
        
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
    end

    def getLatLong(time)
        latLong = @latLongHash[time]

        # If it is nil, go back 30 seconds, go forward 30 seconds and look for it
        if (latLong == nil) 
             (1...30).each do |i|
                latLong = @latLongHash[time - i]
                if (latLong != nil) 
                    break
                end
                latLong = @latLongHash[time + i]
                if (latLong != nil)
                    break
                end
            end
        end

        return latLong
    end
end 



if __FILE__ == $0
    Geotag.new.geotag
  end