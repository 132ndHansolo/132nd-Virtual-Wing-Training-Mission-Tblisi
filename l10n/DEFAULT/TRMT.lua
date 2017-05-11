TRMT = {}

TRMT.DEBUG = function(text)
  env.info('  TRMT:DEBUG: '..text)
end

TRMT.INFO = function(text)
  env.info('   TRMT:INFO: '..text)
end

TRMT.WARN = function(text)
  env.info('TRMT:WARNING: '..text)
end

TRMT.ERROR = function(text)
  env.info('  TRMT:ERROR: '..text)
end

TRMT.SUPPORT_AIRCRAFT = {
  UNITS= {
    { NAME='Tanker Texaco', COUNT=1, TOTAL=0 , DELAY=0 },
    { NAME='Arco',          COUNT=1, TOTAL=0 , DELAY=0 },
    { NAME='Shell',         COUNT=1, TOTAL=0 , DELAY=1800 },
    { NAME='AWACS',         COUNT=1, TOTAL=10, DELAY=0 },
  },
  SCHEDULER_INTERVAL = 120,
  SPAWNERS = {},
}

TRMT.SUPPORT_AIRCRAFT.INITIALIZE = function()

  TRMT.INFO('SUPPORT AIRCRAFTS: INIT: START')  
  for _, unit in ipairs( TRMT.SUPPORT_AIRCRAFT.UNITS ) do
    TRMT.DEBUG('initializing supporting aircraft: making spawner for: '..unit.NAME)
    table.insert( TRMT.SUPPORT_AIRCRAFT.SPAWNERS,
      SPAWN:New( unit.NAME )
           :InitLimit( unit.COUNT, unit.TOTAL )
           :InitRepeatOnEngineShutDown()
           :OnSpawnGroup(
             function( group )                          
               TRMT.DEBUG('(re)Spawning '..group.GroupName)
             end
           )
           :SpawnScheduled( TRMT.SUPPORT_AIRCRAFT.SCHEDULER_INTERVAL, unit.DELAY ) 
    )    
  end
  TRMT.INFO('SUPPORT AIRCRAFTS: INIT: DONE')
end

TRMT.RANGES = {
  MENU = {
    ROOT = MENU_COALITION:New( coalition.side.BLUE, 'Range Options'),
  },
  RESPAWN_UNITS = {
    { NAME='S_Shilka', MAX_UNIT=2 },
    { NAME='S_T55',    MAX_UNIT=5 },
    { NAME='S_Sa13',   MAX_UNIT=1 },
    { NAME='S_BMP',    MAX_UNIT=4 },
    { NAME='S_Sa19',   MAX_UNIT=1 },
  },
  ON_DEMAND_UNITS = {
    { SPAWNER=SPAWN:New( '__ON_DEMAND_B_INFANTRY_SQUAD' ), MENU_TEXT='Spawn infantry squad' },
    { SPAWNER=SPAWN:New( '__ON_DEMAND_B_RECCE_PLATOON' ),  MENU_TEXT='Spawn RECE platoon' },
    { SPAWNER=SPAWN:New( '__ON_DEMAND_B_LAAD_PLATOON' ),   MENU_TEXT='Spawn LAAD platoon' },
    { SPAWNER=SPAWN:New( '__ON_DEMAND_B_ARMD_PLATOON' ),   MENU_TEXT='Spawn armored platoon' },
    { SPAWNER=SPAWN:New( '__ON_DEMAND_B_ARTY_PLATOON' ),   MENU_TEXT='Spawn artillery platoon' },
    { SPAWNER=SPAWN:New( '__ON_DEMAND_B_AAA' ),            MENU_TEXT='Spawn ZSU-23-4' },
    { SPAWNER=SPAWN:New( '__ON_DEMAND_B_SA13' ),           MENU_TEXT='Spawn SA13' },
  },
  SPAWNERS = {},
  SPAWNER_SCHEDULER_INTERVAL = 20, 
  ON_SPAWN = function( group, range )            
    local dest_zone = range.RESPAWN.DEST[ math.random( #range.RESPAWN.DEST ) ]
    local speed = math.random(30, 120)
                
    TRMT.DEBUG('SPAWNER: '..range.NAME..': (re)Spawning '..group.GroupName..' (destination: '..dest_zone:GetName()..' Speed: '..speed..')')
    
    group:TaskRouteToZone(dest_zone, true, speed)
    local dcs_task = group:TaskHold()
    local controlled_task = group:TaskControlled(dcs_task, { userFlag = range.RESPAWN.RANDOM_MOV_FLAG })
    group:PushTask(controlled_task, 1)
  end, 
  TETRA = {    
    NAME = 'Tetra', MENU = nil, OD_MENU = nil,
    RESPAWN = {
      ZONE = ZONE:New('TETRA_SPAWN'),
      DEST = {ZONE:New('TETRA_SPAWN_DEST_1'), ZONE:New('TETRA_SPAWN_DEST_2'), ZONE:New('TETRA_SPAWN_DEST_3'), ZONE:New('TETRA_SPAWN_DEST_4')},
      RANDOM_MOV_FLAG = 20,
    },    
  },
  TIANETI = {    
    NAME = 'Tianeti', MENU = nil, OD_MENU = nil,
    RESPAWN = {
      ZONE = ZONE:New('TIANETI_SPAWN'),
      DEST = {ZONE:New('TIANETI_SPAWN_DEST_1'), ZONE:New('TIANETI_SPAWN_DEST_2'), ZONE:New('TIANETI_SPAWN_DEST_3'), ZONE:New('TIANETI_SPAWN_DEST_4')},
      RANDOM_MOV_FLAG = 30,
    },
  },
  DUSHETI = {    
    NAME = 'Dusheti', MENU = nil, OD_MENU = nil,
    RESPAWN = {
      ZONE = ZONE:New('DUSHETI_SPAWN'),
      DEST = {ZONE:New('DUSHETI_SPAWN_DEST_1'), ZONE:New('DUSHETI_SPAWN_DEST_2'), ZONE:New('DUSHETI_SPAWN_DEST_3'), ZONE:New('DUSHETI_SPAWN_DEST_4')},
      RANDOM_MOV_FLAG = 40,
    },
  },
  MARNUELI = {    
    NAME = 'Marnueli', MENU = nil, OD_MENU = nil,
    RESPAWN = {
      ZONE = ZONE:New('MARNUELI_SPAWN'),
      DEST = {ZONE:New('MARNUELI_SPAWN_DEST_1'), ZONE:New('MARNUELI_SPAWN_DEST_2'), ZONE:New('MARNUELI_SPAWN_DEST_3'), ZONE:New('MARNUELI_SPAWN_DEST_4')},
      RANDOM_MOV_FLAG = 50,
    },
  },
}


TRMT.RANGES.INITIALIZE = function()
  TRMT.INFO('RANGES: INIT: START')
  for _, range in ipairs( {TRMT.RANGES.TETRA, TRMT.RANGES.DUSHETI, TRMT.RANGES.MARNUELI, TRMT.RANGES.TIANETI} ) do
  
    TRMT.DEBUG('RANGES: INIT: '..range.NAME..': START')
    
    range.MENU    = MENU_COALITION:New( coalition.side.BLUE, range.NAME, TRMT.RANGES.MENU.ROOT)
    range.OD_MENU = MENU_COALITION:New( coalition.side.BLUE, 'Spawn',    range.MENU)
    
    TRMT.DEBUG('RANGES: INIT: '..range.NAME..' - making spawners: START')
    
    for _, group in ipairs( TRMT.RANGES.RESPAWN_UNITS ) do
      TRMT.DEBUG('RANGES: INIT: '..range.NAME..' - making spawners: '..group.NAME)
      table.insert(TRMT.RANGES.SPAWNERS,
        SPAWN:NewWithAlias  ( group.NAME, range.NAME..'_'..group.NAME )
        :InitLimit          ( group.MAX_UNIT, 0 )
        :InitRandomizeZones({range.RESPAWN.ZONE})
        :OnSpawnGroup( TRMT.RANGES.ON_SPAWN, range )
        :SpawnScheduled( TRMT.RANGES.SPAWNER_SCHEDULER_INTERVAL, 0 )
      )
    end
    
    for _, group in ipairs( TRMT.RANGES.ON_DEMAND_UNITS ) do
      MENU_COALITION_COMMAND:New(
        coalition.side.BLUE,
        group.MENU_TEXT,
        range.OD_MENU,
        function()
          TRMT.RANGES.ON_SPAWN( group.SPAWNER:SpawnInZone(range.RESPAWN.ZONE, true), range )
        end
      )
    end
    
    TRMT.DEBUG('RANGES: INIT: '..range.NAME..' - making spawners: DONE')
    
    TRMT.DEBUG('RANGES: INIT: '..range.NAME..' - making menus: START')
    
    -- Add command to randomize movements
    MENU_COALITION_COMMAND:New(
      coalition.side.BLUE,
      'Randomize movement',
      range.MENU,
      function()
        trigger.action.setUserFlag(range.RESPAWN.RANDOM_MOV_FLAG, true)
        MESSAGE:New( 'Targets spreading out at ' .. range.NAME, 7):ToBlue()
      end
    )
    
    TRMT.DEBUG('RANGES: INIT: '..range.NAME..' - making menus: DONE')    
    
    TRMT.DEBUG('RANGES: INIT: '..range.NAME..': DONE')
    
  end
  
  TRMT.INFO('RANGES: INIT: DONE')
  
end

TRMT.ARK_UD = {}

TRMT.ARK_UD.BEACONS = {
  {text='Activate Ark-UD at DUSHETI',    flag=11},
  {text='Activate Ark-UD at TIANETI',    flag=12},
  {text='Activate Ark-UD at TETRA',      flag=13},
  {text='Activate Ark-UD at MARNUELI',   flag=14},
  {text='Activate Ark-UD at MARNUELI',   flag=15},
  {text='Deactivate all Ark-UD Beacons', flag=16},
}

TRMT.ARK_UD.MENU      = {}  
TRMT.ARK_UD.MENU.ROOT = MENU_COALITION:New( coalition.side.BLUE, 'ARK UD beacons')
TRMT.ARK_UD.INITIALIZE = function()

  TRMT.DEBUG('ARK UD: INIT: START')
  for i, cmd in ipairs(TRMT.ARK_UD.BEACONS) do  
    TRMT.DEBUG('ARK UD: make radio menus: adding: '..cmd.text)
    MENU_COALITION_COMMAND:New( coalition.side.BLUE, cmd.text, TRMT.ARK_UD.MENU.ROOT, trigger.action.setUserFlag, cmd.flag, true )
  end
  TRMT.DEBUG('ARK UD: INIT: DONE')
  
end

TRMT.MISSILE_TRAINER = {}

TRMT.MISSILE_TRAINER.INITIALIZE = function()
  TRMT.INFO('MISSILE TRAINER: INIT: START')
  TRMT.MISSILE_TRAINER.MISSILE_TRAINER = MISSILETRAINER:New( 100, '132nd Missile Trainer is active' )
                                                       :InitMessagesOnOff       ( true  )
                                                       :InitAlertsToAll         ( true  ) 
                                                       :InitAlertsHitsOnOff     ( true  )
                                                       :InitAlertsLaunchesOnOff ( true  )
                                                       :InitBearingOnOff        ( true  )
                                                       :InitRangeOnOff          ( true  )
                                                       :InitTrackingOnOff       ( true  )
                                                       :InitTrackingToAll       ( true  )
                                                       :InitMenusOnOff          ( true )
  TRMT.INFO('MISSILE TRAINER: INIT: DONE')
end

--- Smokes
 
TRMT.SMOKE = {
  ZONES = {
    LIST = {
      {
        MENU_TEXT='Smoke on Bomb Circle at MARNUELI',
        MENU_PARENT=TRMT.RANGES.MARNUELI,
        COLOR=SMOKECOLOR.Green,
        ZONE=ZONE:New('MARNUELI ConvCircleWest'),
        COUNT=30,
      },
    },
    SPAWN = function( zone, color, count )
      zone:SmokeZone( color, count )
    end
  },
}

TRMT.SMOKE.INITIALIZE = function()
  TRMT.INFO('SMOKE: INIT: START')
  for _, smoke in ipairs( TRMT.SMOKE.ZONES.LIST ) do
    MENU_COALITION_COMMAND:New( coalition.side.BLUE, smoke.MENU_TEXT, smoke.MENU_PARENT.MENU, TRMT.SMOKE.ZONES.SPAWN, smoke.ZONE, smoke.COLOR, smoke.COUNT )
  end
  TRMT.INFO('SMOKE: INIT: DONE')
end

TRMT.SAR = {
  MENU = MENU_COALITION:New( coalition.side.BLUE, 'Search and Rescue' ),
  HELO_GROUP_NAME = 'SARhelo1',
  DUMMY_HELO_GROUP_NAME = 'SARhelo1dummy',
  TEMPLATE_GROUP_NAME = 'SARtemplate',
  CRASH_PLANE = SPAWN:New('crashplane'),
  MANPAD = nil,
  ZONES = {},
  TEMPLATE = nil,
  CTLD_TEMPLATE = nil,
  VEC2 = nil,
  VEC3 = nil,
  ZONE = nil,
  HELO = nil,
  RESCUE_ZONE = nil,
  SCHED_EXTRACT1 = nil,
  SCHED_EXTRACT2 = nil,
  HOSTILES = {
    INNER1 = nil,
    INNER2 = nil,
    GROUPS = {
      {group_name='SARenemy1', outer=13000, inner=9000, x_offset=150, y_offset=170, scheduler=nil, template=nil, transport=nil},
      {group_name='SARenemy2', outer=12000, inner=7000, x_offset=140, y_offset=140, scheduler=nil, template=nil, transport='SARInfantry'},
      {group_name='SARenemy3', outer=19000, inner=9000, x_offset=200, y_offset=200, scheduler=nil, template=nil, transport=nil},
      {group_name='SARenemy4', outer=17000, inner=7000, x_offset=180, y_offset=180, scheduler=nil, template=nil, transport=nil},
      {group_name='SARenemy5', outer=16000, inner=6000, x_offset=140, y_offset=190, scheduler=nil, template=nil, transport=nil},
    },
  },
}

TRMT.SAR.SPAWN_SMOKE = function()
  TRMT.DEBUG('SAR: spawning smoke')
  trigger.action.smoke(TRMT.SAR.VEC3,SMOKECOLOR.Green)
  MESSAGE:New( 'Green smoke on the deck at downed pilot location', 7):ToBlue()
end

TRMT.SAR.SPAWN_HELO = function()
  TRMT.DEBUG('SAR: RESCUE HELO: start')
  MESSAGE:New( 'Search and Rescue Helicopter starting up from FARP MARNUELI, we are inbound the crashsite', 7):ToBlue()
  
  TRMT.DEBUG('SAR: RESCUE HELO: destroying dummy')
  GROUP:FindByName(TRMT.SAR.DUMMY_HELO_GROUP_NAME):Destroy()
  
  TRMT.DEBUG('SAR: RESCUE HELO: spawning real helo')
  TRMT.SAR.HELO = SPAWN:New(TRMT.SAR.HELO_GROUP_NAME):Spawn()
  TRMT.DEBUG('SAR: RESCUE HELO: setting task')
  TRMT.SAR.HELO:SetTask({id = 'Land', params = {point = TRMT.SAR.VEC2,true,40}}, 1)
  TRMT.DEBUG('SAR: RESCUE HELO: creating rescue zone')
  TRMT.SAR.RESCUE_ZONE = ZONE_RADIUS:New('SARrescue',TRMT.SAR.VEC2,25)
  
  TRMT.DEBUG('SAR: RESCUE HELO: scheduling arrival')
  TRMT.SAR.SCHED_EXTRACT1 = SCHEDULER:New( nil,
    function()
      if TRMT.SAR.HELO:IsCompletelyInZone( TRMT.SAR.RESCUE_ZONE ) then
        TRMT.DEBUG('SAR: RESCUE HELO: rescue helo has arrive at pilot location')
        MESSAGE:New( 'Rescue Helicopter reached landing site, we prepare for extraction, give us cover!', 10):ToBlue()
        TRMT.SAR.SCHED_EXTRACT2:Start()
        TRMT.SAR.SCHED_EXTRACT1:Stop()
      end 
    end,
  {}, 0, 10 )
  
  TRMT.DEBUG('SAR: RESCUE HELO: scheduling departure')
  TRMT.SAR.SCHED_EXTRACT2 = SCHEDULER:New( nil,
    function()
      TRMT.DEBUG('SAR: RESCUE HELO: leaving rescue zone')
      TRMT.SAR.MANPAD:destroy()
      MESSAGE:New( 'Pilot is on Board, enroute back to FARP MARNUELI', 17):ToBlue()
      TRMT.SAR.HELO:SetTask({id = 'Land', params = {point = GROUP:FindByName('FARP MARNUEL Vehicle do not rename'):GetVec2(),false,5}}, 1)
      TRMT.SAR.SCHED_EXTRACT2:Stop() 
    end,
  {}, 60, 20 )
  TRMT.SAR.SCHED_EXTRACT2:Stop()
end

TRMT.SAR.SPAWN_HOSTILES = function()
  TRMT.DEBUG('SAR: HOSTILES: start')
  TRMT.SAR.HOSTILES.INNER1  = ZONE_RADIUS:New('innercircle',  TRMT.SAR.VEC2, 1000)
  TRMT.SAR.HOSTILES.INNER2 = ZONE_RADIUS:New('innercircle2', TRMT.SAR.VEC2, 600)
  
  TRMT.DEBUG('SAR: HOSTILES: spawning groups')
  for i = 1, #TRMT.SAR.HOSTILES.GROUPS do
  
    TRMT.DEBUG('SAR: HOSTILES: GROUP'..i..': spawning')
    local group = TRMT.SAR.HOSTILES.GROUPS[i]
    TRMT.SAR.HOSTILES.GROUPS[i].template = SPAWN
      :New(group.group_name)
      :InitRandomizeUnits( true, group.outer, group.inner )
      :SpawnFromVec3(TRMT.SAR.VEC3)
      :RouteToVec3(TRMT.SAR.VEC3, 15)
      
    if group.transport == nil then
      TRMT.DEBUG('SAR: HOSTILES: GROUP'..i..': making regular scheduler')
      TRMT.SAR.HOSTILES.GROUPS[i].scheduler = SCHEDULER:New( nil,
        function()
          if TRMT.SAR.HOSTILES.GROUPS[i].template:IsCompletelyInZone( TRMT.SAR.HOSTILES.INNER1 ) then
            TRMT.DEBUG('SAR: HOSTILES: GROUP'..i..': group is near pilot location, firing')
            TRMT.SAR.HOSTILES.GROUPS[i].template:SetTask(
              {
                id = 'FireAtPoint',
                params = {
                  x=TRMT.SAR.VEC2.x + group.x_offset,
                  y=TRMT.SAR.VEC2.y + group.y_offset,
                  radius=100,
                  expendQty=100,
                  expendQtyEnabled=false
                }
              }, 1)
            TRMT.SAR.HOSTILES.GROUPS[i].scheduler:Stop()
          end 
        end,
      {}, 0, 15 )
    else
      TRMT.DEBUG('SAR: HOSTILES: GROUP'..i..': making transporter scheduler')
      TRMT.SAR.HOSTILES.GROUPS[i].scheduler = SCHEDULER:New( nil,
        function()  
          if TRMT.SAR.HOSTILES.GROUPS[i].template:IsCompletelyInZone( TRMT.SAR.HOSTILES.INNER2 ) then
            TRMT.DEBUG('SAR: HOSTILES: GROUP'..i..': group is near the pilot')
            
            TRMT.DEBUG('SAR: HOSTILES: GROUP'..i..': stopping transporter')
            TRMT.SAR.HOSTILES.GROUPS[i].template:RouteToVec3(TRMT.SAR.HOSTILES.GROUPS[i].template:GetVec3(), 1)
            
            TRMT.DEBUG('SAR: HOSTILES: GROUP'..i..': spawning infantry')
            local infantry = SPAWN:New(group.transport):SpawnFromVec3(TRMT.SAR.HOSTILES.GROUPS[i].template:GetVec3())
            infantry:SetTask(
              {
                id = 'FireAtPoint',
                params = {
                  x=TRMT.SAR.VEC2.x + group.x_offset,
                  y=TRMT.SAR.VEC2.y + group.y_offset,
                  radius=100,
                  expendQty=100,
                  expendQtyEnabled=false,
                }
              }, 1)
            TRMT.SAR.HOSTILES.GROUPS[i].scheduler:Stop()
          end 
        end,
      {}, 0, 15 )   
    end
  end
end

TRMT.SAR.START = function()
  TRMT.INFO('SAR: starting')
  
  TRMT.DEBUG('SAR: spawning template')
  TRMT.SAR.TEMPLATE = SPAWN:New( TRMT.SAR.TEMPLATE_GROUP_NAME ):InitRandomizeZones( TRMT.SAR.ZONES ):Spawn()
  TRMT.SAR.VEC2 = TRMT.SAR.TEMPLATE:GetVec2()
  TRMT.SAR.VEC3 = TRMT.SAR.TEMPLATE:GetVec3()
  
  TRMT.DEBUG('SAR: spawning crash plane')
  TRMT.SAR.CRASH_PLANE:SpawnFromVec3( TRMT.SAR.VEC3 )
  
  TRMT.DEBUG('SAR: spawning pilot')
  local group_details = ctld.generateTroopTypes(2, {aa=1}, 2)
  TRMT.SAR.MANPAD = ctld.spawnDroppedGroup(TRMT.SAR.VEC3, group_details, false, 0);
  table.insert(ctld.droppedTroopsBLUE, TRMT.SAR.MANPAD:getName())
  TRMT.SAR.CTLD_TEMPLATE = GROUP:Register(group_details)
  
  TRMT.DEBUG('SAR: creating beacon')
  ctld.beaconCount = ctld.beaconCount + 1
  ctld.createRadioBeacon(TRMT.SAR.VEC3, 2, 2, 'CRASHSITE TETRA'..ctld.beaconCount - 1, 120)
  MESSAGE:New('Simulated plane crash at TETRA range. Radio Beacon active at the crashsite (use CTLD Beacons to home in)', 7):ToBlue()
  TRMT.SAR.ZONE = ZONE_RADIUS:New('SARzone', TRMT.SAR.VEC2, 200)
  
  TRMT.INFO('SAR: started')
end

TRMT.SAR.INITIALIZE = function()

  TRMT.INFO('SAR: INIT: START')

  TRMT.DEBUG('SAR: INIT: making SAR zones')
  for i = 1, 10 do
    table.insert( TRMT.SAR.ZONES, ZONE:New( 'SAR'..i ))
  end
  
  MENU_COALITION_COMMAND:New( coalition.side.BLUE, 'Activate Crashsite', TRMT.SAR.MENU, TRMT.SAR.START )
  MENU_COALITION_COMMAND:New( coalition.side.BLUE, 'Dispatch Rescue Helicopter from FARP MARNUELI', TRMT.SAR.MENU, TRMT.SAR.SPAWN_HELO )
  MENU_COALITION_COMMAND:New( coalition.side.BLUE, 'Request Smoke on the Crashsite', TRMT.SAR.MENU, TRMT.SAR.SPAWN_SMOKE )
  MENU_COALITION_COMMAND:New( coalition.side.BLUE, 'Activate Hostile Forces', TRMT.SAR.MENU, TRMT.SAR.SPAWN_HOSTILES )

  TRMT.INFO('SAR: INIT: DONE')  
  
end

--- Start TRMT
do

  local modules_to_load = {
    TRMT.RANGES,
    TRMT.SUPPORT_AIRCRAFT,
    TRMT.ARK_UD,
    TRMT.MISSILE_TRAINER,
    TRMT.SMOKE,
    TRMT.SAR,
  }

  for _, module in ipairs( modules_to_load ) do
    module.INITIALIZE()
  end
end

--- No error during script loading, let the log know
TRMT.INFO('LOADED')