extends Node

var HOST = "127.0.0.1"
var PORT = 6317
var client = StreamPeerTCP.new()
var username = "q"
var password = "q"
var list_characters = Array()

func connect_to_server():
	client.connect_to_host(HOST, PORT)
	var login_request = Dictionary()
	login_request["ident"] = username
	login_request["command"] = "login"
	login_request["args"] = password
	var to_send = JSON.print(login_request).to_utf8()
	client.put_data(to_send)

func _process(delta): # where we check for new data recieved from server.
	if client.get_available_bytes() > 0:
		var _recieved_data = client.get_data(client.get_available_bytes())
		var _recieved_string = _recieved_data[1].get_string_from_utf8()
		#print("Received: " + _recieved_string)
		
		var _parsed = parse_json(_recieved_string)
		var _parsed2 = JSON.parse(_parsed) # not sure why we need to do it twice to get a real Dictionary() but so be it.
		
		var _result = _parsed2.result
		for k in _result.keys():
			if k == "login":
				if _result[k] == "Accepted":
					print("logged in.") # login was successfully accepted.
					# request character list
					var characters_request = Dictionary()
					characters_request["ident"] = username
					characters_request["command"] = "request_character_list"
					characters_request["args"] = "[]"
					var to_send = JSON.print(characters_request).to_utf8()
					client.put_data(to_send)
			if k == "character_list":
				print(typeof(_result[k])) # _result[k] is an json array of characters.
				for character in _result[k]:
					character = parse_json(character) # convert character json string to dictionary.
					print(character["name"] + " found.")
					list_characters.append(character)
				get_tree().change_scene("res://window_character_select.tscn")
		