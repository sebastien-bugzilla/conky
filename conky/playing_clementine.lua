-- Biliothèque de récupération de donées clementine pour conky
-- Ecrit par Didier-T
-- Du forum ubuntu.fr
-- Pour les besoins d'un conky créer par Ferod
-- Le 23/06/2015


local json = require('json')
local posix = require('posix')
local assert = assert
local os = require('os')
local io = require('io')
local dermodif = nil
local info_titre, time_titre
module("playing_clementine")

do
    function info(recherche)
        --Vérifier l'existence d'un fichier
        local function existe(file)
            local a = io.open(file, "r")
            local present
            if a then
                present = true
                io.close(a)
            else
                present = false
            end
            return present
        end
        if existe("/home/sebastien/.conky/data_clem_piste") then
            local dermodif2=posix.stat('/home/sebastien/.conky/data_clem_piste', 'mtime')
            if dermodif == nil or dermodif ~= dermodif2 then
                dermodif=dermodif2
                local file = assert(io.open("/home/sebastien/.conky/data_clem_piste", "rb") )
                local line = file:read()
                info_titre = json.decode(line)
                assert(file:close())
            end
        end
        if existe("/home/sebastien/.conky/data_clem_temps") then
            local dermodif4=posix.stat('/home/sebastien/.conky/data_clem_temps', 'mtime')
            if dermodif3 == nil or dermodif3 ~= dermodif4 then
                dermodif3=dermodif4
                local file = assert(io.open("/home/sebastien/.conky/data_clem_temps", "rb"))
                local line = file:read()
                time_titre = json.decode(line)
                assert(file:close())
            end
        end

        if info_titre==nil or time_titre==nil then
            return
        elseif recherche=="artiste" then
            return info_titre["artist"] or "N/A"
        elseif recherche=="titre" then
            return info_titre["title"] or "N/A"
        elseif recherche=="album" then
            return info_titre["album"] or "N/A"
        elseif recherche=="genre" then
            return info_titre["genre"] or "N/A"
        elseif recherche=="annee" then
            return info_titre["year"] or "N/A"
        elseif recherche=="tracknumber" then
            return info_titre["tracknumber"] or "N/A"
        elseif recherche=="bitrate" then
            return info_titre["bitrate"] or "N/A"
        elseif recherche=="samplerate" then
            return info_titre["samplerate"] or "N/A"
        elseif recherche=="temp_passe" then
            return time_titre["etime"] or "0"
        elseif recherche=="temp_restant" then
            return time_titre["rtime"] or "0"
        elseif recherche=="temp_titre" then
            return time_titre["mtime"] or "0"
        elseif recherche=="avancement" then
            return time_titre["progress"] or "0"
        else
            return "Non affecté"
        end
    end
end
