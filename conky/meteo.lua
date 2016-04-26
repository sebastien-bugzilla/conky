-- Biliothèque météo simple pour conky
-- Ecrit par Didier-T
-- Du forum ubuntu.fr
-- Pour les besoins d'un conky créer par Ferod
-- Le 23/06/2015


local json = require('json')
local math = require('math')
local tonumber = tonumber
local assert = assert
local os = require('os')
local io = require('io')
local cc, sj, r
local print = print
local tostring = tostring
module("meteo")

-- utiliser le code postal pour trouver la ville

do
    function maj(code_postal, periode)
        periode=periode or "all"
        code_postal=code_postal or "75000"

        function curl(url,file)
            local cmd="curl  -s ".."\""..url.."\" | sed -r 's/\\.[0-9]*//g' > /home/sebastien/.conky/"..file
            local e=os.execute(cmd)
            local file=assert(io.open("/home/sebastien/.conky/"..file, "r"))
            local r=file:read()
            assert(file:close())
            return r, (e==0 or e==true)
        end
        
        function cond_cour(code_postal)
            local r,e=curl("http://api.openweathermap.org/data/2.5/weather?q="..code_postal..",fr&mode=json&units=metric&lang=fr&appid=MettezVotreAppidIci","data_meteo_actu")
            local ret=json.decode(r)
            ret["weather"][1]["id"]=tostring(ret["weather"][1]["id"]):gsub("200", "i"):gsub("201", "i"):gsub("202", "i"):gsub("230", "i"):gsub("231", "i"):gsub("232", "i"):gsub("906", "i"):
                gsub("210", "f"):gsub("211", "f"):gsub("212", "f"):
                gsub("221", "W"):gsub("731", "W"):gsub("900","W"):
                gsub("300", "G"):gsub("301", "G"):gsub("302", "G"):gsub("310", "G"):gsub("311", "G"):gsub("312", "G"):gsub("321", "G"):
                gsub("500", "g"):gsub("501", "g"):gsub("520", "g"):
                gsub("502", "h"):gsub("503", "h"):gsub("504", "h"):gsub("521", "h"):gsub("522", "h"):
                gsub("511", "k"):gsub("600", "k"):gsub("601", "k"):gsub("611", "k"):gsub("621", "k"):
                gsub("602", "j"):
                gsub("701", "J"):gsub("711", "J"):
                gsub("721", "I"):
                gsub("741", "F"):
                gsub("800", "C"):
                gsub("801", "b"):
                gsub("802", "c"):
                gsub("803", "d"):
                gsub("804", "e"):
                gsub("901", "V"):gsub("902", "V"):
                gsub("903", "x"):
                gsub("904", "z"):
                gsub("905", "v")
            --ret["main"]["temp"]=tostring(math.floor(ret["main"]["temp"]))
            return ret
            
        end
        function sept_jour(code_postal)
            local r,e=curl("http://api.openweathermap.org/data/2.5/forecast/daily?q="..code_postal..",fr&mode=json&units=metric&cnt=7&lang=fr&appid=MettezVotreAppidIci","data_meteo_prev")
            local ret=json.decode(r)
            for jour=1, 7 do
                ret["list"][jour]["weather"][1]["id"]=tostring(ret["list"][jour]["weather"][1]["id"]):
                    gsub("200", "i"):gsub("201", "i"):gsub("202", "i"):gsub("230", "i"):gsub("231", "i"):gsub("232", "i"):gsub("906", "i"):
                    gsub("210", "f"):gsub("211", "f"):gsub("212", "f"):
                    gsub("221", "W"):gsub("731", "W"):gsub("900","W"):
                    gsub("300", "G"):gsub("301", "G"):gsub("302", "G"):gsub("310", "G"):gsub("311", "G"):gsub("312", "G"):gsub("321", "G"):
                    gsub("500", "g"):gsub("501", "g"):gsub("520", "g"):
                    gsub("502", "h"):gsub("503", "h"):gsub("504", "h"):gsub("521", "h"):gsub("522", "h"):
                    gsub("511", "k"):gsub("600", "k"):gsub("601", "k"):gsub("611", "k"):gsub("621", "k"):
                    gsub("602", "j"):
                    gsub("701", "J"):gsub("711", "J"):
                    gsub("721", "I"):
                    gsub("741", "F"):
                    gsub("800", "C"):
                    gsub("801", "b"):
                    gsub("802", "c"):
                    gsub("803", "d"):
                    gsub("804", "e"):
                    gsub("901", "V"):gsub("902", "V"):
                    gsub("903", "x"):
                    gsub("904", "z"):
                    gsub("905", "v")
            end
            return ret
        end
        
        if periode=="all" then
            cc=cond_cour(code_postal)
            sj=sept_jour(code_postal)
        elseif periode=="cc" then
            cc=cond_cour(code_postal)
        else
            sj=sept_jour(code_postal)
        end
    end

    function info(valeur, jour)
        jour=tonumber(jour) or 0

        if jour==0 then
            if valeur=="lon" then
                r = cc["coord"]["lon"]
            elseif valeur=="lat" then
                r = cc["coord"]["lat"]
            elseif valeur=="pays" then
                r = cc["sys"]["country"]
            elseif valeur=="leve_soleil" then
                r = cc["sys"]["sunrise"]
            elseif valeur=="coucher_soleil" then
                r = cc["sys"]["sunset"]
            elseif valeur=="meteo_id" then
                r = cc["weather"][1]["id"]
            elseif valeur=="meteo_main" then
                r = cc["weather"][1]["main"]
            elseif valeur=="meteo_description" then
                r = cc["weather"][1]["description"]
            elseif valeur=="meteo_icone" then
                r = cc["weather"][1]["icon"]
            elseif valeur=="temp" then
                r = cc["main"]["temp"]
            elseif valeur=="temp_min" then
                r = cc["main"]["temp_min"]
            elseif valeur=="temp_max" then
                r = cc["main"]["temp_max"]
            elseif valeur=="pression" then
                r = cc["main"]["pressure"]
            elseif valeur=="sea_level" then
                r = cc["main"]["sea_level"]
            elseif valeur=="grnd_level" then
                r = cc["main"]["grnd_level"]
            elseif valeur=="humidite" then
                r = cc["main"]["humidity"]
            elseif valeur=="vent_vitesse" then
                r = cc["wind"]["speed"]
            elseif valeur=="vent_direction" then
                r = cc["wind"]["deg"]
            elseif valeur=="couverture_nuageuse" then
                r = cc["clouds"]["all"]
            elseif valeur=="pluie_court_terme" then
                if cc["rain"] ~= nil then
                    r = cc["rain"]["1h"]
                else
                    r = 0
                end
            elseif valeur=="date" then
                r = cc["dt"]
            elseif valeur=="ville" then
                r = cc["name"]
            else
                r = valeur.." n'existe pas"
            end
        else
            if valeur=="date" then
                r = sj["list"][jour]["dt"]
            elseif valeur=="temp_jour" then
                r = sj["list"][jour]["temp"]["day"]
            elseif valeur=="temp_min" then
                r = sj["list"][jour]["temp"]["min"]
            elseif valeur=="temp_max" then
                r = sj["list"][jour]["temp"]["max"]
            elseif valeur=="temp_nuit" then
                r = sj["list"][jour]["temp"]["night"]
            elseif valeur=="temp_soir" then
                r = sj["list"][jour]["temp"]["eve"]
            elseif valeur=="temp_matin" then
                r = sj["list"][jour]["temp"]["morn"]
            elseif valeur=="pression" then
                r = sj["list"][jour]["pressure"]
            elseif valeur=="humidite" then
                r = sj["list"][jour]["humidity"]
            elseif valeur=="meteo_id" then
                r = sj["list"][jour]["weather"][1]["id"]
            elseif valeur=="meteo_main" then
                r = sj["list"][jour]["weather"][1]["main"]
            elseif valeur=="meteo_description" then
                r = sj["list"][jour]["weather"][1]["description"]
            elseif valeur=="meteo_icone" then
                r = sj["list"][jour]["weather"][1]["icon"]
            elseif valeur=="vent_vitesse" then
                r = sj["list"][jour]["speed"]
            elseif valeur=="vent_direction" then
                r = sj["list"][jour]["deg"]
            elseif valeur=="couverture_nuageuse" then
                r = sj["list"][jour]["clouds"]
            elseif valeur=="pluviometrie" then
                r = sj["list"][jour]["rain"] or 0
            else
                r = valeur.." "..jour.." n'existe pas"
            end
        end
        return r
    end
end
