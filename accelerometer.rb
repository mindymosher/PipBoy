class Accelerometer
	# Initialize I2C device I2C1
	@i2c = I2CDevice.new(:I2C1)
	
	# Power off accelerometer
	@i2c.write(0x19, [0x20, 0x00].pack("C*"))

	# Put compass into continuous conversation mode
	@i2c.write(0x1e, [0x02, 0x00].pack("C*"))
	
	# Enable temperatuer sensor, 15hz register update
	@i2c.write(0x1e, [0x00, 0b10010000].pack("C*") )
	
	# Delay for the settings to take effect
	sleep(0.1)
	
	def self.getCompass
		# Read axis data.  It is made up of 3 big endian signed shorts starting at register 0x03
		raw = @i2c.read(0x1e, 6, [0x03].pack("C*"))
		
		# Coordinates are big endian signed shorts in x,z,y order
		x,z,y = raw.unpack("s>*")
		
		# Calculate angle of degrees from North
		degrees = (Math::atan2(y, x) * 180) / Math::PI
		degrees += 360 if degrees < 0
		

		return degrees.to_i
	end
	
	def self.getZaxis
		# Read axis data.  It is made up of 3 big endian signed shorts starting at register 0x03
		raw = @i2c.read(0x1e, 6, [0x03].pack("C*"))
		
		# Coordinates are big endian signed shorts in x,z,y order
		x,z,y = raw.unpack("s>*")
	
		return z
	end
	
	def self.getTemp
		# Read 2 byte big endian signed short from temperature register
		raw = @i2c.read(0x1e, 2, [0x31].pack("C*"))
		
		# Temperature is sent big endian, least significant digit last
		temp = raw.unpack("s>").first
		
		# Temperature data is 12 bits, last 4 are unused
		temp = temp >> 4
		
		# Each bit is 8c
		temp /= 8
		
		# Correction factor
		temp += 18
		
		# Convert to f
		temp = (temp * 1.8 + 32).to_i
		
		return temp
	end
	
	# Output data
	#puts "#{Time.now.strftime("%H:%M")}  Temperature: #{getTemp} degrees f        Direction: #{getCompass.to_i}  degrees        Z-value: #{getZaxis}"
#sleep 1
end



