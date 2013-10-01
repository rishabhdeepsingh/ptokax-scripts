unsubbed={}
subbed={}
dofile( path.."files/mcunsubs.txt" )
tabUsers = Core.GetOnlineUsers()

for k,v in ipairs(tabUsers) do
	if not isthere_key(v.sNick,unsubbed) then
		table.insert(subbed,v.sNick)
	end
end

ircout = function (data)
	data = data:gsub( "[\|]", "" )			--	Removing the terminating '|' character only.
	data = data:gsub( "\&\#124\;", "\|" )
	data = data:gsub( "\&\#036\;", "\$" )
	local file= io.open("/root/DCout.txt","a+")
	file:write(data.."\n")
	file:flush()
	file:close()
end

dcmcout = function(data)
	for k,v in ipairs(subbed) do
		Core.SendToNick(v,data)
	end
end

UserConnected= function (tUser)
	if not isthere_key(tUser.sNick,unsubbed) then
		if not isthere_key(tUser.sNick,subbed) then
			table.insert(subbed,tUser.sNick)
		end
	end
end
RegConnected = UserConnected
OpConnected = UserConnected
UserDisConnected= function (tUser)
	key = isthere_key(tUser.sNick,subbed)
	while key do
		table.remove( subbed, key)
		key = isthere_key(user.sNick,subbed)
	end
end
RegDisConnected = UserDisConnected
OpDisConnected = UserDisConnected