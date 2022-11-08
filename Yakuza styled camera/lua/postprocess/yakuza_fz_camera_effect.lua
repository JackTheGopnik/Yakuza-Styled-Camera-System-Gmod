--Credits to FosterZ for the original PS1 Style Camera!
if SERVER then return end

--please dont sue me, it's for a friend project ;w; we gave you credit on the workshop


local UseLockedCameraStyle = true  

local OLD_CM = nil
local CH_SIZE = 254
local CAM_MAX_DIST = 1000
local CAM_AUTO_HEIGHT = false
local CAM_HEIGHT_LIMIT = 0
local LERP_OLD_CAM_TO_NEXT_CAM = false
local LAST_MV_CAM = nil
local last_ang = nil
local ANG_IS_FIXED = false
local ANG_LOCK_PITCH = 45
local FOV = 45
local LAST_UPD_CM = CurTime()
local LAST_UPD_CM2 = CurTime()



CreateClientConVar( "pp_krgn_ykz_cmef_enable",  0,      true, true, "Enable/Disable effect" );
CreateClientConVar( "pp_krgn_ykz_cmef_skip_other_hooks",  0,      true, true, "Enable/Disable effect" );
CreateClientConVar( "pp_krgn_ykz_cmef_uselockedcamerastyle",  1,      true, true, "Effect Settings" );
CreateClientConVar( "pp_krgn_ykz_cmef_chsize",  20,      true, true, "Effect Settings" );
CreateClientConVar( "pp_krgn_ykz_cmef_cam_max_dist",  30,      true, true, "Effect Settings" );
CreateClientConVar( "pp_krgn_ykz_cmef_cam_nlc_dist",  161,      true, true, "Effect Settings" );
CreateClientConVar( "pp_krgn_ykz_cmef_cam_heigh_limit",  5,      true, true, "Effect Settings" );
CreateClientConVar( "pp_krgn_ykz_cmef_cam_auto_heigth",  0,      true, true, "Effect Settings" );
CreateClientConVar( "pp_krgn_ykz_cmef_cam_lerp",  1,      true, true, "Effect Settings" );
CreateClientConVar( "pp_krgn_ykz_cmef_ang_fixed",  1,      true, true, "Effect Settings" );
CreateClientConVar( "pp_krgn_ykz_cmef_ang_pitch",  45,      true, true, "Effect Settings" );
CreateClientConVar( "pp_krgn_ykz_cmef_fov",  50,      true, true, "Effect Settings" );
CreateClientConVar( "pp_krgn_ykz_cmef_ignore_chunks",  0,      true, true, "Enable/Disable effect" );






concommand.Add("pp_krgn_ykz_cmef_reset", function()
    GetConVar("pp_krgn_ykz_cmef_uselockedcamerastyle"):SetBool(true)
    GetConVar("pp_krgn_ykz_cmef_chsize"):SetInt(256)
    GetConVar("pp_krgn_ykz_cmef_cam_max_dist"):SetInt(800)
    GetConVar("pp_krgn_ykz_cmef_cam_nlc_dist"):SetInt(30)
    GetConVar("pp_krgn_ykz_cmef_cam_heigh_limit"):SetInt(128)
    GetConVar("pp_krgn_ykz_cmef_cam_auto_heigth"):SetBool(true)
    GetConVar("pp_krgn_ykz_cmef_cam_lerp"):SetBool(false)
    GetConVar("pp_krgn_ykz_cmef_ang_fixed"):SetBool(false)
    GetConVar("pp_krgn_ykz_cmef_ang_pitch"):SetInt(45)
    GetConVar("pp_krgn_ykz_cmef_fov"):SetInt(50)
    GetConVar("pp_krgn_ykz_cmef_ignore_chunks"):SetBool(false)
end)
concommand.Add("pp_krgn_ykz_cmef_reset2", function()
    GetConVar("pp_krgn_ykz_cmef_uselockedcamerastyle"):SetBool(false)
    GetConVar("pp_krgn_ykz_cmef_chsize"):SetInt(20)
    GetConVar("pp_krgn_ykz_cmef_cam_max_dist"):SetInt(30)
    GetConVar("pp_krgn_ykz_cmef_cam_nlc_dist"):SetInt(161)
    GetConVar("pp_krgn_ykz_cmef_cam_heigh_limit"):SetInt(5)
    GetConVar("pp_krgn_ykz_cmef_cam_auto_heigth"):SetBool(true)
    GetConVar("pp_krgn_ykz_cmef_cam_lerp"):SetBool(true)
    GetConVar("pp_krgn_ykz_cmef_ang_fixed"):SetBool(true)
    GetConVar("pp_krgn_ykz_cmef_ang_pitch"):SetInt(4)
    GetConVar("pp_krgn_ykz_cmef_fov"):SetInt(50)
    GetConVar("pp_krgn_ykz_cmef_ignore_chunks"):SetBool(true)
end)

hook.Add("PostDrawOpaqueRenderables", "Krgn_ykz_Effect_cam_PostDrawOpaqueRenderables", function()
    if GetConVar("pp_krgn_ykz_cmef_enable"):GetBool() == false then return end

    

    
end)

hook.Add("HUDShouldDraw","Krgn_ykz_Effect_cam_HUDShouldDraw",function(name)
    if name == "CHudCrosshair" then 
        return !GetConVar("pp_krgn_ykz_cmef_enable"):GetBool()
    end
end)

hook.Add("ShouldDrawLocalPlayer", "Krgn_ykz_Effect_cam_ShouldDrawLocalPlayer", function(ply)
    if GetConVar("pp_krgn_ykz_cmef_enable"):GetBool() then return true end -- cant return :GetBool() because we need to prevent returning false value from this DISABLED hook
end)

local TB_HOOKS_REPLACED = {}
local TB_WPN_CHS_REPLACED = {}


local LastSkipOtherHooks = nil
local LastHookEnabled = nil

local function SetupHookOvverider(hook_table, hook_name, def_function, cs_function)

end

timer.Create("Krgn_ykz_SkipDifferentCalcViewHooks",0.1,0,function()

    local var = GetConVar("pp_krgn_ykz_cmef_enable"):GetBool() == true
    LastSkipOtherHooks = LastSkipOtherHooks or var
    if var then
        for k,v in pairs(hook.GetTable()["CalcView"]) do
            if k == "Krgn_ykz_Effect_cam_CalcView" then continue end
            if TB_HOOKS_REPLACED[k] == nil then
                TB_HOOKS_REPLACED[k] = v
                hook.Add("CalcView", k, function(ply, pos, angles, fov)
                    if GetConVar("pp_krgn_ykz_cmef_enable"):GetBool() == true then return end
                    v(ply, pos, angles, fov)
                end)
            
            end
        end
    else
        if LastSkipOtherHooks == true then
            for k,v in pairs(TB_HOOKS_REPLACED) do
                hook.Add("CalcView", k, v)
            end
            TB_HOOKS_REPLACED = {}
        end
    end
    LastSkipOtherHooks = var
end )




local LST_EYE_POS = nil

local SKIP_FILTER_WPL = function(ent)
    if ent:IsVehicle() then return true end
end

local SKIP_FILTER = function(ent)
    if ent:IsPlayer() then return false end
    if ent:IsVehicle() then return false end
end

hook.Add("CalcView", "Krgn_ykz_Effect_cam_CalcView", function( ply, pos, angles, fov )


    if GetConVar("pp_krgn_ykz_cmef_enable"):GetBool() == false then return end

    UseLockedCameraStyle = GetConVar("pp_krgn_ykz_cmef_uselockedcamerastyle"):GetBool()  -- Use Locked Style camera
    CH_SIZE = GetConVar("pp_krgn_ykz_cmef_chsize"):GetInt() -- Camera chunks size
    CAM_MAX_DIST = GetConVar("pp_krgn_ykz_cmef_cam_max_dist"):GetInt() -- Max Distance to camera
    CAM_AUTO_HEIGHT = GetConVar("pp_krgn_ykz_cmef_cam_auto_heigth"):GetBool() -- Detect height
    CAM_HEIGHT_LIMIT = GetConVar("pp_krgn_ykz_cmef_cam_heigh_limit"):GetInt() -- Height relative position
    LERP_OLD_CAM_TO_NEXT_CAM = GetConVar("pp_krgn_ykz_cmef_cam_lerp"):GetBool() -- Lerp camera positions
    ANG_IS_FIXED = GetConVar("pp_krgn_ykz_cmef_ang_fixed"):GetBool() -- Freeze Camera Pitch
    ANG_LOCK_PITCH = GetConVar("pp_krgn_ykz_cmef_ang_pitch"):GetInt() -- Camera Pitch
    FOV = GetConVar("pp_krgn_ykz_cmef_fov"):GetInt() -- Camera Fov

    local ignore_chunks = GetConVar("pp_krgn_ykz_cmef_ignore_chunks"):GetBool() && !UseLockedCameraStyle
    
    

    


    LST_EYE_POS = LerpVector(.5, LST_EYE_POS or LocalPlayer():EyePos(), LocalPlayer():EyePos())

    if ply:InVehicle() then
        local lp = ply:GetVehicle():GetPos()+ply:GetVehicle():OBBCenter()
        LST_EYE_POS = LerpVector(.5, LST_EYE_POS or lp, lp)
    end

    last_ang = last_ang or angles
    local upos = LST_EYE_POS
    local NEW_CM = Vector(math.ceil(upos.x/CH_SIZE),math.ceil(upos.y/CH_SIZE),math.ceil(upos.z/CH_SIZE))
    local fw = nil
    if UseLockedCameraStyle then
        fw = last_ang:Forward()*1000
        fw.z = 0
        fw = fw/CH_SIZE
        fw = Vector(math.ceil(fw.x), math.ceil(fw.y), 0)
        NEW_CM = (NEW_CM+fw)*CH_SIZE
    else
        local nangles = angles
        local zc = Angle(2, angles.y, angles.r):Forward()*-GetConVar("pp_krgn_ykz_cmef_cam_nlc_dist"):GetInt()
        NEW_CM = (NEW_CM*CH_SIZE)+zc
    end
    local l_user_eye_pos = LST_EYE_POS
    local check_collision_t2r = util.TraceHull({start = NEW_CM, endpos = l_user_eye_pos, mins = Vector(-10,-10,-10), maxs = Vector(10,10,10), mask=MASK_ALL,  collisiongroup = 0, filter = SKIP_FILTER_WPL})

    

    local dist_cond = ignore_chunks
    if !dist_cond && OLD_CM != nil then
        dist_cond = l_user_eye_pos:Distance(OLD_CM) > CAM_MAX_DIST
    end

    if check_collision_t2r.HitWorld or dist_cond then
        if CurTime() > LAST_UPD_CM or OLD_CM == nil or (dist_cond && !UseLockedCameraStyle) then
            local XCHK_TR = util.TraceHull({ mins = Vector(-10,-10,-10), maxs = Vector(10,10,10), start = l_user_eye_pos, endpos = check_collision_t2r.HitPos, mask=MASK_ALL,  collisiongroup = 0, filter = SKIP_FILTER})

            if UseLockedCameraStyle or (!UseLockedCameraStyle && XCHK_TR.HitWorld) then
                NEW_CM = XCHK_TR.HitPos
                 if util.TraceHull({ mins = Vector(-10,-10,-10), maxs = Vector(10,10,10), start = l_user_eye_pos, endpos = l_user_eye_pos}).HitWorld then
                    NEW_CM = XCHK_TR.HitPos
                end 
            end
            LAST_UPD_CM = CurTime() + 1
            LAST_UPD_CM2 = CurTime() + 1
        else
            NEW_CM = OLD_CM
        end
    end

    if OLD_CM == nil or dist_cond  then
        OLD_CM = NEW_CM 
    else
        local check_collision_tr = util.TraceHull({start = OLD_CM , endpos = l_user_eye_pos, mins = Vector(-10,-10,-10), maxs = Vector(10,10,10), mask=MASK_ALL,  collisiongroup = 0, filter = SKIP_FILTER})

        
        if check_collision_tr.Entity != ply && !check_collision_tr.Entity:IsVehicle() && check_collision_tr.HitWorld then
            OLD_CM = NEW_CM
        end

    end
    local MV_Vec = OLD_CM
    if CAM_AUTO_HEIGHT then
        local dist = math.abs(MV_Vec.z - l_user_eye_pos.z)
        if dist < CAM_HEIGHT_LIMIT then
            local tr = util.TraceHull({start = MV_Vec, endpos = MV_Vec+Vector(0, 0, CAM_HEIGHT_LIMIT-dist), mins = Vector(-10,-10,-10), maxs = Vector(10,10,10), filter = SKIP_FILTER})
            MV_Vec.z = tr.HitPos.z
        else
            local tr = util.TraceHull({start = MV_Vec, endpos = MV_Vec-Vector(0, 0, dist-CAM_HEIGHT_LIMIT), mins = Vector(-10,-10,-10), maxs = Vector(10,10,10), filter = SKIP_FILTER})
            MV_Vec.z = tr.HitPos.z
        end
    end
    if LERP_OLD_CAM_TO_NEXT_CAM && LAST_MV_CAM != nil then
        local CanLerpCam = util.TraceHull({start=LAST_MV_CAM, endpos=MV_Vec, mins = Vector(-10,-10,-10), maxs = Vector(10,10,0), filter = SKIP_FILTER})
        if CanLerpCam.HitWorld then

            if !UseLockedCameraStyle then
                MV_Vec = LerpVector(.1, LAST_MV_CAM, CanLerpCam.HitPos ) 
            end
            LAST_MV_CAM = util.TraceHull({start=l_user_eye_pos, endpos=MV_Vec, mins = Vector(-10,-10,-10), maxs = Vector(10,10,10), filter = SKIP_FILTER}).HitPos


        end
        if UseLockedCameraStyle then
            MV_Vec = LerpVector(.1, LAST_MV_CAM, CanLerpCam.HitPos )
        end

    end
    
    if !UseLockedCameraStyle then
        if LAST_MV_CAM != nil then
            MV_Vec = Vector(
                Lerp(.05, LAST_MV_CAM.x, MV_Vec.x),
                Lerp(.05, LAST_MV_CAM.y, MV_Vec.y),
                Lerp(.05, LAST_MV_CAM.z, MV_Vec.z)
            )
        end
    end
    LAST_MV_CAM = MV_Vec 
    local view = {
        origin = MV_Vec,
        angles = (pos-MV_Vec):GetNormalized():Angle(),
        fov = FOV,
        drawviewer = true
    }
    if ANG_IS_FIXED then
        view.angles.p = ANG_LOCK_PITCH
    end
    if CurTime() > LAST_UPD_CM2 then
        last_ang = view.angles
        LAST_UPD_CM2 = CurTime() + 1
    end
    return view
end)



list.Set( "PostProcess", "Yakuza Styled Camera", {

    icon = "gui/postprocess/didyouseeit.png",
    convar = "pp_krgn_ykz_cmef_enable",
    category = "Yakuza (RGG)",
    cpanel = function( CPanel )

        CPanel:AddControl( 
            "Header", {
                    Description = "A Simple Yakuza Style Camera Effect (Credits to FosterZ for the Original Lua!)" 
            } )

        CPanel:AddControl( 
            "CheckBox", 
            { 
                Label = "Enable effect", 
                Command = "pp_krgn_ykz_cmef_enable" 
            } )


        CPanel:AddControl( 
            "CheckBox", 
            { 
                Label = "Use Locked Camera Style", 
                Command = "pp_krgn_ykz_cmef_uselockedcamerastyle" 
            } )
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Camera Chunks Size", 
                Command = "pp_krgn_ykz_cmef_chsize", 
                Type = "Integer", 
                Min = "20", 
                Max = "1024" 
            } )
    
        CPanel:AddControl( 
            "CheckBox", 
            { 
                Label = "[NonLocked Camera] Ignore chunks (FreeRoam)", 
                Command = "pp_krgn_ykz_cmef_ignore_chunks", 
            } )
    
    
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "[NonLocked] Cam Dist.", 
                Command = "pp_krgn_ykz_cmef_cam_nlc_dist", 
                Type = "Integer", 
                Min = "30", 
                Max = "2000" 
            } )        

        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "[Chunks] Cam Dist. Limit", 
                Command = "pp_krgn_ykz_cmef_cam_max_dist", 
                Type = "Integer", 
                Min = "30", 
                Max = "2000" 
            } )

        CPanel:AddControl( 
            "CheckBox", 
            { 
                Label = "Custom camera Height ", 
                Command = "pp_krgn_ykz_cmef_cam_auto_heigth" 
            } )

        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Camera height", 
                Command = "pp_krgn_ykz_cmef_cam_heigh_limit", 
                Type = "Integer", 
                Min = "-256", 
                Max = "1000" 
            } )
        CPanel:AddControl( 
            "CheckBox", 
            { 
                Label = "Lerp camera position", 
                Command = "pp_krgn_ykz_cmef_cam_lerp" 
            } )
        CPanel:AddControl( 
            "CheckBox", 
            { 
                Label = "Lock camera pitch", 
                Command = "pp_krgn_ykz_cmef_ang_fixed" 
            } )
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Camera pitch", 
                Command = "pp_krgn_ykz_cmef_ang_pitch", 
                Type = "Integer", 
                Min = "-90", 
                Max = "90" 
            } )
        CPanel:AddControl( 
            "Slider", 
            { 
                Label = "Camera FOV", 
                Command = "pp_krgn_ykz_cmef_fov", 
                Type = "Integer", 
                Min = "10", 
                Max = "110" 
            } )

        CPanel:AddControl( 
            "Button", 
            { 
                Label = "Reset Settings (Locked)", 
                Command = "pp_krgn_ykz_cmef_reset", 
            } )
        CPanel:AddControl( 
            "Button", 
            { 
                Label = "Reset Settings (Unlocked)", 
                Command = "pp_krgn_ykz_cmef_reset2", 
            } )


        CPanel:AddControl( 
            "label", 
            { 
                Text = "If you have conflicted addons",
            } )
        CPanel:AddControl( 
            "CheckBox", 
            { 
                Label = "Skip other CalcView hooks ", 
                Command = "pp_krgn_ykz_cmef_skip_other_hooks" 
            } )

        CPanel:AddControl( 
            "label", 
            { 
                Text = "This will disable Camera Hooks Made by any other Addons (BE CAREFUL)",
            } )


    end


} )



