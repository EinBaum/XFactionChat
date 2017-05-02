

local a_1 = " !\"#$%&'()*+,-./"
local a_2 = "0123456789"
local a_3 = ":;<=>?@"
local a_4 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local a_5 = "[\\]^_`"
local a_6 = "abcdefghijklmnopqrstuvwxyz"
local a_7 = "{|}~"

local chars = a_6 .. a_4 .. a_1 .. a_2 .. a_3 .. a_5 .. a_7
local signature = "^~"

-- Dictionary credits: http://members.ii.net/~nichevo/phrase/

local dict_common = {
	[1] = {"d", "y"},
	[2] = {"b", "e"},
	[3] = {"c", "o"},
	[4] = {"pp", "an"},
	[5] = {"dd", "ko"},
	[6] = {"ee", "lo"},
	[7] = {"hh", "lu"},
	[8] = {"ss", "me"},
	[9] = {"zz", "ne"},
	[10] = {"aa", "re"},
	[11] = {"ll", "ru"},
	[12] = {"bb", "se"},
	[13] = {"jj", "ti"},
	[14] = {"cc", "va"},
	[15] = {"oo", "ve"},
	[16] = {"nap", "ash"},
	[17] = {"mom", "bor"},
	[18] = {"oil", "bur"},
	[19] = {"mod", "far"},
	[20] = {"oak", "gol"},
	[21] = {"nag", "hir"},
	[22] = {"mum", "lon"},
	[23] = {"new", "mod"},
	[24] = {"nib", "nud"},
	[25] = {"nee", "ras"},
	[26] = {"nil", "ver"},
	[27] = {"ode", "vil"},
	[28] = {"nix", "wos"},
}

local dict_orcish = {
	[1] = {"f", "a"},
	[2] = {"a", "g"},
	[3] = {"d", "l"},
	[4] = {"j", "n"},
	[5] = {"c", "o"},
	[6] = {"aa", "ag"},
	[7] = {"cc", "gi"},
	[8] = {"ee", "ha"},
	[9] = {"hh", "il"},
	[10] = {"ff", "ka"},
	[11] = {"bb", "ko"},
	[12] = {"dd", "mu"},
	[13] = {"oo", "no"},
	[14] = {"mug", "aaz"},
	[15] = {"mud", "gul"},
	[16] = {"new", "kaz"},
	[17] = {"now", "kek"},
	[18] = {"odd", "kil"},
	[19] = {"nay", "lok"},
	[20] = {"nap", "mog"},
	[21] = {"mop", "nuk"},
	[22] = {"mom", "ogg"},
	[23] = {"oat", "ruk"},
	[24] = {"mod", "tar"},
	[25] = {"nag", "zug"},
	[26] = {"magi", "dogg"},
	[27] = {"luck", "gesh"},
	[28] = {"loss", "grom"},
	[29] = {"lord", "kagg"},
	[30] = {"stew", "maka"},
	[31] = {"luxe", "maza"},
	[32] = {"lose", "nogu"},
	[33] = {"lows", "ogar"},
	[34] = {"lops", "rega"},
	[35] = {"mach", "tago"},
	[36] = {"lugs", "thok"},
	[37] = {"mace", "uruk"},
	[38] = {"lush", "zaga"},
}

--------------------------------------------------------------------------------

local function string_perms(str)
	local perms = {}
	local l = string.len(str)
	local n = math.pow(2, l)
	for i = 0, n - 1 do
		local perm = ""
		for j = 0, l - 1 do
			local is_bit_set = bit.band(bit.rshift(i, j), 1) ~= 0
			local orig_char = string.sub(str, j + 1, j + 1)
			local new_char = is_bit_set and string.upper(orig_char) or orig_char
			perm = perm .. new_char
		end
		perms[i + 1] = perm
	end
	return perms
end

local function table_perms(dict)
	local out = {}
	local i = 1
	for _, entry in dict do
		local input  = entry[1]
		local output = entry[2]
		local input_perms  = string_perms(input)
		local output_perms = string_perms(output)
		for k, _ in input_perms do
			out[i] = {input_perms[k], output_perms[k]}
			i = i + 1
		end
	end
	return out
end

local function assign_letters(letters, perms)
	local trans_to = {}
	local trans_from = {}
	local l = string.len(letters)
	local i = 1
	for _, entry in perms do
		if i > l then break end
		local letter = string.sub(letters, i, i)
		--pp(letter .. " " .. entry[1] .. " " .. entry[2])
		trans_to[letter] = entry[1]
		trans_from[entry[2]] = letter
		i = i + 1
	end
	return trans_to, trans_from
end

local function split(s,t)
	local l = {n=0}
	local f = function (s)
		l.n = l.n + 1
		l[l.n] = s
	end
	local p = "%s*(.-)%s*"..t.."%s*"
	s = string.gsub(s,"^%s+","")
	s = string.gsub(s,"%s+$","")
	s = string.gsub(s,p,f)
	l.n = l.n + 1
	l[l.n] = string.gsub(s,"(%s%s*)$","")
	return l
end

local function out(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 0.85, 0)
end

local function say(msg)
	SendChatMessage(msg, "SAY")
end

local function add_sig(msg, sig)
	return sig .. msg
end

local function remove_sig(msg, sig)
	if string.sub(msg, 1, string.len(sig)) ~= sig then
		return nil
	else
		return string.sub(msg, string.len(sig) + 1)
	end
end

local function decrypt(msg, trans_from, sig)
	local out = ""
	local split_msg = split(msg, " ")
	for i = 1, split_msg.n do
		local c = trans_from[split_msg[i]]
		if c then
			out = out .. c
		end
	end

	if out == "" then
		return nil
	end

	out = remove_sig(out, sig)
	return out
end

local function encrypt(msg, trans_to, sig)
	msg = add_sig(msg, sig)
	local out = ""
	local l = string.len(msg)
	for i = 1, l do
		local c = string.sub(msg, i, i)
		local str = trans_to[c]
		if str then
			out = out .. str .. " "
		end
	end
	return out
end

--------------------------------------------------------------------------------

local p_name			= nil
local p_faction			= nil
local p_lang_foreign	= nil

local p_to				= nil
local p_from			= nil

local function init()
	p_name = UnitName("player")
	p_faction = UnitFactionGroup("player")

	local alliance = p_faction == "Alliance"

	p_lang_foreign = alliance and "Orcish" or "Common"

	local perms_common = table_perms(dict_common)
	local perms_orcish = table_perms(dict_orcish)

	local to_horde, from_horde = assign_letters(chars, perms_common)
	local to_alliance, from_alliance = assign_letters(chars, perms_orcish)

	p_to = alliance and to_horde or to_alliance
	p_from = alliance and from_alliance or from_horde
end

local frame = CreateFrame("frame")
frame:RegisterEvent("CHAT_MSG_SAY")
frame:SetScript("OnEvent", function()
	local msg		= arg1
	local author	= arg2
	local lang		= arg3
	if author ~= p_name then
		if lang == p_lang_foreign then
			local dmsg = decrypt(msg, p_from, signature)
			if dmsg then
				out("[" .. author .. "]: " .. dmsg)
			end
		end
	end
end)

SLASH_XF1 = "/x"
SlashCmdList["XF"] = function(msg)
    if msg == "" then
		out("What do you want to say?")
	else
		out("[" .. p_name .. "]: " .. msg)
		say(encrypt(msg, p_to, signature))
	end
end

--------------------------------------------------------------------------------

init()
