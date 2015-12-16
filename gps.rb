class GPS
	# Initialize pins for UART device
	@uart4 = UARTDevice.new(:UART4, 9600)

	#set baud rate (on chip)
	@uart4.write("$PMTK251,115200*1F\r\n")

	#set UART baud (here) to 115200
	@uart4.set_speed(115200)

	#gga and rmc only 
	@uart4.write("$PMTK314,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*28\r\n")

	#once every 10s update 
	#@uart4.write("$PMTK220,10000*2F\r\n")
	@uart4.write("$PMTK220,1000*1F\r\n")
	
	$expand = 0.00425

	$latitude = 40.691593
	$longitude = -73.963248
	
	$maxLat = $latitude + $expand
	$minLat = $latitude - $expand
	$maxLon = $longitude + $expand
	$minLon = $longitude - $expand


 def self.updateMapBox 
	$maxLat = $latitude + $expand
	$minLat = $latitude - $expand
	$maxLon = $longitude + $expand
	$minLon = $longitude - $expand

	

 end

 def self.insideMapBox?
	return false unless $latitude.between?($minLat, $maxLat) 
	return false unless $longitude.between?($minLon, $maxLon) 
	true
 end

 def self.drawMap 
	system("/home/debian/Desktop/pipboy/tile.sh #{$longitude} #{$latitude} #{$expand}")
	GPS.updateMapBox
 end

#gga only
#$PMTK314,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29

#output off
#$PMTK314,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*28
 

	@timeSet = false
	
	if Time.now.to_i > 1396681063 #April 4, 2014
		@timeSet = true
	end

	def self.getGPSData
	   return @gpsData
	    	   
	end

	def self.stopGPS 
		@gpsThread.die if @gpsThread
	end
	
	def self.startGPS 
		@gpsThread = Thread.new do
			@uart4.each_line do |line|
				gpsData = line.force_encoding("iso-8859-1").split(",")
				
				case gpsData[0] 

					when "$GPGGA"
						puts gpsData.inspect
						#@time = gpsData[1]
						@lat = gpsData[2]
						@nsLat = gpsData[3]
						@lon = gpsData[4]
						@ewLon = gpsData[5]
						@fixedGPS = gpsData[6]
						#@numSat = gpsData[7]
						#@altitude = gpsData[9]
						#@altUnit = gpsData[10]
						@gpsData = gpsData
						
						if @fixedGPS == "1"
							$latitude = @lat[0..1].to_i + @lat[2..-1].to_f / 60
							$latitude *= -1 if @nsLat == "S"
							$longitude = @lon[0..1].to_i + @lon[2..-1].to_f / 60 
							$longitude *= -1 if @ewLon == "W"
						end




					when "$GPRMC"
						#puts gpsData.inspect
						next if @timeSet
						@time = gpsData[1] #hhmmss.sss
						@date = gpsData[9] #ddmmyy
						
						next unless @time.size > 0
						next unless @date[4..5].to_i.between?(14, 69)
						# MMDDhhmmYY.ss
						@dateString = @date[2..3]+@date[0..1]+@time[0..3]+@date[4..5]+'.'+@time[4..5]
						
						system("date", "-u", @dateString)
						@timeSet = true
				end
				sleep 60 if $mp3Length > 0
			end
			
		end

	end
	
	
	#    puts "Latitude: #{@lat} #{@nsLat}"
	#    puts "Longitude: #{@lon} #{@ewLon}"
	#    puts "GPS Fix: #{@fixedGPS} # of Satellites: #{@numSat}"
	#    puts "Sea Level: #{@altitude} #{@altUnit}"


end

