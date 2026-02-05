# nethealth

A plasmoid for KDE to easily see the internet connectivity health.

![logo](https://github.com/facundobatista/nethealth/blob/main/media/icon-256.png?raw=True)

It presents an icon with several colors:
- a greyed out that will not caught attention to your eye if ping time is under 10 milliseconds
- yellow if its greater than that but still below 100 milliseconds
- orange: more than 100 ms but less than 1 second
- red: more than 1s or no ping at all

Clicking in the icon will present the measurement of previous pings:

![sshot](https://github.com/facundobatista/nethealth/blob/main/media/sshot.png?raw=True)

Probably is better to just install it from [the KDE store](https://www.pling.com/p/2346355/), but if want a development version, see below for how to install from project.


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
