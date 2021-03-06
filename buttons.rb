require 'beaglebone'
include Beaglebone
require 'gps.rb'
require 'accelerometer.rb'
require 'geiger.rb'
require 'flashlight.rb'


class PipBoy < Shoes 
 url '/', :index
 url '/gps', :gps 
 url '/data',:data 
 
 #@@OldcustomGreen = rgb(49, 255, 165)
 @@customGreen = rgb(127, 255, 0) 
 @@initialized = false

 @@thisPage = "index"

 $mp3Length = 0 

 def index
    background "background1.png", width: 480, height: 272
    background "screenpixel.png", width: 480, height: 272
    
   # fill @@customGreen..gray(0, 0)
   # strokewidth 0
   # @scanLine = rect 0, 0, 470, 40
   # @scanLine.displace(0, 0)
    
    unless @@initialized 
	   GPS.startGPS
	   button1 = GPIOPin.new(:P8_12, :IN, :PULLUP, :FAST)
	   button2 = GPIOPin.new(:P8_14, :IN, :PULLUP, :FAST)
	   button3 = GPIOPin.new(:P8_16, :IN, :PULLUP, :FAST)
	   button1Light = GPIOPin.new(:P8_11, :OUT)
	   button2Light = GPIOPin.new(:P8_13, :OUT)
	   button3Light = GPIOPin.new(:P8_15, :OUT)
	
	   button1Light.digital_write(:HIGH)

	   callback = lambda { |pin,edge,count|
			#puts pin
			case pin
				when :P8_12
					unless @@thisPage == "index"
						visit "/"
						button1Light.digital_write(:HIGH)
						button2Light.digital_write(:LOW)
						button3Light.digital_write(:LOW)
						@@thisPage = "index"
					end
				when :P8_14
					unless @@thisPage == "gps"
						visit "/gps"
						button1Light.digital_write(:LOW)
						button2Light.digital_write(:HIGH)
						button3Light.digital_write(:LOW)
						@@thisPage = "gps"
					end
				when :P8_16
					unless @@thisPage == "data"
						visit "/data"
						button1Light.digital_write(:LOW)
						button2Light.digital_write(:LOW)
						button3Light.digital_write(:HIGH)
						@@thisPage = "data"
					end
			end
	    }
	
	    button1.run_on_edge(callback, :FALLING)
	    button2.run_on_edge(callback, :FALLING)
   	    button3.run_on_edge(callback, :FALLING)
	@@initialized = true
    end

    stack width: 480 do
        flow(margin: 10) do
			stack width: 150, margin_right: 5 do
				border @@customGreen..gray(0, 0), strokewidth: 1
				stack width: 150 do
					@bg1 = background "background1.png", width: 67, height: 20
					@bg2 = background "screenpixel.png", width: 67, height: 20
					@stats = para " STATS ", stroke: @@customGreen, size: 12, kerning: 2, family: "Monofonto"
					@stats.displace(15, -12)
					@bg1.displace(20, -10)
					@bg2.displace(20, -10)
				end
			end
            stack width: 115, margin_right: 5 do
                border @@customGreen..gray(0, 0), strokewidth: 1
                stack width: 115 do
					flow do
						para "CPU LOAD", stroke: @@customGreen, size: 11, family: "Monofonto"
						@load=para "...", stroke: @@customGreen, size: 11, family: "Monofonto"
						@load.displace(10, 0)
					end
				end
	        end
            stack width: 195 do
                border @@customGreen..gray(0, 0), strokewidth: 1
                stack width: 195 do
					flow do
						para "UPTIME", stroke: @@customGreen, size: 11, family: "Monofonto"
		 				@up=para "...", stroke: @@customGreen, size: 11, family: "Monofonto"
						@up.displace(10, 0)
					end
				end
			end
		end
		flow(margin_left: 10, height: 180) do
			stack width: 160 do
				@text = para "Degrees from North: #{Accelerometer.getCompass}", stroke: @@customGreen, family: "Monofonto"
				@radsText = para "Pulses of Radiation Per Second: #{Geiger.getPulses}", stroke: @@customGreen, family: "Monofonto"
			end
			stack width: 310 do	
				@north = para "N", stroke: @@customGreen, size: 20, family: "Monofonto"
				@north.displace(175, 20)
				nofill
				stroke @@customGreen
				strokewidth 2
				oval(100, 5, 170)
				x = 0
				startx = 185
				starty = 90
				while x < 360 do
					radians = x*Math::PI/180
					
					sinx = Math.sin(radians)
					cosy = Math.cos(radians)
					
					if x%90 == 0
						lineheight = 10
						strokewidth 2
					else
						lineheight = 5
						strokewidth 1
					end

					tickStartx = startx + (75 - lineheight)*sinx
					tickStarty = starty - (75 - lineheight)*cosy
					
					tickEndx = startx + 75*sinx
					tickEndy = starty - 75*cosy
					line(tickStartx, tickStarty, tickEndx, tickEndy)
				x += 15 
				end


				animate(5) do
					@degrees = Accelerometer.getCompass
					
					stroke @@customGreen
					strokewidth 1
					
					radians = @degrees*Math::PI/180
					startx = 355
					starty = 145

					baseRadians = (@degrees + 80)*Math::PI/180
					basex = startx + 10*Math.sin(baseRadians)
					basey = starty - 10*Math.cos(baseRadians)

					baseRadians2 = (@degrees - 80)*Math::PI/180
					base2x = startx + 10*Math.sin(baseRadians2)
					base2y = starty - 10*Math.cos(baseRadians2)

					endx = startx + 80*Math.sin(radians)
					endy = starty - 80*Math.cos(radians)

					blankRadians = (@degrees + 180)*Math::PI/180
					blankx = startx + 80*Math.sin(blankRadians)
					blanky = starty - 80*Math.cos(blankRadians)
					
					fill @@customGreen
					@compassLine.remove if @compassLine
					@compassLine = shape do
						move_to(endx, endy)
						line_to(basex, basey)
						line_to(base2x, base2y)
					end
					nofill
					@compassBlank.remove if @compassBlank
					@compassBlank = shape do
						move_to(basex, basey)
						line_to(blankx, blanky)
						line_to(base2x, base2y)
					end
					@text.replace("Degrees from North: #{@degrees}")
					@radsText.replace("Pulses of Radiation Per Second: #{Geiger.getPulses}")
				end
			end
		end
		@foot = flow(margin_left: 10, margin_right: 10) do 
			border gray(0, 0)..@@customGreen, strokewidth: 1
			stack width: 150, margin_right: 5 do
				stack width: 150 do
					@bg5 = background "background1.png", width: 110, height: 20
					@bg6 = background "screenpixel.png", width: 110, height: 20
					@data = para " Orientation ", stroke: @@customGreen, size: 12, family: "Monofonto"
						@data.displace(15, 17)
					@bg5.displace(20, 15)
					@bg6.displace(20, 15)
				end
			end
		end
		@foot.displace(0, -5)
    end

    every 1 do 
        loadAvg = (File.open("/proc/loadavg").read.split[0].to_f * 100).round.to_s.rjust(3, " ")
        @load.replace(loadAvg)
        uptime = File.open("/proc/uptime").read.split[0].to_f.round
        t = uptime
	mm, ss = t.divmod(60)           
	hh, mm = mm.divmod(60)           
	dd, hh = hh.divmod(24)          

        @up.replace("#{dd.to_s.rjust(2, "0")}d #{hh.to_s.rjust(2, "0")}h #{mm.to_s.rjust(2, "0")}m #{ss.to_s.rjust(2, "0")}s")
    end
   # animate(24) do |frame|
	#@scanLine.move(0, 0+frame%24)
   # end
 end 

 def gps
    background "background1.png", width: 480, height: 272
    background "screenpixel.png", width: 480, height: 272
	stack width: 480 do
        flow(margin: 10) do
            stack width: 150, margin_right: 5 do
                border @@customGreen..gray(0, 0), strokewidth: 1
                stack width: 160 do
					@bg3 = background "background1.png", width: 47, height: 20
					@bg4 = background "screenpixel.png", width: 47, height: 20
					@gps = para " GPS ", stroke: @@customGreen, size: 12, kerning: 2, family: "Monofonto"
					@gps.displace(15, -12)
					@bg3.displace(20, -10)
					@bg4.displace(20, -10)
				end
            end
            stack width: 150, margin_right: 5 do
                border @@customGreen..gray(0, 0), strokewidth: 1
                stack width: 125 do
					flow do
			       		para "SIGNAL", stroke: @@customGreen, size: 11, family: "Monofonto"
						@sig=para "...", margin_left: 10, stroke: @@customGreen, size: 11, family: "Monofonto"
						@sig.displace(10, 0)
					end
	       		end
            end
            stack width: 160 do
                border @@customGreen..gray(0, 0), strokewidth: 1
                stack width: 145 do
					flow do
					    para "# SATELLITES", stroke: @@customGreen, size: 11, family: "Monofonto"
						@sat=para "...", stroke: @@customGreen, size: 11, family: "Monofonto"
						@sat.displace(10, 0)
					end
			    end
            end
        end
		flow(margin_left: 10, height: 180) do
			stack width: 170 do
				border @@customGreen, strokewidth: 1
				@mapImage = image "map.png", margin_right: 50
				fill white
				@mapDot = oval(85, 85, 8)
			end
			stack width: 230, margin_left: 20 do
				@gpsPrintout = para "Loading...", stroke: @@customGreen, family: "Monofonto"
			end
		end
		every 1 do
			@gpsNow = GPS.getGPSData
				
				if @gpsNow[6] == "0" 
					@gpsPrintout.replace("Searching for Satellite Signal...")
					@sig.replace("...")
					@sat.replace("#{@gpsNow[6]}")
				else
					@gpsPrintout.replace("Signal Locked.\nLatitude: #{$latitude} #{@gpsNow[3]}\nLongitude: #{$longitude} #{@gpsNow[5]}\nAltitude: #{@gpsNow[9]} #{@gpsNow[10]}")
					@sig.replace("Locked")
					@sat.replace("#{@gpsNow[6]}")
					
					unless GPS.insideMapBox? 
						GPS.drawMap
						@mapImage.path = "map.png"
					end
					@dotX = (($latitude - $minLat) * 20000).round
					@dotY = (($longitude - $minLon) * 20000).round
					@mapDot.move(@dotX, @dotY)
				end
		end
		@foot = flow(margin_left: 10, margin_right: 10) do 
			border gray(0, 0)..@@customGreen, strokewidth: 1
			stack width: 150, margin_right: 5 do
				stack width: 150 do
					@bg5 = background "background1.png", width: 57, height: 20
					@bg6 = background "screenpixel.png", width: 57, height: 20
					@data = para " Map ", stroke: @@customGreen, size: 12, kerning: 2, family: "Monofonto"
						@data.displace(15, 17)
					@bg5.displace(20, 15)
					@bg6.displace(20, 15)
				end
			end
		end
		@foot.displace(0, -5)
	end
 end 

 def data 
    background "background1.png", width: 480, height: 272
    background "screenpixel.png", width: 480, height: 272
    currentTime = Time.now
	@mp3Length = 0
	@mp3Started = 0

    stack width: 480 do
        flow(margin: 10) do
            stack width: 290, margin_right: 5 do
                border @@customGreen..gray(0, 0), strokewidth: 1
                stack width: 140 do
			        @bg5 = background "background1.png", width: 57, height: 20
					@bg6 = background "screenpixel.png", width: 57, height: 20
			        @data = para " DATA ", stroke: @@customGreen, size: 12, kerning: 2, family: "Monofonto"
				    @data.displace(15, -12)
					@bg5.displace(20, -10)
					@bg6.displace(20, -10)
			    end
            end
            stack width: 95, margin_right: 5 do
                border @@customGreen..gray(0, 0), strokewidth: 1
                stack width: 95 do
	            	para @date = currentTime.strftime("%m/%d/%Y"), stroke: @@customGreen, size: 11, family: "Monofonto"
	        	end
            end
            stack width: 75 do
                border @@customGreen..gray(0, 0), strokewidth: 1
                stack width: 75 do
	          	  para @time = currentTime.strftime("%I:%M %p"), stroke: @@customGreen, size: 11, family: "Monofonto"
	        	end
            end
        end
		@main = flow(margin_left: 15) do
			stack width: 280, scroll: true, height: 180, margin_right: 5 do	
				stack width: 260 do
					mp3s = Dir.glob("/home/debian/Music/Fallout 3_ The Unofficial Soun/*.mp3")
			
					mp3s.each do |mp3|
						para link(File.basename(mp3, ".mp3"), :click => Proc.new { system("killall mplayer");  pid=spawn("mplayer", "-af", "volume=5", mp3, "-really-quiet"); $mp3Length = IO.popen(['mp3info', '-p', '%S', mp3]).read.to_i; @@mp3Started = Time.now; Process.detach(pid)}, stroke: @@customGreen, underline: "none", margin_right: 50, family: "Monofonto", size: 11)
					end
				end
	    	end
			stack width: 160, margin_left: 5, height: 180 do
				image "radioChartreuse.png", margin_left: 30, margin_top: 20, margin_bottom: 10
				
				@mp3Progress = progress width: 1.0
				every(1) do
					if Time.now - @@mp3Started > $mp3Length 
						$mp3Length = 0
					end
					if $mp3Length == 0
						@mp3Progress.fraction = 0
					else
						@mp3Progress.fraction = (Time.now - @@mp3Started)/$mp3Length
					end
				end

				para link("Stop", :click=> Proc.new { system("killall mplayer"); $mp3Length = 0}, stroke: @@customGreen, underline: "none", border: @@customGreen, strokewidth: 1, family: "Monofonto")
			end
		end
		@main.displace(0, -15)
		@foot = flow(margin_left: 10, margin_right: 10) do 
			border gray(0, 0)..@@customGreen, strokewidth: 1
			stack width: 150, margin_right: 5 do
				stack width: 150 do
					@bg5 = background "background1.png", width: 57, height: 20
					@bg6 = background "screenpixel.png", width: 57, height: 20
					@data = para " MP3s ", stroke: @@customGreen, size: 12, kerning: 2, family: "Monofonto"
					@data.displace(15, 17)
					@bg5.displace(20, 15)
					@bg6.displace(20, 15)
				end
			end
		end
		@foot.displace(0, -5)
		every 60 do 
			currentTime = Time.now
			@date.replace(currentTime.strftime("%m/%d/%Y"))
			@time.replace(currentTime.strftime("%I:%M %p"))
		end
    end
 end 
end 

Shoes.app title: "Pipboy 1500", width: 480, height: 272
