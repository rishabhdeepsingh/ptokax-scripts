--[[

	This file is part of HiT Hi FiT Hai's PtokaX scripts

	Copyright: © 2014 HiT Hi FiT Hai group
	Licence: GNU General Public Licence v3 https://www.gnu.org/licenses/gpl-3.0.html

--]]

path=Core.GetPtokaXPath().."scripts/"
bot=SetMan.GetString(21)
dofile(path.."files/digest.lua")
nickc = {}
falone = {}
muted = {}
blocked={}
dofile( path.."files/blocks.txt" )
desu =false
san =false
chan =false
inPM=false
local temp={					 -- built in commands ,bypass these commands if typed in mainchat
"ban", "banip", "fullban", "fullbanip", "nickban", "tempban", "tempbanip", "fulltempban", "fulltempbanip", "nicktempban", "unban", 
"permunban", "tempunban", "getbans", "getpermbans", "gettempbans", "clrpermbans", "clrtempbans", "rangeban", "fullrangeban", 
"rangetempban", "fullrangetempban", "rangeunban", "rangepermunban", "rangetempunban", "getrangebans", "getrangepermbans", 
"getrangetempbans", "clrrangepermbans", "clrrangetempbans", "checknickban", "checkipban", "checkrangeban", "getinfo", "op",
"gag", "ungag", "restart", "startscript", "stopscript", "restartscript", "restartscripts", "getscripts", "reloadtxt", "addreguser", "delreguser", 
"topic", "massmsg", "opmassmsg", "myip", "help"
}	
PtokaxCommands={}
for k,v in ipairs(temp) do
	PtokaxCommands[v]=true
end
cmdchars = {	--commands start with these
["!"]=true,
["/"]=true,
["+"]=true
}
tmr = TmrMan.AddTimer(400,"fileread") 

fileread = function()
	local file = io.open("/root/IRCout.txt","r")
	if not file then return end
	local msg = file:read("*a")
	file:close();
	if msg ~= "" then
		local user = {
			sNick = "IRC",
			sIP="127.0.0.1",
			iProfile = 6
			}
		local file=io.open("/root/IRCout.txt","w+")
		file:close()
		digest(user,msg,true)
	end
end
ChatArrival = function(user,data)
	local data = string.gsub(data,"|","") --remove terminating |
	local tempdata = data.." "
	 fchar,cmd= tempdata:match( "%b<> (.)(%S+)%s")
	 local isCmd=false
	 local irc=false
	 --Check beforehand if the message begins with a command character . If it doesnt , its not a command . 
	 --We are avoiding the table lookups and saving computation power at the cost of code repetition
	if  not cmdchars[fchar] then			
		isCmd=false
		digest(user,data,isCmd,irc)
		return true
	end
	if isthere(cmd,PtokaxCommands) then		-- let ptokax handle inbuilt commands
		if cmd == "help" then 				-- hack to have custhelp executed each time help is executed
			data=data:gsub("help","custhelp")
			inPM=false
			isCmd=true
			digest(user,data,isCmd,irc)
		end
		return
	end
	if isthere(cmd,CustomCommands) then  
		isCmd=true
		inPM=false
		digest(user,data,isCmd,irc)
		return true
	end
	--message begins with a command character but the command is not found . Treat it as a normal message
	isCmd=false
	digest(user,data,isCmd,irc)
	return true
	
end

ToArrival = function( user, data)
	local tempdata = string.gsub(data,"|","") --remove terminating |
	local tempdata = tempdata.." "
	 to,from= tempdata:match( "$To:%s(%S+)%sFrom:%s(%S+)%s$%b<>%s.*")
	if  to~= "PtokaX" then
		return
	end
	tempdata=tempdata:match("$.*$(.*)")
	fchar,cmd= tempdata:match( "%b<> (.)(%S+)%s")
	if  not cmdchars[fchar] then	
		return
	end
	if isthere(cmd,CustomCommands) then  
		local isCmd=true
		local irc=false
		inPM=true
		digest(user,tempdata,isCmd,irc)
		return true
	end
	if cmd == "help" then 
		local irc=false
		tempdata=tempdata:gsub("help","custhelp")
		isCmd=true
		inPM=true
		digest(user,tempdata,isCmd,irc)
	end
end
ConnectToMeArrival=function(user,data)
	local uploader=data:match("$ConnectToMe%s(%S+)")
	local nickpair=uploader.."$"..user.sNick
	if blocked[nickpair] then
		local msg = uploader.." has blocked you from downloading from them for the reason: "..blocked[nickpair]
		Core.SendPmToNick(user.sNick,"PtokaX",msg)
		return true
	end
end