# conky
Conky perso réalisé en partant de notifyOSD de BigRZA (http://bigrza.deviantart.com/art/notifyOSD-conky-206763506) et optimisé par Didier-T sur le forum Ubuntu (https://forum.ubuntu-fr.org/viewtopic.php?pid=20074491#p20074491). Un grand merci à eux !

pour l'installation vous aurez besoin :
- des polices 
    - Moon Phases : http://www.dafont.com/fr/moon-phases.font
    - Weather : http://www.dafont.com/fr/weather.font
    - Heyding Icons : http://www.dafont.com/fr/heydings-icons.font
    - Open Logos : http://www.dafont.com/openlogos.font
- d'une clé API à demander sur le site openweathermap pour la météo (http://openweathermap.org/appid). Cette clé comporte 32 caractères (chiffre et lettre). Il faut la rentrer dans le fichier meteo.lua à la place de la chaine de caractère "MettezVotreAppidIci" (2 occurences).
- des paquets :
    - curl
    - lm-sensors
    - lua-posix

Je me sers du script "wlppr" pour changer aléatoirement mon fond d'écran. Je change l'image de fond du conky (base.png) pour s'adapter à la couleur du fond d'écran. Lorsque la couleur du fond d'écran est trop clair, l'écriture passe en noir pour rester lisible, d'où la présence de "script_modele.lua". 

L'utilisation de wlppr nécessite l'installation de imagemagick.


