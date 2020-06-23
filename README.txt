Assignement 1: TextRain
Kenneth Barta
barta051
5064961

Selecting random letters:
	To select the "randomness" of letters used in this form of "textrain", a file containing a preselected amount of text (in this case, the text being a quote by Bruce Lee's 
	from the Lost Interview) was loaded into the program. Each letter from the quote is then split up and placed with a string array. When each text "droplet" is created, 
	a integer selected by Java's random class is used to select one of the indices of this string array. The letter located at that index of the string array is then used to
	represent the droplet.
Attempts to "slide" the rain:
	I attemtped to let the rain "slide" off objects if it seemed that the letter fell on an incline. However, this hasn't been fully implemented causing it to work only for very specific slopes.
Letter generation and falling velocity:
	Using the real time clock, a new letter is created every predetermined amount of time and initialized with some base starting velocity. After each real time second though, the velocity 
	is increased by a constant amount to simulate constanct acceleration due to gravity unitl it runs into a dark surface. At which point, the letter will revert back to it's starting velocity
	and have to regain its speed should it fall off the surface again, else it will slowly run down the surface if left on the surface long enough.