extends Node2D

const ai_version = "121"
const ai_date = "2021-05-13"
const about = "My version is"+ ai_version+" from " +ai_date+" please check for updates at [url=http://diegoferraribruno.itch.io/angelica]my web page[/url] \nIf you wanna chat a bit say: [b]hello[/b]"
const STATES = ["mini","hide","show","editor"]
var state = "show"
var state_old = "show"
const FILE_NAME = "user://angelica-data.json"
var ai_name = "Angelica"
var ai_color = "#ffbbdd"
var need = ""
onready var good = $DB.good
onready var bad = $DB.bad
onready var needs = $DB.needs
onready var notfeeling = $DB.notfeeling
onready var help = $DB.help
onready var sentences = $DB.sentences
onready var hashtags = $DB.hashtags
onready var greetings = $DB.greetings
onready var links = $DB.links
onready var notes = $DB.notes
onready var ai_prefs = [ai_version, ai_name, ai_color, autohide, autoload, autosave, addonmode, quietstart, rsiblink, autopause,sound,"(0,0)","(0,0)",state_old]
onready var user = ["id", "Me", "sillyword", "#dfbdfbff", hashtags, links, ai_prefs, notes, initialize]
var rsiblink = [[true,true],[3000,600]]
var satisfied = 0
var text = ""
var have_feelings = []
var have_need = []
var inputs = 0
var new_face = load("res://addons/angelica/images/1f646.png")
var sleep = true
var history =["enter text here"]
var cdtimer
var autohide = true
var autoload = false
var autosave = true
var olduser = ["id","Me","password","#dfbdfbff",notes,links]
var buser
var quietstart = false
var addonmode = true
var autopause = true
onready var printparent = "get_parent()"
var initialize = [[true],["about","notes","list links",]]
var sound = true
var last_window_pos
var userbkp = user
#var lastposition = Vector2(user[6][11].x,user[6][11].y)
func inittialize():
	for i in user[8][1]:
		_on_LineEdit_text_entered(i)
		yield(get_tree().create_timer(1.5), "timeout")

func demo():
	get_node("Interface/LineEdit/LineEditFake").visible = true
	auto_save()
	userbkp = user
	autosave = false
	for i in dialogue:
		if i.find("ai_name ") != -1:
			i = i.replace("ai_name ","")
			text_to_say(i)
			screen_shot(true)
			yield(get_tree().create_timer(1.5), "timeout")
		else: 
			get_node("Interface/LineEdit/LineEditFake").append_bbcode(i)
			yield(get_tree().create_timer(1.8), "timeout")
			get_node("Interface/LineEdit/LineEditFake").text = ""
			_on_LineEdit_text_entered(i)
			yield(get_tree().create_timer(1.5), "timeout")
		
	get_node("Interface/LineEdit/LineEditFake").visible = false
	user = userbkp
	autosave = true
	
func preload_saved():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_ARRAY:
			buser = data
			if buser.size() < user.size() or buser[6][0] != ai_version:
				text_to_say("You might have a different version of this app and update may break things. I have set [b]autosave[/b] to [b]false[/b]. Try to [b]load[/b] your old prefs, then [b]list links[/b] and [b]#[/b] to check if everything is ok then save, try 'print user'")
				autosave = false
			else:
				if buser[6][0] == ai_version:
					autoload = buser[6][4]
					if autoload != false:
						load_user_prefs()
				if buser[6][4] == false:
					autosave = false

func load_user_prefs():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_ARRAY:
			user = data
			hashtags = user[4]
			links = user[5]
			ai_name = user[6][1]
			ai_color = user[6][2]
			autohide = user[6][3]
			autoload = user[6][4]
			autosave = user[6][5]
			$Control.addonmode = user[6][6]
			rsiblink = user[6][8]
			autopause = user[6][9]
			$Blink.wait_time = rsiblink[1][1]
			$RSI.wait_time = rsiblink[1][0]
			addonmode = user[6][6]
			sound = user[6][10]
			last_window_pos = user[6][12]
			notes = user[7]
			initialize = user[8]
#			lastposition = user[6][11]
			text_to_say("OH! it is you [b][color="+user[3]+"]"+user[1]+"[/color][/b]?")

		else:
			printerr("No saved data! type 'save' to make a new file. \n Remember to aways save after making changes.")

func save_prefs():
	var file = File.new()
	user[6][0] = ai_version
	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(user))
	file.close()
	print(OS.get_user_data_dir())

func _process(delta):
	if addonmode == false:
		if !OS.is_window_focused() and autohide == true and state != "mini":
			change_state("mini")
#		if OS.is_window_focused() and autohide == true and state == "mini":
#			change_state(state_old)

func _teste():
	text_to_say("maravilha")

func _ready():

#	save_prefs() # it will reset user prefs in case of inconsistences
	preload_saved()
	face_change(new_face)
	$Interface/LineEdit.grab_focus()
	
#	if autohide == true:
#		change_state("hide")
	if OS.get_name() != "HTML5":
		get_node("Interface/Panel/Print").connect("meta_clicked", self, "_on_RichTextLabel_meta_clicked")
#func _ready():
	if $Control.addonmode == true:
		$"../../PlayerExample".visible = true
#		if OS.get_name() != "HTML5":
		OS.set_window_maximized(true)
		OS.set_window_always_on_top(false)
		var some_vector = str2var("Vector2" + user[6][11])
		position = some_vector
		$Control.panel_position()
#		text_to_say(str(user[6][11]))
	else:
		position = Vector2(0,0)
		$"../../PlayerExample".visible = false
		OS.set_window_maximized(false)
		OS.set_window_always_on_top(true)
		last_window_pos = str2var("Vector2" + user[6][12])
		OS.set_window_position(last_window_pos)
		position = Vector2(0,0)
	if quietstart == false:
		text_to_say(str(sentences["welcome"]))
		inittialize()
	userbkp = user

func change_state(state_new):
	if state != "mini": 
		state_old = state
	match state_new:
		"mini":
			get_node("Interface/LineEdit/Linkmini").text = ">"
			get_node("Face").scale = Vector2(0.5,0.5)
			get_node("Interface").visible = false
#			get_node("Interface/Print2").visible = false
#			get_node("Interface/LineEdit").visible = false
			state = "mini"
#			if $Interface/Editor.visible == false:
#				$Interface/LineEdit.grab_focus()
#			else:
#				$Interface/Editor/TextEdit.grab_focus()
			if $Control.addonmode == false:
				OS.set_window_mouse_passthrough($PolygonFace.polygon)
		"hide":
			get_node("Interface").visible = true
			get_node("Interface/LineEdit/Linkmini").text = "<"
			get_node("Face").scale = Vector2(1,1)
			if $Control.addonmode == false:
				if $Interface/Editor.visible == true:
					OS.set_window_mouse_passthrough($Interface/PolygonFull.polygon)
				else:
					OS.set_window_mouse_passthrough($Interface/Polygon2D2.polygon)
			get_node("Interface/Panel").visible = false
			get_node("Interface/Print2").visible = true
			state = "hide"
			$Interface/LineEdit.grab_focus()
		"show":
			get_node("Interface").visible = true
			get_node("Interface/LineEdit/Linkmini").text = "<"
			get_node("Face").scale = Vector2(1,1)
			if $Control.addonmode == false:
				OS.set_window_mouse_passthrough($Interface/PolygonFull.polygon)
			get_node("Interface/Print2").visible = true
			get_node("Interface/Panel").visible = true
			get_node("Interface/Print2").visible = false
			state = "show"
#	if $Control.addonmode == true:
#			OS.set_window_mouse_passthrough([])

func face_change(image):
	get_node("Face").set_texture(image)
#func set_func(setA,setB):
#	var parent = $"../"
#	if parent.has_node(setA):
#		var parentb = get('$"../"'+setA)
#		set(parentb,setB)
##		var myparentvar = get_node(printparent).get(command[2])
#		text_to_say(str(setA))
	
	
func math(text) -> void:
	if text.count("+") or text.count("-") or text.count("*") or text.count("/"):
		text.replace(",",".")
		var text_to_float = "1.0*"+str(text)
		var expression = Expression.new()
		expression.parse(text_to_float)
		var result = expression.execute()
		if result != null:
			text_to_say(str(text," = ",result))
func screen_shot(selfie):
				if selfie == false:
					self.visible = false
				yield(get_tree(), "idle_frame")
				var image = get_viewport().get_texture().get_data()
				image.flip_y()
				image.save_png("user://ssAngelica"+datetime_to_string(OS.get_date())+"-"+datetime_to_string(OS.get_time())+".png")
				text = "File saved to" +str(OS.get_user_data_dir())
				if selfie == false:
					self.visible = true
				text_to_say(text)


func _on_LineEdit_text_entered(new_text)-> void :
	history.push_front(new_text)
	command_n = 0
	var command = new_text.split(" ", true, 4)
	match command[0].to_lower():
				"demo":
					demo()
				"ss":
					screen_shot(false)
				"selfie":
					screen_shot(true)
					yield(get_tree().create_timer(0.2), "timeout")
	if command.size() > 1:
		var ai_name_b = ai_name.to_lower()
		match command[0].to_lower():
				ai_name_b:
					match command[1]:
						"name":
							ai_name = str(command[2])
							ai_prefs[1] = ai_name
							user[6] = ai_prefs
						"color":
							ai_color = str(command[2])
							ai_prefs[2] = ai_color
							user[6] = ai_prefs
							text_to_say("UHU! New colous! \n Did you know that i can use RGB colors like #ffddbb")
						"learn":
							text_to_say("I am not learning new sentences yet.")
				"timer":
					cdtimer = float(command[1])*60
					$AngelicaTimer.wait_time = cdtimer
					$AngelicaTimer.start()
					$AngelicaTimer2.start()
					text_to_say("your timer is set! I will alert you when it is over")
					$TimerMini.start()
				"name":
					if command[1] != null:
						user[1] = command[1]
					else:
						pass
				"color":
					if command[1] != null:
						user[3] = command[1]
			
#				"user":
#					if user[1] == command[1]:
#		future				print(user[1])
#		login 			if command[2] == user[2]:
#						print("sillyword ok")
#				"sillyword":
#					if user[1] == command[1]:
#						if user[2] == command[2]:
#							print("macth sillyword")
#							user[2] = command[3]
#							print("sillyword changed")
				"link":
					var key = str(command[1])
					var z = 0
					for i in links[0]:
						if i == key:
							OS.shell_open(links[1][z])
							text_to_say(str("Opening " +str(command[0] +" at "+str(links[1][z]))))
							$TimerMini.start()
						z += 1
				"tw":
					var openfile = false
					var tw_text = new_text.replace("tw ","")
					if command[1] == "ss":
						tw_text = tw_text.replace("ss ","")
						openfile = true
					if command[1] == "@":
						tw_text = tw_text.replace("@ ","")
						tw_text = tw_text.replace(str(command[2]),"")
						var key = str(command[2])
						print (key)
						var x = 0
						for i in links[0]:
							if i == key:
								tw_text += " "+links[1][x]+" "
								print (tw_text)
								break
							x += 1
					if command[1] == "note":
						tw_text = tw_text.replace("note ","")
						tw_text = tw_text.replace(str(command[2]),"")
						var key = str(command[2])
						print (key)
						var x = 0
						for i in notes[0]:
							if i == key:
								tw_text += " "+notes[1][x]+" "
								print (tw_text)
								break
							x += 1
					var hashtags_text=""
					if tw_text.find("#") != -1:
						tw_text = tw_text.replace("#","")
						var hashtags = user[4]["hashtags"]
						for i in hashtags:
							hashtags_text = hashtags_text +i+" "
					new_text = new_text.replace("tw ", "Tweet this:\n")
					new_text = new_text+ " " + hashtags_text
					tw_text = "https://twitter.com/intent/tweet?hashtags="+hashtags_text+"&text="+tw_text
					tw_text = tw_text.replace(" ","%20")
					tw_text = tw_text.replace("#","%2c")
					tw_text = tw_text.replace("=%2c","=")
					OS.shell_open(tw_text)
					if openfile == true:
						OS.shell_open(OS.get_user_data_dir())
					
				"gg":
					var searchstring = new_text.split(" ", true)
					searchstring.remove(0)
					var search =""
					for i in searchstring:
						search += i+"+"
					OS.shell_open("https://www.google.com/search?q="+search)
				"gd":
					var searchstring = new_text.split(" ", true)
					searchstring.remove(0)
					var search =""
					for i in searchstring:
						search += i+"+"
					OS.shell_open("https://www.google.com/search?q=GDScript+"+search)
				"dg":
					var searchstring = new_text.split(" ", true)
					searchstring.remove(0)
					var search =""
					for i in searchstring:
						search += i+"+"
					OS.shell_open("https://duckduckgo.com/?t=lm&q="+search)

	append_text(str("[color="+user[3]+"][right][b]"+user[1]+":[/b] - "+str(new_text)+"[/right][/color]\n"))
	match command[0]:
				"color":
					text_to_say(str("[color="+str(command[1])+"]"+str(command[1])+" is a great color![/color]"))
				"rsi":
					if command.size() == 1:
						var rsi = rsiblink[0][0] 
						rsiblink[0][0] = !rsi
						if rsiblink[0][0] == false:
							$RSI.stop()
							text_to_say("RSI set to " + str(rsiblink[0][0])+ " to turn it on again type [b]rsi[/b]")
						else:
							$RSI.start()
							text_to_say("RSI set to " + str(rsiblink[1][0]) + ". to turn it off type [b]rsi[/b]")
					elif command.size() == 2:
						var seconds = int(command[1])*60
						rsiblink[1][0] = int(seconds)
						$RSI.wait_time = rsiblink[1][0]
						if rsiblink[0][0] == true:
							$RSI.start()
						text_to_say("RSI timer interval set to "+ str(command[1]) +" minutes")
				"blink":
					if command.size() == 1:
						var blink = rsiblink[0][1] 
						rsiblink[0][1] = !blink
						if rsiblink[0][1] == false:
							$Blink.stop()
							text_to_say("blink timer is off now. Type [b]blink[/b] to turn it on again")
						else:
							$Blink.start()
							text_to_say("Blink timer is set to " + str(rsiblink[1][1]) + " minutes")
					elif command.size() == 2:
						var seconds = int(command[1])*60
						rsiblink[1][1] = int(seconds)
						$Blink.wait_time = int(seconds)
						if rsiblink[0][1] == true:
							$Blink.start()
						text_to_say("Blink timer interval set to "+ str(command[1])+ " minutes.")
	if command.size() == 1 :
			math(command[0])
			match command[0]:
				"sound":
					sound = !sound
					user[6][10] = sound
					if sound == false:
						text_to_say("Sound alerts are Off")
					else:
						text_to_say("Sound alerts are On")
				"reset":
					get_tree().reload_current_scene()
				"init":
					inittialize()
				"folder":
					text_to_say("opening folder: "+str(OS.get_user_data_dir()))
					OS.shell_open(OS.get_user_data_dir())
				"autopause":
					autopause = !autopause
					text_to_say("auto pause is set to "+ str(autopause))
				"pause":
					get_tree().paused = !get_tree().paused
					text_to_say("Game pause is "+ str(get_tree().paused))
					
	if command.size() > 1:
		match command[0].to_lower():
			"edit":
				if command.size() == 2:
					text_to_say("Here is a list of your notes:\n"+ str(user[7][0])+"\n Please type: edit note name")
				else:
					editor(command[1], command[2])
					get_node("Interface/Editor")._on_edit_note()
#				get_node("Interface/Editor/TextEdit").visible = true
#				get_node("Interface/Editor/TextEdit").set_text("")
#				editing = get(command[1])
#				get_node("Interface/Editor/TextEdit").insert_text_at_cursor(str(editing))
			"print":
				if command.size() ==3:
					var parent = $"./../../"
					if parent.has_node(command[1]):
						printparent = "./../../"+command[1]
						var myparentvar = get_node(printparent).get(command[2]) 
						text_to_say(str(myparentvar))
				if command.size() == 2:
					printparent = "./../../Angelica/Angelica"
					var myparentvar = get_node(printparent).get(command[1]) 
					text_to_say(str(myparentvar))
			"set":
#				set_func(command[1],command[2])
				var parent = $"../"
				if parent.has_node(command[1]):
					printparent = "../"+command[1]
					var myparentvar = get_node(printparent).get(command[2])
					set(str(myparentvar), command[3])
					text_to_say(str(myparentvar))
			"calc":
				math(command[1])
			"list":
				match command[1]:
					"init":
						var x = 0
						for i in initialize[1]:
							text += "- "+initialize[1][x]+""
							x += 1
						text_to_say("This are your initialization commands:"+ text+ "\n to remove something: [b]del init[/b] something")
						text =""
					"notes":
						text_to_say("here is a list of your notes:\n"+str(user[7][0]))
						
					"links":
						var x = 0
						for i in links[0]:
							text += "[url="+links[1][x]+"]"+links[0][x]+"[/url] "
							x += 1
						text_to_say(text)
						text =""
					"good": 
						list(good)
						append_text(str("\n"))
						new_face = load("res://addons/angelica/images/1f481.png")
						get_node("Face").set_texture(new_face)
						sleep = false
					"bad":
						new_face = load("res://addons/angelica/images/1f64d.png")
						get_node("Face").set_texture(new_face) 
						list(bad)
						append_text(str("\n"))
						sleep = false
					"feelings":
						new_face = load("res://addons/angelica/images/1f481.png")
						get_node("Face").set_texture(new_face) 
						list(good)
						append_text(str("\n"))
						list(bad)
						append_text(str("\n"))
					"#":
						var hashtags = user[4]["hashtags"]
						for i in hashtags:
							append_text(str(i+" "))
					"needs":
						new_face = load("res://addons/angelica/images/1f481.png")
						get_node("Face").set_texture(new_face) 
						text_to_say(str("This is a list of NEEDS that might be useful to you:"))
						list(needs)
						append_text(str("\n"))
			"app":
				$TimerMini.start()
				match command[1]:
					_:
						var commando = new_text.replace("app ","")
						print(commando)
						OS.execute(str(commando),[], false)
						text_to_say("trying to run %s" % command[1])
			"copy":
				match command[1]:
					"note":
							var key = str(command[2])
							var x = 0
							for i in notes[0]:
								if i == key:
									OS.clipboard = notes[1][x]
									text_to_say("Text copied to clipboard: " + notes[1][x])
									auto_save()
									break
								x += 1
			"del":
				match command[1]:
						"init":
							new_text = new_text.replace("del init ","")
							var init_str = str(new_text)
							var i = initialize[1].find(init_str)
							initialize[1].remove(i)
							user[8] = initialize
							text = "init "+init_str+" removed.'"
							auto_save()
						"#":
							var i = hashtags["hashtags"].find(str(command[1],command[2]))
							hashtags["hashtags"].remove(i)
							text = "Hashtag #"+str(command[2])+" removed."
							auto_save()
						"link":
							var key = str(command[2])
							var x = 0
							for i in links[0]:
								if i == key:
									links[0].remove(x)
									links[1].remove(x)
									text = "link "+i+" removed."
									auto_save()
									break
								x += 1
								
						"note":
							var key = str(command[2])
							var x = 0
							for i in notes[0]:
								if i == key:
									notes[0].remove(x)
									notes[1].remove(x)
									text_to_say("note "+i+" removed.")
									auto_save()
									break
								x += 1
							
	if command.size() > 2:
			match command[0].to_lower():
				"add":
					match command[1]:
						"init":
							var init_str = new_text.replace("add init ","")
							initialize[1].append(init_str)
							user[8] = initialize
							text = "Added Initialize command: "+init_str+" to list."
							auto_save()
							
						"#":
							user[4]["hashtags"].append(str(command[1],command[2]))
							text = "Added hashtag:"+command[1]+command[2] + " to # list."
							auto_save()
						"link":
							if command.size() > 3:
								links[0].append(command[2])
								links[1].append(command[3])
								user[4]["links"] = links
								text = "Added link: "+command[2]+" to "+ command[3] + " to list."
								auto_save()
						"note":
							new_text = new_text.replace("add note ","")
							new_text = new_text.replace(command[2],"")
							user[7][0].append(str(command[2]))
							user[7][1].append(str(new_text))
							text = "Added note [b]"+ command[2] +":[/b] "+ new_text
							auto_save()
	match command[0].to_lower():
			"links":
				_on_LineEdit_text_entered("list links")
				
			"hide":
				change_state("hide")
			"show":
				change_state("show")
			"mini":
				change_state("mini")
			"help":
				if command.size() > 1:
					if str(command[1]) in help:
						text_to_say(str(help[command[1]]))
#						print (help[command[1]].size())
#							text_to_say(str(help[command[2]]))
				else:
					new_face = load("res://addons/angelica/images/1f937.png")
					face_change(new_face)
					for i in help:
						append_text(str("[b]"+i+"[/b]: "+help[i][0]+" \n"))
						yield(get_tree().create_timer(0.5), "timeout")
			"save":
				save_prefs()
				text_to_say(" auto save is set to "+ str(autosave))
			"about":
				text_to_say(str("today is ", datetime_to_string(OS.get_date())+" according to this OS."+" "+about))
#				if command[1] == str(user[2]):
			"load":
				load_user_prefs()
			"autoload":
				autoload = !autoload
				user[6][4] = autoload
				text_to_say("autoload set to "+str(autoload))
			"autosave":
				autosave = !autosave
				user[6][5] = autosave
				text_to_say("autosave set to "+str(autosave))
			"quietstart":
				quietstart = !quietstart
				user[6][5] = autosave
				text_to_say("autosave set to "+str(autosave))
			"addon":
				$Control.addonmode = !$Control.addonmode
				user[6][6] = $Control.addonmode
				text_to_say("Addon mode set to "+str($Control.addonmode)+".\n Please save, close and reopen this app!")
			"desktop":
				$Control.addonmode = false
				user[6][6] = $Control.addonmode
				text_to_say("Desktop mode On.\n Please save, and reopen this app!")
			"user":
				text_to_say(str(user))
			"notes":
						text = ""
						var x = 0
						for i in notes[0]:
							text += "[b]"+notes[0][x]+"[/b] "+ notes[1][x]+"\n"
							x += 1
						text_to_say("Here are your notes:\n"+ text)
						text =""
			"ai_name":
				pass #user[6][1] = command[1]+" "+command[2]
			"ai_color": 
				pass #user[6][2]
			"autohide":
				autohide = !autohide
				user[6][3] = autohide
				text_to_say(("autohide is "+str(autohide)))
	new_text = " " + new_text.to_lower() + " "
	new_text = new_text.replace(",", " ");
	new_text = new_text.replace(".", " ");
	new_text = new_text.replace("!", " ");
	$Interface/LineEdit.clear()
	inputs += 1
	if new_text == " print help ":
		for i in help:
			append_text(str(i+": "+help[i][0]+"\n"))
	if new_text == " editor ":
		get_node("Interface/Editor")._on_EditorButton_button_up()
		pass
#		"PopupPanel"PopupPanel()
#		get_node("Interface/Editor/TextEdit").text = ""
#		get_node("Interface/Editor/TextEdit").visible = !get_node("Interface/Editor/TextEdit").visible
	if new_text == " bye ":
		new_face = load("res://addons/angelica/images/1f64b.png")
		face_change(new_face)
		if autosave == true:
			save_prefs()
			text_to_say(str("Prefences were save by autosave."))
		text_to_say(str("Bye! If you need me, reload the page or open the app again."))
		$Timer.start()
	if new_text == " clear ":
		get_node("Interface/Print2").set_bbcode("")
		get_node("Interface/Panel/Print").set_bbcode("")
		get_node("Interface/Editor/TextEdit").text = ""
	if new_text == " hashtags " or new_text == " # ":
		var clipboard = ""
		var hashtags = user[4]["hashtags"]
		for i in hashtags:
			clipboard += " "+i
			append_text(str(i+" "))
		OS.clipboard = clipboard
		append_text("\n")
		text_to_say(str("Hashtags copied to clipboard!"))
	if new_text == " time ":
		text_to_say("it's about " + str(datetime_to_string(OS.get_time()))+" according to this OS.")
	if new_text == " date " or new_text == " today ":
		text_to_say(str("today is ", datetime_to_string(OS.get_date()))+" according to this OS.")
	if new_text == " good ":
		_on_LineEdit_text_entered("list good")
	if new_text == " bad ":
		_on_LineEdit_text_entered("list bad")
	if new_text == " sleep ":
		sleep = true
		new_face = load("res://addons/angelica/images/1f486.png")
		get_node("Face").set_texture(new_face)
	if new_text in greetings:
		new_face = load("res://addons/angelica/images/1f64b.png")
		get_node("Face").set_texture(new_face)
		text_to_say(str(greetings[new_text]))
		sleep = false
	if new_text == " new ":
		sleep = false
		get_node("Interface/Panel/Print").set_bbcode("")
		text_to_say(str(sentences["welcome"]))
		new_face = load("res://addons/angelica/images/1f64e.png")
		face_change(new_face)
		text_to_say(str(greetings[" hello "]))
		have_need = []
		have_feelings = []
		inputs = 0
		satisfied = 0
	if new_text == " needs ":
			new_face = load("res://addons/angelica/images/1f481.png")
			get_node("Face").set_texture(new_face) 
			text_to_say(str("This is a list of NEEDS that might be useful to you:"))
			list(needs)
	if !sleep:
		for i in good:
			for x in good[i]:
				x = " "+ x + " "
				if new_text.find(x) != -1:
					have_feelings.append(x)
					new_face = load("res://addons/angelica/images/1f646.png")
					face_change(new_face)
					satisfied += 1
					text_to_say(str("Uhu! You really look "+ i.to_lower()+ "!"))
					if !have_need:
						text_to_say(str("We might feel this way when our needs are satisfied.\n Can you name one of your needs? (if you need a list type: needs)"))
					break
		for i in notfeeling:
			for f in notfeeling[i]:
				f =  " " + f + " "
				if new_text.find(f) != -1:
					new_face = load("res://addons/angelica/images/1f937.png")
					face_change(new_face)
					text_to_say(str("Did you said: ", f.to_lower(), "? this is not a feeling.\n", sentences["notfeeling"]))
					break
		for i in bad:
			for y in bad[i]:
				y = " " + y + " "
				if new_text.find(y) != -1:
					have_feelings.append(y)
					new_face = load("res://addons/angelica/images/1f645.png")
					face_change(new_face)
					satisfied -= 1
					text_to_say(str("Oh! You are ", i.to_lower(), " aren't you?!"))
					text_to_say(str("We might feel this way when our needs are not satisfied.\nCan you identify one of your needs? (for a list of the needs, type: needs)"))
					break
		if have_feelings:
			for i in needs:
				for y in needs[i]:
					y = " " + y + " "
					if new_text.find(y) != -1:
						if satisfied <= 0:
							have_need.append(y)
							new_face = load("res://addons/angelica/images/1f646.png")
							get_node("Face").set_texture(new_face)
							text_to_say(str(i.to_lower(), ", hum?! I miss it too."))
							break
						if satisfied > 0:
							have_need.append(y)
							new_face = load("res://addons/angelica/images/1f646.png")
							get_node("Face").set_texture(new_face)
							text_to_say(str(i.to_lower(), ", hum?! That is awesome!."))
							break
						if satisfied == 0:
							have_need.append(y)
							text_to_say(str("I am sorry that I can't say: 'i know how does it feel'... \nI hope that you can find someone real to share your feelings and needs."))
							break
		text = ""
		if inputs == 5 and !have_need and !have_feelings:
			sleep == true
		if sleep == false:
			if inputs == 4 and have_need and have_feelings:
				new_face = load("res://addons/angelica/images/1f937.png")
				face_change(new_face)
				get_node("Face").set_texture(new_face)
				text_to_say(str("If you want to talk to someone, maybe you could tell them that you feel, ", str(have_feelings), "\n because of your need for ", str(have_need), " and than ask them to do (or stop doing) something concrete that would make your life more joyful!"))
			if inputs == 10:
				text_to_say(str("Remember that our freedom of choice lies in the space/time between the input and the response."))
			if inputs == 12:
				text_to_say(str("Ah, just one more thing: help the Open Source Community to improve the world!"))
			if inputs == 13:
				sleep = true
				inputs = 0

func auto_save():
	if autosave == true:
		text += " (auto saved)"
		save_prefs()
	else:
		text += "Autosave is off so, don't forget to [b]save[/b]"
	text_to_say(text)
	text=""

func list(what) -> void:
		for i in what:
			yield(get_tree().create_timer(0.6), "timeout")
			append_text(str(" -[b] ", i, " [/b]"))
			for x in what[i]:
				yield(get_tree().create_timer(0.02), "timeout")
				append_text(str(" - ",x))
	
func text_to_say(text):
	text = str("[color="+ ai_color+"][b]"+ai_name+":[/b][/color] "+text+"\n")
	get_node("Interface/Panel/Print").append_bbcode(text)
#	get_node("Interface/Editor/TextEdit").insert_text_at_cursor(text)
	get_node("Interface/Print2").append_bbcode(text)
	
func append_text(text):
	get_node("Interface/Panel/Print").append_bbcode(text)
#	get_node("Interface/Editor/TextEdit").insert_text_at_cursor(text)
	get_node("Interface/Print2").append_bbcode(text)
	
func _on_Timer_timeout():
		get_tree().quit()
		
func _on_SendButton_button_up():
	var new_text = get_node("Interface/LineEdit").get_text()
	_on_LineEdit_text_entered(new_text)
	
func _on_SendButton2_button_up():
	var sendtext = get_node("Interface/Editor/TextEdit").text
	get_node("Interface/Panel/Print").set_bbcode(sendtext)
#
func add_hashtags():
	var hashtags = user[4]["hashtags"]
	for i in hashtags:
		append_text(str(i+" "))

#func _on_OpenShellWeb_pressed():
#		$AudioStreamPlayer.play()
#	OS.shell_open("https://example.com")
func _on_Print_meta_clicked(meta):
#	$AudioStreamPlayer.play()
	$TimerMini.start()
	OS.shell_open(meta)
	
func datetime_to_string(date):
	if (
		date.has("year")
		and date.has("month")
		and date.has("day")
		and date.has("hour")
		and date.has("minute")
		and date.has("second")
	):
		# Date and time.
		return "{year}-{month}-{day} {hour}:{minute}:{second}".format({
			year = str(date.year).pad_zeros(2),
			month = str(date.month).pad_zeros(2),
			day = str(date.day).pad_zeros(2),
			hour = str(date.hour).pad_zeros(2),
			minute = str(date.minute).pad_zeros(2),
			second = str(date.second).pad_zeros(2),
		})
	elif date.has("year") and date.has("month") and date.has("day"):
		# Date only.
		return "{year}-{month}-{day}".format({
			year = str(date.year).pad_zeros(2),
			month = str(date.month).pad_zeros(2),
			day = str(date.day).pad_zeros(2),
		})
	else:
		# Time only.
		return "{hour}-{minute}-{second}".format({
			hour = str(date.hour).pad_zeros(2),
			minute = str(date.minute).pad_zeros(2),
			second = str(date.second).pad_zeros(2),
		})

func _on_AngelicaTimer_timeout():
	change_state(state_old)
	text_to_say("Atention! Timer Expired")
	new_face = load("res://addons/angelica/images/1f64b.png")
	get_node("Face").set_texture(new_face)
	$Interface/Warning.visible = !$Interface/Warning.visible
	if sound == true:
		$Interface/Warning/Alarm.play()
	change_state(state_old)
	
func _on_AngelicaTimer2_timeout():
	if cdtimer > 0:
		cdtimer -= 1
		var hour: = int(cdtimer/60/60)
		var minutes = cdtimer/60
		minutes = int(fmod(minutes,60))
		var seconds := fmod(cdtimer, 60)
		$Face/TimerClock.text = "%02d:%02d:%02d" % [hour, minutes, seconds]
	else:
		$AngelicaTimer2.stop()
		$Face/TimerClock.text = ""
		
		
		

func _on_Button_button_up():
	if autopause == true:
		get_tree().paused = false
	$Interface/Warning.visible = false
	$TimeOut.stop()
	
func _on_TimerMini_timeout():
	change_state("mini")
	
func _on_Control_gui_input(InputEventMouseButton):
	if addonmode == false:
			match state:
				"mini":
					change_state(state_old)
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		if addonmode == true and state == "mini":
			change_state(state_old)

func _on_Control_mouse_entered():
	pass
	if addonmode == true and autohide == true:
		match state:
			"mini":
				change_state(state_old)
			_:
				change_state("mini")


func _on_LineEdit_focus_entered():
	$Interface/LineEdit.text = history[0]
	pass # Replace with function body.
var command_n = 0
func _on_LineEdit_gui_input(event):
	if Input.is_action_just_released("ui_up"):
		var history_max = history.size()-1
		print (command_n," de", history_max)
#		history.push_front($Interface/LineEdit.text)
		if command_n < history_max:
				if history[command_n] != null:
					$Interface/LineEdit.text = history[command_n]
					command_n+=1

	if Input.is_action_just_released("ui_down") and command_n >= 1:
			command_n-=1
			$Interface/LineEdit.text = history[command_n]


func _on_Blink_timeout():
	change_state(state_old)
	if autopause == true:
		get_tree().paused = true
#	text_to_say("Time to rest your eyes")
	new_face = load("res://addons/angelica/images/1f64b.png")
	get_node("Face").set_texture(new_face)
	$Interface/Warning.visible = !$Interface/Warning.visible
	$Interface/Warning/Label.text = "Take 20 seconds to rest your eyes."
	$Interface/Warning/Alarm.play()
	$TimeOut.wait_time = 20
	$TimeOut.start()
	change_state(state_old)

func _on_RSI_timeout():
	change_state(state_old)
	if autopause == true:
		get_tree().paused = true
#	text_to_say("Time to take a break")
	new_face = load("res://addons/angelica/images/1f64b.png")
	get_node("Face").set_texture(new_face)
	$Interface/Warning.visible = !$Interface/Warning.visible
	$Interface/Warning/Label.text = "Time for 1 min rest \n to deactivate this type [b]rsi[/b]"
	$Interface/Warning/Alarm.play()
	$TimeOut.wait_time = 60
	$TimeOut.start()
	change_state(state_old)

func _on_TimeOut_timeout():
	if autopause == true:
		get_tree().paused = false
		$Interface/Warning.visible = false
		$Interface/Warning/Alarm.play()


func _on_close_button_up():
	get_node("Interface/Editor").visible = false
	if addonmode == false:
		match state:
			"hide":
				OS.set_window_mouse_passthrough($Interface/Polygon2D2.polygon)
			"show":
				OS.set_window_mouse_passthrough($Interface/PolygonFull.polygon)

func _on_MouseOver():
	match state:
		"mini":
			change_state(state_old)
		_:
			change_state("mini")
			

func _on_RichTextLabel_meta_clicked():
	change_state("mini")
	print ("click no link")

func _on_Linkmini_button_up():
#	get_node("Interface/LineEdit").visible = !get_node("Interface/LineEdit").visible
	match state:
		"mini":
			change_state(state_old)
		_:
			change_state("mini")

func _on_LinkHide_button_up():
	match state:
		"hide":
			change_state("show")
			get_node("Interface/LineEdit/LinkHide").text = "Hide"
		"show":
			change_state("hide")
			get_node("Interface/LineEdit/LinkHide").text = "Show"

# crash test area EDITOR

var posA = 7
var posB = 0
var editing = ["note","firstone"]
func editor(what,witch):
	if what == "note":
		editing[0] = "note"
		var x = 0
		for i in notes[0]:
			if i == witch:
				editing[1] = witch
				get_node("Interface/Editor/TextEdit").text = notes[1][x]
				get_node("Interface/Editor/Label").text = str(editing)
#									note[0].remove(x)
#				note[1][x] = array_note[3]
			x += 1
		
func _on_save_button_up():
	var save_note_text = get_node("Interface/Editor/TextEdit").text
	if editing[0] == "note":
		var x = 0
		for i in notes[0]:
			if i == editing[1]:
#				save_note_text.replace("save note ","")
				notes[1][x] = save_note_text
				user[7] = notes
				text = "Saved note [b]"+i+"[/b] : " + save_note_text
				text_to_say(text)
				text =""
				auto_save()
			x += 1
#	get_node(Interface/Editor/TextEdit").visible = true
	get_node("Interface/Editor/TextEdit").set_text("")
	get_node("Interface/Editor/Label").text = "Saved: "+str(editing)
	
	
var dialogue = [
	"timer 3",
	"show",
	"new",
	"Angelica name Angelica121",
	"good morning",
	"Angelica121 color Blueviolet",
	"hello",
	"happy",
	"community",
	"Angelica121 name Angelica",
	"name UserName",
	"very wise...",
	"name Diego",
	"by the way!",
	"color #dfb000",
	"someone could make you a brain... I  might have that example downloaded!",
	"date",
	"You are growing fast Angelica! Now you have a demo command",
	"2*5",
	"time",
	"i talk to myself sometimes. I feel safe talking to you",
	"ai_name selfie",
	"What? what are you doing?????",
	"ai_name nothing, i am doing absolutly nothing!",
	"Oh-no! you are alive!",
	"ai_name no, i am not!",
	"What do you know about me?",
	"print have_feelings",
	"print have_need",
	"What about privacy?",
	"print user",
	"thats all that you know about me?",
	"add note Angelica121 This is a greart example! i could tweet this note with [b]tw note Angelica121[/b] #",
	"edit note Angelica121",
	"editor",
	"add # angelica",
	"tw @ angelica I am testing Angelica Desktop Helper and she just opened my browser to send this tweet #",
	"del # angelica",
	"del note Angelica121",
	"help"
	]


func _on_copy_button_up():
		OS.clipboard = get_node("Interface/Editor/TextEdit").text
		append_text("\n")
		text_to_say(str("Note copied to clipboard!"))
