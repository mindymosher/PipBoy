class BookList < Shoes 
 url '/',      :index 
 url '/twain', :twain 
 url '/kv',    :vonnegut 

 def index 
    background "background1.png", width: 470, height: 280
    background "screenpixel.png", width: 470, height: 280
   para "Books I've read: ", 
     link("by Mark Twain", :click => '/twain'), 
     link("by Kurt Vonnegut", :click => '/kv') 
 end 

 def twain 
    background "screenpixel.png", width: 470, height: 280
   para "Just Huck Finn.\n", 
     link("Go Back", :click => '/') 
 end 

 def vonnegut 

background "background1.png", width: 470, height: 280
   para "Cat's Cradle, Sirens of Titan. Breakfast of Champions.\n", 
     link("Go Back", :click => '/') 
 end 
end 

Shoes.app width: 470, height: 280