repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.GameId ~= 0
function missing(T, F, Fb)
	if type(F) == T then return F end
	return Fb
end
cloneref = missing("function", cloneref, function(...) return ... end)
Services = setmetatable({}, {
	__index = function(Slf, N)
		local Ok, Cch = pcall(function()
			return cloneref(game:GetService(N))
		end)
		if Ok then
			rawset(Slf, N, Cch)
			return Cch
		else
			error("Invalid Service: " .. tostring(N))
		end
	end
})
local CoreGui = Services.CoreGui
local TextService = Services.TextService
local Players = Services.Players
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local RunService = Services.RunService
local Plr = Players.LocalPlayer
local Lst = {
	{gid = {"1831550657", "10337069275", "3512256796", "10454554751", "6324644175", "10219827882", "10231502419", "10769660375", "10771800287", "10770306793", "10767755325", "10770703729", "10770566869", "10771778398", "10766671102", "6218783244", "10768886153"}, id = "1b1251046fd4407c1d8f7e90cb337aeb", keyless = true}, -- cos, ice tycoon, golem, minor, zenith, unbox, mp, auto, piggy, candy, ch2 clicks, cheese, krn, soccer, chop, zoo, btd, buff
	{gid = {"7359962123"}, id = "f3cdf28dc70b1249611f4d9e92b15c4e", keyless = true}, -- aac
	{gid = {"10529769390", "7613921865","3913007563", "1962399895", "10516888336", "9866884975", "10428418645", "10743048214", "10767913047", "10768934591", "10769361895", "10766473593", "10770256752", "10770228857", "10768532216", "10769787444", "10773259496", "10775182046", "8724785394", "6147671296"}, id = "245e817ec11f0591898dbef698f5a598", keyless = true}, -- gambling, castle, bubble, r, ae, tbb, ba, ttdlllslslsl, td, neb, syb, trench, fts, metro, steal zombie, ch3, superpower, horse, above, psycho, seed, mansion, islands
	{gid = {"9219838330", "6749892429", "7990186056", "7300616172", "10393620082","7585140258", "7738524573", "10604233923", "10414383300", "8875954667", "10768558548", "10771805737", "10770609435", "10772114384", "4778845442", "10771238997", "10770526777", "9089939780", "10768781474"}, id = "d310529bba1c9560607c620cc8664b89", keyless = true}, -- pml, spm, eve, tower, purge, asmr, fish, dumpling, runaways, rtd, ishin, ub, motel, jjk farm, bridge, dragon arena, 100 miles, racetrack, gakusen
	{gid = {"9980077437", "5691634893","10504918958", "10099615394", "6628327758", "10439568447", "10766506199", "10768128625", "10768541373", "10768556372", "10769188452", "10768625767", "10768449395", "10769965862", "10768383600", "7144947546", "10771273649", "10578076062", "10771760061", "10771908014"}, id = "d8e39dd7c8bfa5015a2c48dc361d656f", keyless = true}, -- rng, overdrive, vut, squishy, drill, base, dino, ut, dd, ca, lumber, rp, medved, pte, atr, dtd
	{gid = {"9584946743","9826885587","10475794799", "10405010493", "10539411000", "10529067596", "9906378607", "10772636982", "10765582175", "10282097014", "10768176407", "10769415620", "10493707858", "10769249409", "10771966586", "10769850160", "10701622575", "8172250815"}, id = "74b4e982b9b980d106fc43e8ca53f248", keyless = true}, -- 🧱, ii, pf, sandwich, evo, blocklll, dig, wash, cleanleaf, sr, golf, hole, scooter, icecream, animepack, standout
	{gid = {"7037673488", "10356701370","8191321227", "10376944238", "10690360998", "10769594564", "10741654282","10393438342","10471427008","10769548496", "10599406058", "10768003706", "10772253152", "9867225552", "9293926625", "10774810800", "10771368987"}, id = "3781eb1fc444bef291a013c0e69f7c2a", keyless = true}, -- skeleton, ti, qua,li, stealbase, overture, bad, byb, map, ctf, abr, uma, tiny skies
	{gid = {"10762636904", "9734147105", "8079278639","7934320560","10399136326", "10767408330", "6272727021", "10769802973", "10767808614", "10769020444", "10768197635", "10771680162", "10771327607", "10770730129", "10774386745", "10774051115", "10774639404", "10765482403", "10765718479"}, id = "79c4f538aba5d702cd1b7795737a36d1", keyless = true}, --, cu, ma, s, u, animeg, 5n, aaa, ant, tank, pa, egg, scare, tcs, drive, prison, soccer, sandworm, ballpit, pixelz, break, car
}
local GameCfg
for _, Entry in ipairs(Lst) do
	for _, Id in ipairs(Entry.gid) do
		if Id == tostring(game.GameId) then
			GameCfg = Entry
			break
		end
	end
	if GameCfg then break end
end
if not GameCfg then
	Plr:Kick("This game is not supported.")
	return
end
local Cfg = {
	KeyFile = "yuri/savedkey.txt",
	AAC = "https://ads.luarmor.net/get_key?for=AAC-bLTGMmZfIQlm",
	LinkvertiseURL = "https://ads.luarmor.net/get_key?for=Yuri-ODPllbErcWEJ",
	LootlabsURL = "https://ads.luarmor.net/get_key?for=Lesbian-IpYoiiAdSJVi",
	DiscordURL = "https://discord.gg/6pCsSbVd3E",
	Key = {
		KEY_EXPIRED = { Msg = "Key has expired.", false },
		KEY_BANNED = { Msg = "Key is blacklisted.", false },
		KEY_HWID_LOCKED = { Msg = "Key is locked to a different HWID. Reset your HWID and re-run.", false },
		KEY_INCORRECT = { Msg = "Key is incorrect or was deleted.(you probably done the aac one)", false },
		KEY_INVALID = { Msg = "Key is in an invalid format.", false },
		SCRIPT_ID_INCORRECT = { Msg = "Script ID does not exist or was deleted. Contact support." },
		SCRIPT_ID_INVALID = { Msg = "Script ID is in an invalid format. Contact support." },
		INVALID_EXECUTOR = { Msg = "Executor is not supported." },
		SECURITY_ERROR = { Msg = "Request could not be validated. Try again." },
		TIME_ERROR = { Msg = "Client time is invalid. Check your system clock and try again." },
		UNKNOWN_ERROR = { Msg = "Unknown server error. Try again later or contact support." },
	},
}
local LuarmorApi = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
local Yuri = loadstring(game:HttpGet("https://raw.githubusercontent.com/iLove-yuri/debug/refs/heads/main/homutop.lua"))()
LuarmorApi.script_id = GameCfg.id
if GameCfg.keyless then
	pcall(function()
		LuarmorApi.load_script()
	end)
	return
end
local function KeyStatus(Rslt)
	if type(Rslt) ~= "table" or Rslt.code == nil then
		return "Unexpected response: " .. tostring(Rslt)
	end
	local Info = Cfg.Key[Rslt.code]
	return Info and Info.Msg or tostring(Rslt.message or "Unknown status.")
end
if isfile(Cfg.KeyFile) then
	local SvdKey = readfile(Cfg.KeyFile):gsub("%s", "")
	local Ok, Rslt = pcall(function()
		return LuarmorApi.check_key(SvdKey)
	end)
	if not Ok then
		Plr:Kick("Network error while checking saved key: " .. tostring(Rslt))
		return
	end
	if type(Rslt) == "table" and Rslt.code == "KEY_VALID" then
		script_key = SvdKey
		pcall(function()
			LuarmorApi.load_script()
		end)
		return
	end
	local Info = type(Rslt) == "table" and Cfg.Key[Rslt.code]
	if Info and Info[1] then
		delfile(Cfg.KeyFile)
		Plr:Kick("Saved key rejected: " .. KeyStatus(Rslt))
	else
		Plr:Kick("Key check failed: " .. KeyStatus(Rslt))
	end
	return
end
local function ValidateKey(Key, Ntfy, Sg)
	local ClnKey = Key:gsub("%s", "")
	Ntfy("Validating key...", Color3.fromRGB(220, 220, 220))
	local Ok, Rslt = pcall(function()
		return LuarmorApi.check_key(ClnKey)
	end)
	if not Ok then
		Ntfy("Network error. Check your connection. (" .. tostring(Rslt) .. ")", Color3.fromRGB(255, 60, 60))
		return false
	end
	if type(Rslt) == "table" and Rslt.code == "KEY_VALID" then
		if not isfolder("yuri") then
			makefolder("yuri")
		end
		writefile(Cfg.KeyFile, ClnKey)
		script_key = ClnKey
		Sg:Destroy()
		pcall(function()
			LuarmorApi.load_script()
		end)
		return true
	else
		Ntfy(KeyStatus(Rslt), Color3.fromRGB(255, 60, 60))
		return false
	end
end
Yuri.new({
	TweenService = TweenService,
	UserInputService = UserInputService,
	CoreGui = CoreGui,
	TextService = TextService,
	RunService = RunService,
	config = Cfg,
	scriptKey = script_key,
	onCheckKey = ValidateKey,
})
