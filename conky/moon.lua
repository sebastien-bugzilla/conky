local math = require('math')
local string = require('string')
local tonumber = tonumber
local assert = assert
local os = require('os')
local io = require('io')
local print = print
local tostring = tostring
local annee
module("moon")

do
    function lecture(annee)
        local jour,temp = 0
        local annee_deb=2015
        while annee_deb < annee do
            num_sec=os.time{year=annee_deb, month=12, day=31}
            temp=tonumber(os.date("%j",num_sec))
            jour=jour+temp
            annee_deb=annee_deb + 1
        end
        temp=os.date("%j")
        jour=jour+temp
        local alphabet = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
        iter = io.lines("cycle_lunaire_2025")
        for i=0, jour - 3 do
            if not iter() then
                error 'Not enough lines in file'
            end
        end
        local hier = tostring(iter())
        local phase_hier = tonumber(string.sub(hier,10))*100
        local aujourdhui = tostring(iter())
        local phase_aujourdhui=tonumber(string.sub(aujourdhui,10))*100
        local difference_phase=phase_aujourdhui-phase_hier
        
        if difference_phase>0 then
            indice_lettre=math.floor((phase_aujourdhui-1)*13/98)+1
        else
            indice_lettre=26-math.floor((phase_aujourdhui-1)*13/98)
        end
        lettre_lune=alphabet[indice_lettre]
        if phase_aujourdhui==0 then
            lettre_lune="1"
        elseif phase_aujourdhui==100 then
            lettre_lune="0"
        end
        --print(lettre_lune)
        return lettre_lune
    end
end

