# nethealth
A plasmoid for KDE to easily see the internet connectivity health



# test

clear; plasmoidviewer -a package -l topedge -f horizontal

kpackagetool5 -i package
kpackagetool5 -u package
kquitapp5 plasmashell && kstart5 plasmashell

