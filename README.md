# nethealth
A plasmoid for KDE to easily see the internet connectivity health

Probably is better to just install it from FIXME, but if want a development version, see below for how to install from project.


## some tips to facilitate development

This will show the "full representation" of the plasmoid (what you see if you left-click on it):
```
plasmoidviewer -a package -l topedge -f horizontal
```

This is to install the plasmoid from the project:
```
kpackagetool5 -i package
```

Then, if you do changes, you need to update it:
```
kpackagetool5 -u package
```

In both cases, `plasmashell` needs to be restarted (totally sucks):
```
kquitapp5 plasmashell && kstart5 plasmashell
```
