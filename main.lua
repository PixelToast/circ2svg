local f = io.open("test.circ")
local xml = require("xml")
local project = xml.find(xml.load(f:read("*a")), "project")
f:close()

local rotations = {
	east = 0,
	south = 90,
	west = 180,
	north = -90,
}

local function gate_box(bx, by, w, h)
	return function(x, y, p)
		p.facing = p.facing or "east"
		print([[<g transform="translate(]] .. x .. [[ ]] .. y .. [[) rotate(]] .. rotations[p.facing] .. [[ 0 0)">]])
		print([[<rect x="]] .. bx .. [[" y="]] .. by .. [[" width="]] .. w .. [[" height="]] .. h .. [[" stroke-width="3" fill="none" stroke="black"/>]])
		print([[</g>]])
	end
end

local stl = {
	["#Gates"] = {
		["AND Gate"] = function(x, y, p)
			p.facing = p.facing or "east"
			print([[<g transform="translate(]] .. x .. [[ ]] .. y .. [[) rotate(]] .. rotations[p.facing] .. [[ 0 0)">]])
			print([[<path
	       d="m -50.499892,24.999927 c 25.000001,0 50.00000048,0 50.00000048,-25.000000300012 C -0.49989152,-25.000075 -25.499891,-25.000075 -50.499892,-25.000075 c -0.0393,0.26172 0,50.000002 0,50.000002 z"
	       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:3px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1" />]])
			print([[</g>]])
		end,
		["OR Gate"] = function(x, y, p)
			p.facing = p.facing or "east"
			print([[<g transform="translate(]] .. x .. [[ ]] .. y .. [[) rotate(]] .. rotations[p.facing] .. [[ 0 0)">]])
			print([[<path
	       d="M -50.499892,24.999927 C -39,25.362205 -0.49989152,12.362205 -0.49989152,-7.3300012e-5 -0.49989152,-11.738119 -39,-25.637795 -50.499892,-25.000075 c 13.499892,28.3622797 0,50.000002 0,50.000002 z"
	       style="fill:none;fill-rule:evenodd;stroke:#000000;stroke-width:3px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1" />]])
			print([[</g>]])
		end,
	},
}

local libs = {}

local function readattr(node)
	local o = {}
	for i = 1, #node do
		if node[i].xml == "a" then
			o[node[i].name] = node[i].val
		end
	end
	return o
end

for i = 1, #project do
	local c = project[i]
	if c.xml == "lib" then
		local lib = {tools = {}, desc = c.desc}

		libs[c.name] = lib
		for j = 1, #c do
			if c[j].xml == "tool" then
				local tool = {attr=readattr(c[j])}
				lib.tools[c[j].name] = tool
			end
		end
	end
end

local function readvec(s)
	local x, y = s:match("%((%d+),(%d+)%)")
	return tonumber(x), tonumber(y)
end

print([[<svg xmlns="http://www.w3.org/2000/svg" version="1.1">]])

for i = 1, #project do
	local c = project[i]
	if c.xml == "circuit" then
		local intersect = {}

		local function setIntersect(x, y)
			intersect[x] = intersect[x] or {}
			intersect[x][y] = (intersect[x][y] or 0) + 1
		end

		for j = 1, #c do
			local comp = c[j]
			if comp.xml == "wire" then
				local x1, y1 = readvec(comp.from)
				local x2, y2 = readvec(comp.to)

				setIntersect(x1, y1)
				setIntersect(x2, y2)

				print([[<line x1="]] .. x1 .. [[" y1="]] .. y1 .. [[" x2="]] .. x2 .. [[" y2="]] .. y2 .. [[" stroke="darkgreen" stroke-width="3"/>]])
			elseif comp.xml == "comp" then
				local x, y = readvec(comp.loc)
				stl[libs[comp.lib].desc][comp.name](x, y, readattr(comp))
			end
		end

		for k, v in pairs(intersect) do
			for n, l in pairs(v) do
				if l == 2 then
					print([[<circle cx="]] .. k .. [[" cy="]] .. n .. [[" r="1.5" fill="darkgreen"/>]])
				elseif l >= 3 then
					print([[<circle cx="]] .. k .. [[" cy="]] .. n .. [[" r="3.5" fill="darkgreen"/>]])
				end
			end
		end
	end
end

print([[</svg>]])