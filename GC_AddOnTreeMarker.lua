--
-- GlobalCompany - AddOn - Icons
--
-- @Interface: --
-- @Author: LS-Modcompany / kevink98
-- @Date: 15.07.2019
-- @Version: 1.0.0.0
--
-- @Support: LS-Modcompany
--
-- Changelog:
--
--
-- 	v1.0.0.0 (15.07.2019):
-- 		- convert to fs19 (kevink98)
--
-- Notes:
--
--
-- ToDo:
-- 
--
--

GC_AddOnTreeMarker = {}

GC_AddOnTreeMarker.MAX_DISTANCE = 5;
GC_AddOnTreeMarker.MARKER_X = 1;
GC_AddOnTreeMarker.MARKER_PL = 2;
GC_AddOnTreeMarker.MARKER_ST = 3;

function GC_AddOnTreeMarker:initGlobalCompany(customEnvironment, baseDirectory, xmlFile)
	if (g_company == nil) or (GC_AddOnTreeMarker.isInitiated ~= nil) then
		return;
	end

	GC_AddOnTreeMarker.debugIndex = g_company.debug:registerScriptName("GC_AddOnTreeMarker");
	GC_AddOnTreeMarker.modName = customEnvironment;
	GC_AddOnTreeMarker.isInitiated = true;

	g_company.addOnTreeMarker = GC_AddOnTreeMarker;
	g_company.addInit(GC_AddOnTreeMarker, GC_AddOnTreeMarker.init);

end

function GC_AddOnTreeMarker:init()
	self.isServer = g_server ~= nil;
	self.isClient = g_dedicatedServerInfo == nil;
	self.isMultiplayer = g_currentMission.missionDynamicInfo.isMultiplayer;	

	self.supportetTrees = {};
	self.supportetTrees["pine_stage1"] = {"treeFir2", "treeFir3", "treeFir4"};
	self.supportetTrees["pine_stage2"] = {"treeFir2", "treeFir3", "treeFir4"};
	self.supportetTrees["pine_stage3"] = {"treeFir2", "treeFir3", "treeFir4"};
	self.supportetTrees["pine_stage4"] = {"treeFir2", "treeFir3", "treeFir4"};
	self.supportetTrees["pine_stage5"] = {"treeFir2", "treeFir3", "treeFir4"};
	self.supportetTrees["pine_stage6"] = {"treeFir2", "treeFir3", "treeFir4"};
	self.supportetTrees["spruce_stage1"] = {"treeFir5", "treeFir6", "treeFir7"};
	self.supportetTrees["spruce_stage2"] = {"treeFir5", "treeFir6", "treeFir7"};
	self.supportetTrees["spruce_stage3"] = {"treeFir5", "treeFir6", "treeFir7"};
	self.supportetTrees["spruce_stage4"] = {"treeFir5", "treeFir6", "treeFir7"};
	self.supportetTrees["spruce_stage5"] = {"treeFir5", "treeFir6", "treeFir7"};

end

function GC_AddOnTreeMarker:findNextTree(p_x, p_y, p_z)
	local tree = nil;
	local distance = 1000000000;
	
	if self.trees == nil then
		self.trees = {};
		self:search(getRootNode());
	end;

	for _, t in pairs(self.trees) do
		if entityExists(t) then
			local x,y,z = getWorldTranslation(t);
			local d = MathUtil.vector3LengthSq(x - p_x, 0, z - p_z);
			if d < distance then
				distance = d;
				tree = t;
			end;		
		end;		
    end
	
	--[[
	for _, t in pairs(g_currentMission.plantedTrees.growingTrees) do
		local d = Utils.vector3LengthSq(t.x - p_x, 0, t.z - p_z);
		
		if d < distance and not TreePlantUtil[t.treeType] == createdTreeTypes[t.treeType] then
			distance = d;
			tree = t.node;
		elseif string.format("%.2f",d) == string.format("%.2f",distance) then
			self.printE = true;
			return nil;
		end;
	end
	]]--
	
	if distance > GC_AddOnTreeMarker.MAX_DISTANCE then	
		return nil;
	end;	
	return tree;
end;

function GC_AddOnTreeMarker:search(id)
	for i=1, getNumOfChildren(id) do
		local c = getChildAt(id, i-1);
		if self.supportetTrees[getName(c)] ~= nil then
			table.insert(self.trees, c);
		else
			self:search(c);
		end;
	end;
end;

function GC_AddOnTreeMarker:markTree(tree, markerType)
	if not self.isServer then
		return;
	end;
	
	local supTrees = self.supportetTrees[getName(tree)];
	local treeType = supTrees[markerType]

	if tree ~= 0 and type(tree) == "number" and supTrees ~= nil and treeType ~= nil then
				
		local x,y,z = getWorldTranslation(tree);
		local rx,ry,rz = getRotation(tree);
		
		local growthStateI = tonumber(string.sub(getName(tree), string.len(getName(tree))))
		local growthState = (growthStateI) / ((table.getn(g_treePlantManager.nameToTreeType["TREEFIR"].treeFilenames)));
		
		g_treePlantManager:plantTree(g_treePlantManager.nameToTreeType[treeType:upper()].index, x, y, z, rx, ry, rz, growthState, growthStateI + 1, true, nil)
		delete(tree);		
		g_treePlantManager:cleanupDeletedTrees()
	end;
end

GC_AddOnTreeMarkerHandTool = {};

local GC_AddOnTreeMarkerHandTool_mt = Class(GC_AddOnTreeMarkerHandTool, HandTool);
InitObjectClass(GC_AddOnTreeMarkerHandTool, "GC_AddOnTreeMarkerHandTool");

function GC_AddOnTreeMarkerHandTool:new(isServer, isClient, customMt)
	local mt = customMt;
	if mt == nil then
		mt = GC_AddOnTreeMarkerHandTool_mt;
	end

	return HandTool:new(isServer, isClient, mt);	
end;

function GC_AddOnTreeMarkerHandTool:load(xmlFilename, player)
    if not GC_AddOnTreeMarkerHandTool:superClass().load(self, xmlFilename, player) then
        return false;
    end
	
	local xmlFile = loadXMLFile("TempXML", xmlFilename)
    if xmlFile == 0 then
        return false
	end
	
	local typ = getXMLString(xmlFile, "handTool.handToolType#type");
	if typ ~= nil then
		if typ == "x" then
			self.type = GC_AddOnTreeMarker.MARKER_X;
		elseif typ == "pl" then
			self.type = GC_AddOnTreeMarker.MARKER_PL;
		elseif typ == "st" then
			self.type = GC_AddOnTreeMarker.MARKER_ST;
		end;
	else
		self.type = GC_AddOnTreeMarker.MARKER_X;
	end;

	local animationNodes = g_company.animationNodes:new(self.isServer, self.isClient)
	if animationNodes:load(self.rootNode, self, xmlFile, "handTool") then
		self.animationNodes = animationNodes;
	end

	self.canMark = false;
	self.soundRunStart = 0;  
	self.soundRunMark = 0;    
	
	self:register(false);

	self.eventId_startMarkTree = g_company.eventManager:registerEvent(self, self.startMarkTree_Event, true);
	self.eventId_startEffects = g_company.eventManager:registerEvent(self, self.startEffects_Event, true);

	if g_company.addOnTreeMarker.isClient then
		self.sounds = {};
		self.sounds.onActivateSound = g_soundManager:loadSampleFromXML(xmlFile, "handTool.sounds", "onActivateSound", self.baseDirectory, self.rootNode, 0, AudioGroup.VEHICLE, nil, nil);
		self.sounds.onMark = g_soundManager:loadSampleFromXML(xmlFile, "handTool.sounds", "onMark", self.baseDirectory, self.rootNode, 0, AudioGroup.VEHICLE, nil, nil);
	end;
	
	delete(xmlFile);
    return true;
end;

function GC_AddOnTreeMarkerHandTool:delete()

	self.animationNodes:delete();
	g_soundManager:deleteSamples(self.sounds)
	self:unregister();
	
    GC_AddOnTreeMarkerHandTool:superClass().delete(self);
end;


function GC_AddOnTreeMarkerHandTool:onActivate(allowInput)
	GC_AddOnTreeMarkerHandTool:superClass().onActivate(self);
	
	g_soundManager:playSample(self.sounds.onActivateSound);
	self.soundRunStart = 3000;   
	self.soundRunMark = 0;

	self.canMark = true;
end;

function GC_AddOnTreeMarkerHandTool:onDeactivate(allowInput)
    GC_AddOnTreeMarkerHandTool:superClass().onDeactivate(self);
	self.canMark = false;
	g_soundManager:stopSample(self.sounds.onActivateSound);
	g_soundManager:stopSample(self.sounds.onMark);
end;


function GC_AddOnTreeMarkerHandTool:update(dt, allowInput)
	if g_company.addOnTreeMarker.isClient then
		if self.soundRunStart > 0 then
			self.soundRunStart = math.max(self.soundRunStart - dt, 0);
			if self.soundRunStart == 0 then
				g_soundManager:stopSample(self.sounds.onActivateSound);
			end;
		end;

		if self.soundRunMark > 0 then
			self.soundRunMark = math.max(self.soundRunMark - dt, 0);
			if self.soundRunMark == 0 then
				g_soundManager:stopSample(self.sounds.onMark);
				self:toggleEffect();
				self.animationNodes:setAnimationNodesState(false);
			end;
		end;
	end;

	if allowInput ~= nil then
		GC_AddOnTreeMarkerHandTool:superClass().update(self, dt, allowInput);
		
		if self.activatePressed and self.canMark and g_company.addOnTreeMarker.isClient then			
			self:startMarkTree(g_currentMission.player.rootNode);			
			self.activatePressed = false;
			--self.canMark = false;
		end;		
	end;	
end;

function GC_AddOnTreeMarkerHandTool:startMarkTree(x,y,z, noEventSend)
	self:startMarkTree_Event({x,y,z}, noEventSend);   
end;

function GC_AddOnTreeMarkerHandTool:startMarkTree_Event(data, noEventSend)
	g_company.eventManager:createEvent(self.eventId_startMarkTree, data, false, noEventSend);
	if self.isServer then
		local nextTree = g_company.addOnTreeMarker:findNextTree(getTranslation(data[1], data[2], data[3]));
		if nextTree ~= nil then
			g_company.addOnTreeMarker:markTree(nextTree, self.type);
			self:startEffects_Event({}, noEventSend);
		end;
	end;
end;

function GC_AddOnTreeMarkerHandTool:startEffects_Event(data, noEventSend)
	g_company.eventManager:createEvent(self.eventId_startEffects, data, false, noEventSend);
	if g_company.addOnTreeMarker.isClient then
		
		g_soundManager:playSample(self.sounds.onMark);
		self.animationNodes:setAnimationNodesState(true);
		self:toggleEffect();
		self.soundRunMark = 3000;
		
	end;
end;

function GC_AddOnTreeMarkerHandTool:toggleEffect()
	if self.animationNodes ~= nil then
		for _,group in pairs(self.animationNodes.standardAnimations) do
			for _,anim in pairs(group.animationNodes) do				
				setVisibility(anim.node, not getVisibility(anim.node));
			end;
		end;
	end;
end

registerHandTool("GC_AddOnTreeMarkerHandTool", GC_AddOnTreeMarkerHandTool);