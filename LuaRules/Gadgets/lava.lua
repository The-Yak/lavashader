function gadget:GetInfo()
  return {
    name      = "Lava Gadget 2.3",
    desc      = "SMOKING hot",
    author    = "knorke, Beherith, The_Yak, Anarchid, Kloot",
    date      = "Feb 2011, Nov 2013",
    license   = "GNU GPL, v2 or later",
    layer     = -3,
    enabled   = true
  }
end
-----------------
-- local glTexRect = gl.TexRect
-- local glUseShader = gl.UseShader

-- local glCopyToTexture = gl.CopyToTexture
-- local glTexture = gl.Texture


local resolution=10
local edgeExponent = 2.5



if (gadgetHandler:IsSyncedCode()) then
tideRhym = {}
tideIndex = 1
tideContinueFrame = 0
lavaLevel = 00
lavaGrow =0
gameframe=0


function gadget:Initialize()
	 _G.lavaLevel = lavaLevel
	 _G.frame = 0
	 addTideRhym (0, 0, 5*6000)
	-- addTideRhym (150, 0.25, 3)
	-- addTideRhym (-20, 0.25, 5*60)
	-- addTideRhym (150, 0.25, 5)
	-- addTideRhym (-20, 1, 5*60)
	-- addTideRhym (180, 0.5, 60)
	-- addTideRhym (240, 0.2, 10)
end


function addTideRhym (targetLevel, speed, remainTime)
	local newTide = {}
	newTide.targetLevel = targetLevel
	newTide.speed = speed
	newTide.remainTime = remainTime
	table.insert (tideRhym, newTide)
end


function updateLava ()
	if (lavaGrow < 0 and lavaLevel < tideRhym[tideIndex].targetLevel) 
		or (lavaGrow > 0 and lavaLevel > tideRhym[tideIndex].targetLevel) then
		tideContinueFrame = gameframe + tideRhym[tideIndex].remainTime*30
		lavaGrow = 0
		--Spring.Echo ("Next LAVA LEVEL change in " .. (tideContinueFrame-gameframe)/30 .. " seconds")
	end
	
	if (gameframe == tideContinueFrame) then
		tideIndex = tideIndex + 1		
		if (tideIndex > table.getn (tideRhym)) then
			tideIndex = 1
		end
		--Spring.Echo ("tideIndex=" .. tideIndex .. " target=" ..tideRhym[tideIndex].targetLevel )		
		if  (lavaLevel < tideRhym[tideIndex].targetLevel) then 
			lavaGrow = tideRhym[tideIndex].speed
		else
			lavaGrow = -tideRhym[tideIndex].speed
		end
	end
end


function gadget:GameFrame (f)
	--gameframe = f
	
	--Spring.Echo('unsynced gameframe')
	
	_G.lavaLevel = lavaLevel+math.sin(f/30)*2
	_G.frame = f

	if (f%10==0) then
		lavaDeathCheck()
	end

	--if (f%2==0) then
		updateLava ()
		lavaLevel = lavaLevel+lavaGrow
		
		--if (lavaLevel == 160) then lavaGrow=-0.5 end
		--if (lavaLevel == -10) then lavaGrow=0.25 end
	--end
	
	--if (f%10==0) then		
		local x = math.random(1,Game.mapX*512)
		local z = math.random(1,Game.mapY*512)
		local y = Spring.GetGroundHeight(x,z)
		if y  < lavaLevel then
			Spring.SpawnCEG("lavaburst", x, lavaLevel, z)
		end
	--end
	
end

function lavaDeathCheck ()
local all_units = Spring.GetAllUnits ()
	for i in pairs(all_units) do
		x,y,z = Spring.GetUnitBasePosition   (all_units[i])
		if (y ~= nil) then
			if (y and y < lavaLevel) then 
				Spring.AddUnitDamage (all_units[i],500) 
				--Spring.DestroyUnit (all_units[i])
				--Spring.SpawnCEG("tpsmokecloud", x, y, z)
			end
		end
	end
end

local DAMAGE_EXTSOURCE_WATER = -5
     
function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID)
    if (weaponDefID ~= DAMAGE_EXTSOURCE_WATER) then
           -- not water damage, do not modify
           return damage, 1.0
    end
     
    local unitDef = UnitDefs[unitDefID]
    local moveDef = unitDef.moveDef
     
    if (moveDef == nil or moveDef.family ~= "hover") then
          -- not a hovercraft, do not modify
          return damage, 1.0
    end
     
    return 0.0, 1.0
end


else --- UNSYCNED:

local glCreateShader = gl.CreateShader
local lavatex=":la:LuaRules/images/lavacolor3.png"
local heighttex="$heightmap"

local shader
function gadget:Initialize()
	shader=nil
	if (glCreateShader == nil) then
		Spring.Echo("Shaders not found, reverting to non-GLSL lava gadget")
	else
		shader = glCreateShader({

			uniform = {
			  sintime=1,
			  mapsizex=Game.mapX*512/2,
			  mapsizez=Game.mapY*512/2,
			},
			uniformInt = {
				  lavacolor =0,
				  height =1 ,
			},

			vertex = [[
			  // Application to vertex shader
			  varying vec3 normal;
			  varying vec3 eyeVec;
			  varying vec3 color;
			  varying float lavaheight;
			  uniform mat4 camera;
			  uniform mat4 caminv;
			  uniform float time2;
			  uniform float time3;
			  uniform float sintime;
			  uniform float mapsizex;
			  uniform float mapsizez;
			  
			  void main()
			  {
				vec4 P = gl_ModelViewMatrix * gl_Vertex;
				lavaheight=gl_Vertex.y;
					  
				eyeVec = P.xyz;
					  
				normal  = gl_NormalMatrix * gl_Normal;
					  
				color = gl_Color.rgb;
					  
				gl_Position = gl_ProjectionMatrix * P;//+sin(sintime/50)*10;
				gl_TexCoord[0] = gl_MultiTexCoord0;
				gl_TexCoord[1].s = gl_Vertex.x/mapsizex*0.5;
				gl_TexCoord[1].t = gl_Vertex.z/mapsizez*0.5;
			  }
			  
			]],  
		 
			fragment = [[
			  #define M_PI 3.1415926535897932384626433832795
			  varying vec3 normal;
			  varying vec3 eyeVec;
			  varying vec3 color;
			  varying float lavaheight;
				
				uniform float time5;
				uniform float time6;
				uniform float time;
				uniform float sintime;
				uniform float mapsizex;
				uniform float mapsizez;
				uniform sampler2D lavacolor;
				uniform sampler2D height;
				
			  void main()
			  {
				vec2 distortion;
				distortion.x=gl_TexCoord[0].s+sin(gl_TexCoord[0].s*20 +sintime/50)/350;
				distortion.y=gl_TexCoord[0].t+sin(gl_TexCoord[0].t*20 +sintime/73)/400;
				vec4 vlavacolor=texture2D(lavacolor,distortion) + 0.1;
				
				vec2 distortion2;
				distortion2 = (distortion + M_PI * 12) * M_PI / 9;
				vec4 vlavacolor2=texture2D(lavacolor,distortion2) * 2 + 0.1;
				vlavacolor *= vlavacolor2;

				//-------------------------------------------
				//The next 3 lines make the lava glow more at the edges, 
				//it looks up the height from a texture, and if the height is close to lava height, it adds a lot of glow.
				vec4 ground=texture2D(height,gl_TexCoord[1].st);
				
				float heightDiff = max(lavaheight-30-ground,0);
				float multi=clamp(heightDiff/100,0.15,1.0)+0.35;
				
				gl_FragColor.rgb = vlavacolor.rgb/multi;
				//-------------------------------------------
				
				gl_FragColor.rgb = gl_FragColor.rgb + gl_FragColor.rgb * vlavacolor.a*(sin(sintime/15)/4+0.3);
				gl_FragColor.a =1;//sin(sintime/5)/4+0.75;
			  }
			]],
		})
		if (shader == nil) then
			Spring.Echo(gl.GetShaderLog())
			Spring.Echo("LAVA shader compilation failed, falling back to GL Lava. See infolog for details")
		else
			Spring.Echo('Lava shader compiled successfully! Yay!')
		end
	end
end

function gadget:DrawWorldPreUnit()  
    if (SYNCED.lavaLevel) then
		r = 0.8
		DrawWorldTimer=DrawWorldTimer or Spring.GetTimer()		
		
         --gl.Color(1-cm1,1-cm1-cm2,0.5,1)
		
		-- DrawGroundHuggingSquare(1,1,1,1,  -0.0*Game.mapX*512, -0.0*Game.mapY*512,  1*Game.mapX*512, 1*Game.mapY*512 ,SYNCED.lavaLevel) --***map.width bla
		
		DrawGroundHuggingSquare(1,1,1,1,  -4*Game.mapX*512, -4*Game.mapY*512,  5*Game.mapX*512, 5*Game.mapY*512 ,SYNCED.lavaLevel) --***map.width bla
			end
end

function DrawGroundHuggingSquare(red,green,blue,alpha,  x1,z1,x2,z2,   HoverHeight)
	if (shader==nil) then
		--Spring.Echo('no shader, fallback renderer working...')
		gl.PushAttrib(gl.ALL_ATTRIB_BITS)
		gl.DepthTest(true)
		gl.DepthMask(true)	
		gl.Texture(":la:LuaRules/images/lavacolor3.png")-- Texture file	
		gl.BeginEnd(GL.QUADS,DrawGroundHuggingSquareVertices,  x1,z1, x2,z2,  HoverHeight)
		gl.Texture(false)
		gl.DepthMask(false)
		gl.DepthTest(false)	
	else
		--Spring.Echo('USING SHADER...')
		gl.PushAttrib(gl.ALL_ATTRIB_BITS)
		us=gl.UseShader(shader)
		
		f=Spring.GetGameFrame()
		gfloc=gl.GetUniformLocation(shader,"sintime")
		gl.Uniform(gfloc, f)

		--lcloaded=gl.Texture(gl.GetUniformLocation(shader,"lavacolor"),lavatex)-- Texture file			
		gl.Texture(0,lavatex)-- Texture file			
		gl.Texture(1,heighttex)-- Texture file					
		--gl.UniformInt(gl.GetUniformLocation(shader,"lavacolor"), 0)		
		-- if (f%100==0) then
			-- Spring.Echo('sintimeLoc='..to_string(gfloc),'shaderid', shader)
			-- uniforms=gl.GetActiveUniforms(shader)
			-- Spring.Echo("Uniforms"..to_string(uniforms))
			-- Spring.Echo("LC "..to_string(lcloaded)..' at '..to_string(gl.GetUniformLocation(shader,"lavacolor"))..' with '..lavatex)
			
		-- end

		gl.DepthTest(true)
		gl.DepthMask(true)			
		--Spring.Echo(to_string(x1)..' '..to_string(z1)..' '..to_string(x2)..' '..to_string(z2)..' '..to_string(HoverHeight)..' ')
		gl.BeginEnd(GL.QUADS,DrawGroundHuggingSquareVertices,  x1,z1, x2,z2,  HoverHeight)
		--gl.DepthTest(false)
		--gl.DepthMask(false)					
		gl.UseShader(0)
	end
	gl.PopAttrib()
end


function DrawGroundHuggingSquareVertices(x1,z1, x2,z2,   HoverHeight)
	-- if (rez==nil) then
		-- rez=1
	-- end
		rez=4
  local y=HoverHeight--+Spring.GetGroundHeight(x,z)  
  local s = 8
  --+math.sin (SYNCED.frame/50)/10
	xstep=(x2-x1)/rez
	zstep=(z2-z1)/rez
	for w=x1, x2-1, xstep do
		for h=z1, z2-1, zstep do
		gl.TexCoord(-s,-s)
		gl.Vertex(h,y,w)

		gl.TexCoord(-s,s) 
		gl.Vertex(h,y,w+zstep)

		gl.TexCoord(s,s)
		gl.Vertex(h+xstep,y,w+zstep)

		gl.TexCoord(s,-s)
		gl.Vertex(h+xstep,y,w)
		end
	end
end

end--ende unsync

function to_string(data, indent)
    local str = ""

    if(indent == nil) then
        indent = 0
    end

    -- Check the type
    if(type(data) == "string") then
        str = str .. (" "):rep(indent) .. data .. "\n"
    elseif(type(data) == "number") then
        str = str .. (" "):rep(indent) .. data .. "\n"
    elseif(type(data) == "boolean") then
        if(data == true) then
            str = str .. "true"
        else
            str = str .. "false"
        end
    elseif(type(data) == "table") then
        local i, v
        for i, v in pairs(data) do
            -- Check for a table in a table
            if(type(v) == "table") then
                str = str .. (" "):rep(indent) .. i .. ":\n"
                str = str .. to_string(v, indent + 2)
            else
                str = str .. (" "):rep(indent) .. i .. ": " ..
to_string(v, 0)
            end
        end
    elseif (data ==nil) then
		str=str..'nil'
	else
        print_debug(1, "Error: unknown data type: %s", type(data))
		str=str.. "Error: unknown data type:" .. type(data)
		Spring.Echo('X data type')
    end

    return str
end
