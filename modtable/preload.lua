Assets = {
	Asset("ATLAS", "modicon.xml"),
	
	-- Filter
	Asset("ANIM", "anim/hx_trans.zip"), 
	-- Range display
	Asset("ANIM", "anim/firefighter_placement.zip"),
	-- Removing noise
	Asset("SOUNDPACKAGE", "sound/hx_shutup.fev"),
	Asset("SOUND", "sound/hx_slient.fsb"),
	-- Seed map
	Asset("ATLAS", "images/myseeds.xml"),
	-- Pioneer
	Asset("ATLAS", "images/bottom_text_grid.xml"),
	Asset("ATLAS", "images/hx_or.xml"),
	-- Rendering deale setbloomecthandle (resolvefilepath ('shaders/hxshader.ksh')
	Asset("SHADER", "shaders/hxshader.ksh"),

	-- Exclusive texture of painting rolls
	Asset("ATLAS", "images/hx_icons1.xml"),
	Asset("ATLAS", "images/hx_icons2.xml"),
	-- Key display
	Asset("ATLAS", "images/keyup.xml"),
	Asset("ATLAS", "images/keydown.xml"),
	Asset("ATLAS", "images/spaceup.xml"),
	Asset("ATLAS", "images/spacedown.xml"),
}

PrefabFiles = {
	-- Range display
	"hrange",
	"harrow",
	-- Smart wooden sign
	"hminisign",
}