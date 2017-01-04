--this is a lua script for use in conky
require 'cairo'
require 'os'
require 'posix'

-- Parametre a modifier
local departement="Toulouse" -- indiquer le département pour la météo
local disque_1="/home"
local disque_2="/"
local disque_3="/media/Documents"
--local chemin="~/.conky" -- répertoire ou ce trouve vos scripts

--[[
###################################################################################################
#  Ne pas faire de modification après cette ligne (sauf si vous savez ce que vous faite), Merci.  #
###################################################################################################
]]--
--Bibliothèque maison
-- on determine le répertoire de travail
function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end
chemin=script_path()
posix.chdir(chemin)

-- on ajoute les Bibliothèques
local meteo=require('meteo')
local play=require('playing_clementine')
local moon=require('moon')

-- Mise en place des variables d'environement
local home = os.getenv("HOME")
disque_1=string.gsub(disque_1,"~",home)
disque_2=string.gsub(disque_2,"~",home)
disque_3=string.gsub(disque_3,"~",home)
local nb_coeur=tonumber(4)

local Clementine
local T00=0
local T0=0
local T=0
local cr, TEMP1, TEMP2, temp1, temp2
local demon=1

-- Partie Fonctions
local function draw_circle(alpha,progress,x_center,y_center,radius,epaisseur)
    cairo_set_source_rgba(cr,0,0,0,alpha)
    cairo_set_line_width(cr,epaisseur)
    cairo_arc(cr, x_center, y_center, radius, 0-math.pi/2, progress * 2 * math.pi / 100 - math.pi/2)
    cairo_stroke(cr)
end

local function draw_circle_gauge(alpha,nb_gauge,angle_step,angle_step_ink,x_center,y_center,radius,epaisseur)
    cairo_set_source_rgba(cr,0,0,0,alpha)
    cairo_set_line_width(cr,epaisseur)
    local angle_step_rad=angle_step*math.pi/180
    local angle_step_ink_rad=angle_step_ink*math.pi/180
    local i = 1
    local angle=-math.pi/2
    while i <= nb_gauge do
        cairo_arc(cr, x_center, y_center, radius, angle, angle + angle_step_ink_rad)
        angle=angle+angle_step_rad
        cairo_stroke(cr)
        i = i+1
    end

end

local function draw_line(alpha,progress,x_ligne,y_ligne,longueur,epaisseur)
    progress=progress or 0
    local red,green,blue=0,0,0
    cairo_set_source_rgba (cr,0,0,0,alpha)
    cairo_set_line_width (cr, epaisseur)
    cairo_set_dash(cr,1.,0,1)
    cairo_move_to (cr, x_ligne, y_ligne)
    cairo_line_to (cr, x_ligne+((progress/100)*longueur), y_ligne)
    cairo_stroke (cr)
end

local function draw_dash_line(alpha,progress,x_ligne,y_ligne,longueur,epaisseur)
    local red,green,blue=0,0,0
    cairo_set_source_rgba (cr,0,0,0,alpha)
    cairo_set_line_width (cr, epaisseur)
    cairo_set_dash(cr,5.,1,0)
    cairo_move_to (cr, x_ligne, y_ligne)
    cairo_line_to (cr, x_ligne+longueur*progress/100, y_ligne)
    cairo_stroke (cr)
end

local function draw_scale(alpha,x_ligne,y_ligne,nb_step,long_step_ink,long_step,epaisseur)
    local red,green,blue=0,0,0
    cairo_set_source_rgba (cr,0,0,0,alpha)
    cairo_set_line_width (cr, epaisseur)
    local i = 1
    local x_step=x_ligne
    while i <= nb_step do
        cairo_move_to (cr, x_step, y_ligne)
        cairo_line_to (cr, x_step+long_step_ink,y_ligne)
        cairo_stroke (cr)
        x_step=x_step + long_step
        i=i+1
    end
end

local function affiche_texte(police,taille,x,y,alpha,texte)
    local red,green,blue,alpha=0,0,0,alpha
    cairo_select_font_face (cr, police, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size (cr, taille)
    cairo_set_source_rgba (cr,red,green,blue,alpha)
    cairo_move_to (cr,x,y)
    cairo_show_text (cr,texte)
    cairo_stroke (cr)
end


-- Partie script
function graph_line(Maj)
    --if Maj==1 then
        -- Températures
    local TEMP1=tonumber(conky_parse("${exec sensors | awk ' $2==\"0:\" {print $3}' | cut -c 2-3}"))
    local TEMP2=tonumber(conky_parse("${exec sensors | awk ' $2==\"1:\" {print $3}' | cut -c 2-3}"))
    --end

    -- Utilisation Disque
    local used_perc1=tonumber(conky_parse("${fs_used_perc "..disque_1.."}"))
    local used_perc2=tonumber(conky_parse("${fs_used_perc "..disque_2.."}"))
    local used_perc3=tonumber(conky_parse("${fs_used_perc "..disque_3.."}"))
    -- A chaque cycle
    -- Heure
    local heure=tonumber(conky_parse("${time %I}"))
    local minute=tonumber(conky_parse("${time %M}"))
    local seconde=tonumber(conky_parse("${time %S}"))
    -- Utilisation CPU
    local cpu={}
    for i = 1,nb_coeur do
        cpu[i]=tonumber(conky_parse("${cpu cpu"..i.."}"))
    end
    -- UP Down
    local ratio_upload=tonumber(conky_parse("${upspeedf enp7s0}")/90*100)
    local ratio_download=tonumber(conky_parse("${downspeedf enp7s0}")/302*100)
    local totalup=conky_parse("${totalup enp7s0}")
    num_car_up=string.find(totalup,"MiB")
    if num_car_up==nil then
        total_upload=0
        totalup=0
    else
        total_upload=tonumber(string.sub(totalup,0,num_car_up-1))
    end
    local totaldown=conky_parse("${totaldown enp7s0}")
    num_mib_down=string.find(totaldown,"MiB")
    num_gib_down=string.find(totaldown,"GiB")
    if num_mib_down==nil then
        if num_gib_down==nil then
            total_download=0
            totaldown=0
        else
            total_download=tonumber(string.sub(totaldown,0,num_gib_down-1))*1000
        end
    else
        total_download=tonumber(string.sub(totaldown,0,num_mib_down-1))
    end
    -- Clementine
    Clementine=play.info("avancement")

    -- Horloge
    draw_circle(0.2,100,204,48,20,2)
    draw_circle(0.2,100,204,48,25,2)
    if heure == 12 then
        heure = 0
    end
    local prog_seconde=seconde/60
    local prog_minute=(minute+prog_seconde)/60
    local prog_heure=(heure+prog_minute)/12
    draw_circle(1.,prog_minute*100,204,48,25,2)
    draw_circle(1.,prog_heure*100,204,48,20,2)
    draw_circle_gauge(1,12,30,2,204,48,20,2)
    draw_circle_gauge(1,12,30,2,204,48,25,2)
    draw_circle_gauge(1,seconde,6,2,204,48,30,2)

    --CPU & RAM
    local y_img_4 = 219
    draw_scale(0.5,153,y_img_4+32,36,1,5,3)
    draw_scale(1,153,y_img_4+32,8,1,25,6)
    local temp1=TEMP1-30
    local temp2=TEMP2-30
    if temp1<0 then
        temp1 = 0
    end
    if temp2<0 then
        temp2 = 0
    end
    draw_line(temp1/35,(temp1/35)*100,153,y_img_4+31,176,2)
    draw_line(temp2/35,(temp2/35)*100,153,y_img_4+33,176,2)

    for i = 1,nb_coeur do
        if cpu[i] == nil then cpu[i]=0 end
    end
    draw_line(0.2,100,180,y_img_4+44,150,2)
    local ratio_barre=(150/nb_coeur)

    -- calcul pour affichage barre ratio cpu
    local x1 = {}
    x1[1]=180 -- début barre cpu1
    for i = 1,nb_coeur do
        x1[i+1]=x1[i]+cpu[i]/100*ratio_barre
    end

    -- affichage barre occupation cpu
    local ratio_trans=(0.8/nb_coeur)
    for i = 1,nb_coeur do
        draw_line(1-(i-1)*ratio_trans,cpu[i],x1[i],y_img_4+44,ratio_barre,2)
    end
    
    --ram
    draw_line(0.2,100,180,y_img_4+61,150,2)
    local mem_perc=tonumber(conky_parse("${memperc}"))
    draw_line(1,mem_perc,180,y_img_4+61,150,2)
    
    --uptime
    uptime=conky_parse("${uptime_short}")
    rep_heure=string.find(uptime,"h")
    rep_minute=string.find(uptime,"m")
    if rep_heure == nil then
        up_hr=0
        up_min=tonumber(string.sub(uptime,1,rep_minute-1))
    else
        up_hr=tonumber(string.sub(uptime,1,rep_heure-1))
        up_min=tonumber(string.sub(uptime,rep_heure+1,rep_minute-1))
    end
    up_max=math.max(up_hr,8)+1
    up_prog=(up_hr+up_min/60)/up_max*100
    up_step=(140-up_max-1)/up_max+1
    affiche_texte("Ubuntu",11,144,y_img_4+77,1,uptime)
    draw_line(0.2,100,190,y_img_4+74,140,2)
    draw_line(1,up_prog,190,y_img_4+74,140,2)
    draw_scale(1,190,y_img_4+74,up_max+1,1,up_step,4)
    
    --utilisation disque :
    local y_img_5 = 292
    draw_line(0.2,100,160,y_img_5+33,170,2)
    draw_line(1,used_perc1,160,y_img_5+33,170,2)

    draw_line(0.2,100,160,y_img_5+53,170,2)
    draw_line(1,used_perc2,160,y_img_5+53,170,2)

    draw_line(0.2,100,160,y_img_5+73,170,2)
    draw_line(1,used_perc3,160,y_img_5+73,170,2)

    --upload
    local y_img_6 = 365
    draw_line(0.2,100,130,y_img_6+30,200,2)
    draw_line(1,ratio_upload,130,y_img_6+30,200,2)
    affiche_texte("Ubuntu",11,295,y_img_6+27,0.7,"90 KiB")
    
    local max_upload=math.max(math.floor(total_upload/10)+1,10)*10
    draw_line(0.2,100,130,y_img_6+45,200,2)
    draw_line(1,total_upload/max_upload*100,130,y_img_6+45,200,2)
    num_step_up = max_upload/10 + 1
    long_step=(200-num_step_up)/(num_step_up - 1)+1
    draw_scale(1,130,y_img_6+45,num_step_up,1,long_step,4)
    affiche_texte("Ubuntu",11,295,y_img_6+42,0.7,max_upload.." MiB")
    --
    
    --download
    draw_line(0.2,100,130,y_img_6+60,200,2)
    draw_line(1,ratio_download,130,y_img_6+60,200,2)
    affiche_texte("Ubuntu",11,295,y_img_6+57,0.7,"300 KiB")
    
    local max_download=math.max(10,math.floor(total_download/100)+1)*100
    draw_line(0.2,100,130,y_img_6+75,200,2)
    draw_line(1,total_download/max_download*100,130,y_img_6+75,200,2)
    num_step_down = max_download/100 + 1
    long_step_down=(200-num_step_down)/(num_step_down-1)+1
    draw_scale(1,130,y_img_6+75,num_step_down,1,long_step_down,4)
    affiche_texte("Ubuntu",11,295,y_img_6+72,0.7,max_download.." MiB")
    
    -- lecture musique
    if Clementine ~= nil then
        local y_img_7 = 438
        draw_line(0.2,100,100,y_img_7+70,230,2)
        local progress=tonumber(Clementine)
        draw_line(1,progress,100,y_img_7+70,230,2)
    end
end

function display_text(Maj)
    local h_leve=os.date("%Hh%M", meteo.info("leve_soleil"))
    local h_couche=os.date("%Hh%M", meteo.info("coucher_soleil"))
    local meteo_act=meteo.info("meteo_description")
    local pression=meteo.info("pression")
    local temp_act=meteo.info("temp")
    local text_meteo=meteo.info("meteo_id")
    local humidite=meteo.info("humidite")
    local speed=math.floor(meteo.info("vent_vitesse")*3.6)
    local direction_vent=meteo.info("vent_direction")
    local precipitation=meteo.info("pluie_court_terme")
    local temp_min=meteo.info("temp_min", 1)
    local temp_max=meteo.info("temp_max", 1)
    local semaine_meteo_2=meteo.info("meteo_id", 2)
    local semaine_meteo_3=meteo.info("meteo_id", 3)
    local semaine_meteo_4=meteo.info("meteo_id", 4)
    local semaine_meteo_5=meteo.info("meteo_id", 5)
    local semaine_meteo_6=meteo.info("meteo_id", 6)
    local semaine_meteo_7=meteo.info("meteo_id", 7)
--    -- affichage du jour
    local semaine_jour_2=os.date("%a", meteo.info("date", 2))
    local semaine_jour_3=os.date("%a", meteo.info("date", 3))
    local semaine_jour_4=os.date("%a", meteo.info("date", 4))
    local semaine_jour_5=os.date("%a", meteo.info("date", 5))
    local semaine_jour_6=os.date("%a", meteo.info("date", 6))
    local semaine_jour_7=os.date("%a", meteo.info("date", 7))
--    -- prévision température jour
    local semaine_temp_2=meteo.info("temp_jour", 2).."°C"
    local semaine_temp_3=meteo.info("temp_jour", 3).."°C"
    local semaine_temp_4=meteo.info("temp_jour", 4).."°C"
    local semaine_temp_5=meteo.info("temp_jour", 5).."°C"
    local semaine_temp_6=meteo.info("temp_jour", 6).."°C"
    local semaine_temp_7=meteo.info("temp_jour", 7).."°C"

    local espace1=conky_parse("${fs_used_perc "..disque_1.."}").."%"
    local espace2=conky_parse("${fs_used_perc "..disque_2.."}").."%"
    local espace3=conky_parse("${fs_used_perc "..disque_3.."}").."%"
    local esp_used1=conky_parse("${fs_used "..disque_1.."}")
    local esp_used2=conky_parse("${fs_used "..disque_2.."}")
    local esp_used3=conky_parse("${fs_used "..disque_3.."}")
    local esp_free1=conky_parse("${fs_free "..disque_1.."}")
    local esp_free2=conky_parse("${fs_free "..disque_2.."}")
    local esp_free3=conky_parse("${fs_free "..disque_3.."}")


    local cpu=conky_parse("${cpu cpu0}")

    local y_img_1 = 0    
    
    --[[###########################################
        Heure et Date
    ##############################################]]
    nb_jour=os.date("%j")
    annee=tonumber(os.date("%Y"))
    lune=moon.lecture(annee)
    affiche_texte("Ubuntu",11,92,y_img_1+27,1,"J"..conky_parse("${time %j}").." - S"..conky_parse("${time %V}"))
    affiche_texte("Sans",35,93,y_img_1+56,1,"☼")
    affiche_texte("Ubuntu",11,95,y_img_1+67,1,h_leve)
    affiche_texte("Ubuntu",11,95,y_img_1+77,1,h_couche)
    affiche_texte("Moon Phases",35,130,y_img_1+70,1,lune)
    affiche_texte("Ubuntu",12,189,y_img_1+52,1,conky_parse("${time %H:%M}"))     --heure
    affiche_texte("Ubuntu",12,282,y_img_1+36,1,conky_parse("${time %A}"))        --nom du jour
    affiche_texte("Ubuntu",12,282,y_img_1+47,1,conky_parse("${time %B}"))        --nom du mois
    affiche_texte("Ubuntu",32,245,y_img_1+47,1,conky_parse("${time %d}"))        --numeros du jour
    affiche_texte("Ubuntu",32,245,y_img_1+73,1,conky_parse("${time %Y}"))        --année

    --[[###########################################
        Météo actuelle
    ##############################################]]
    local y_img_2 = 73
    affiche_texte("Weather",65,95,y_img_2+77,1,text_meteo)
    affiche_texte("Ubuntu",12,95,y_img_2+28,1,temp_act.."°C")
    affiche_texte("Ubuntu",12,95,y_img_2+78,1,pression.." hPa")
--    
    affiche_texte("Ubuntu",11,160,y_img_2+30,1,meteo_act)
    affiche_texte("Ubuntu",11,160,y_img_2+45,1,"Humidité : "..humidite.."%")
    if direction_vent==nil then direction_vent="-" end
    affiche_texte("Ubuntu",11,160,y_img_2+60,1,"Vent : "..speed.." km/h - "..direction_vent.." °")
    if precipitation==nil then precipitation="-" end
    affiche_texte("Ubuntu",11,160,y_img_2+75,1,"Pluies : "..precipitation.." mm")

    affiche_texte("Ubuntu",11,315,y_img_2+70,1,temp_min.."°C")
    affiche_texte("Ubuntu",11,315,y_img_2+35,1,temp_max.."°C")
    affiche_texte("Weather",60,295,y_img_2+72,1,"y")

    --[[###########################################
        prévision météo semaine
    ##############################################]]
    local y_img_3 = 146
    affiche_texte("Weather",50,95,y_img_3+67,1,semaine_meteo_2)
    affiche_texte("Weather",50,135,y_img_3+67,1,semaine_meteo_3)
    affiche_texte("Weather",50,175,y_img_3+67,1,semaine_meteo_4)
    affiche_texte("Weather",50,215,y_img_3+67,1,semaine_meteo_5)
    affiche_texte("Weather",50,255,y_img_3+67,1,semaine_meteo_6)
    affiche_texte("Weather",50,295,y_img_3+67,1,semaine_meteo_7)

--    -- affichage du jour
    affiche_texte("Ubuntu",11,100,y_img_3+27,1,semaine_jour_2)
    affiche_texte("Ubuntu",11,140,y_img_3+27,1,semaine_jour_3)
    affiche_texte("Ubuntu",11,180,y_img_3+27,1,semaine_jour_4)
    affiche_texte("Ubuntu",11,220,y_img_3+27,1,semaine_jour_5)
    affiche_texte("Ubuntu",11,260,y_img_3+27,1,semaine_jour_6)
    affiche_texte("Ubuntu",11,300,y_img_3+27,1,semaine_jour_7)

--    -- prévision température jour
    affiche_texte("Ubuntu",12,100,y_img_3+74,1,semaine_temp_2)
    affiche_texte("Ubuntu",12,140,y_img_3+74,1,semaine_temp_3)
    affiche_texte("Ubuntu",12,180,y_img_3+74,1,semaine_temp_4)
    affiche_texte("Ubuntu",12,220,y_img_3+74,1,semaine_temp_5)
    affiche_texte("Ubuntu",12,260,y_img_3+74,1,semaine_temp_6)
    affiche_texte("Ubuntu",12,300,y_img_3+74,1,semaine_temp_7)


    --[[###########################################
        CPU Temperature et RAM
    ##############################################]]
    local y_img_4 = 219
    affiche_texte("Ubuntu",13,100,y_img_4+32,1,"Temp :")
    affiche_texte("Ubuntu",13,100,y_img_4+47,1,"CPU    :")
    affiche_texte("Ubuntu",13,100,y_img_4+62,1,"RAM   :")
    affiche_texte("Ubuntu",13,100,y_img_4+77,1,"Up      :")

    affiche_texte("Ubuntu",10,147,y_img_4+26,1,"30°")
    affiche_texte("Ubuntu",10,197,y_img_4+26,1,"40°")
    affiche_texte("Ubuntu",10,247,y_img_4+26,1,"50°")
    affiche_texte("Ubuntu",10,297,y_img_4+26,1,"60°")

    if cpu == nil then cpu=0 end

    affiche_texte("Ubuntu",11,150,y_img_4+47,1,cpu.."%")

    affiche_texte("Ubuntu",11,150,y_img_4+62,1,conky_parse("${memperc}").."%")
    affiche_texte("Ubuntu",11,180,y_img_4+58,1,conky_parse("${mem}"))
    affiche_texte("Ubuntu",11,290,y_img_4+58,0.7,conky_parse("${memeasyfree}"))

    --[[###########################################
        Espace disponible
    ##############################################]]
    local y_img_5 = 292
    affiche_texte("Heydings Icons",18,100,y_img_5+34,1,"H")
    affiche_texte("OpenLogos",18,100,y_img_5+54,1,"u")
    affiche_texte("Heydings Icons",18,100,y_img_5+74,1,"F")

    affiche_texte("Ubuntu",15,123,y_img_5+33,1,espace1)
    affiche_texte("Ubuntu",15,123,y_img_5+53,1,espace2)
    affiche_texte("Ubuntu",15,123,y_img_5+73,1,espace3)

    affiche_texte("Ubuntu",11,160,y_img_5+30,1,esp_used1)
    affiche_texte("Ubuntu",11,160,y_img_5+50,1,esp_used2)
    affiche_texte("Ubuntu",11,160,y_img_5+70,1,esp_used3)

    affiche_texte("Ubuntu",11,290,y_img_5+30,0.7,esp_free1)
    affiche_texte("Ubuntu",11,290,y_img_5+50,0.7,esp_free2)
    affiche_texte("Ubuntu",11,290,y_img_5+70,0.7,esp_free3)

    --[[###########################################
        Débit internet
    ##############################################]]
    local y_img_6 = 365
    local up_total=conky_parse("${totalup enp7s0}")
    local down_total=conky_parse("${totaldown enp7s0}")
    affiche_texte("Deja",25,95,y_img_6+35,1,"↗")
    affiche_texte("Ubuntu",11,130,y_img_6+27,1,conky_parse("${upspeed enp7s0}"))
    affiche_texte("Ubuntu",11,130,y_img_6+42,1,up_total)
    
    affiche_texte("Deja",25,95,y_img_6+70,1,"↘")
    affiche_texte("Ubuntu",11,130,y_img_6+57,1,conky_parse("${downspeed enp7s0}"))
    affiche_texte("Ubuntu",11,130,y_img_6+72,1,down_total)


    --[[###########################################
        Musique
    ##############################################]]
    if Clementine ~= nil then
        local y_img_7 = 438
        affiche_texte("Ubuntu",11,100,y_img_7+35,1,play.info("album"))
        affiche_texte("Ubuntu",11,100,y_img_7+50,1,play.info("titre"))
        local temp_ecoule=play.info("temp_passe")
        local temp_remain=play.info("temp_restant")
        affiche_texte("Ubuntu",11,100,y_img_7+65,1,temp_ecoule)
        affiche_texte("Ubuntu",11,310,y_img_7+65,0.7,temp_remain)
    end
end

function conky_main()
    local function exec(cmd)
        local cmd=cmd.." > /tmp/exec.log"
        local e=os.execute(cmd)
        local file=assert(io.open("/tmp/exec.log", "r"))
        local r=file:read("*all")
        assert(file:close())
        return r
    end

    if conky_window == nil then
        return
    end

    if demon==1 then
        local list=exec("ps -sa | awk '{print $NF}'")
        if list:find("playing_clementine.py")~=nil then
            demon=0
        else
            demon=os.execute('python '..chemin..'/playing_clementine.py &')
        end
    end

    local cs = cairo_xlib_surface_create(conky_window.display,
                                         conky_window.drawable,
                                         conky_window.visual,
                                         conky_window.width,
                                         conky_window.height)
    cr = cairo_create(cs)
    local updates=tonumber(conky_parse('${updates}'))

    local timer_meteo=(updates % 1800)
    local T1 = os.time()

    -- Gestion mise a jour météo
    if timer_meteo == 5 then
        meteo.maj(departement, "all")
        meteo.maj(departement, "all")
    end


    if updates>=5 then
        if os.difftime(T1, T00) >= 30 then
            display_text(1)
            graph_line(1)
            T00=T1
        else
            display_text(0)
            graph_line(0)
        end
    end

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
    cr=nil
end
