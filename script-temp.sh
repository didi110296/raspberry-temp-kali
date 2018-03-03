#!/bin/bash

# récupération de la température ; on obtient ici une valeur à 5 chiffres sans virgules (ex: 44123) :
TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)

# on divise alors la valeur obtenue par 1000, pour obtenir un résultat avec deux chiffres seulement (ex: 44) :
TEMP=$(($TEMP/1000))

# récupération de la date et l'heure du jour ; on obtient ici une valeur telle que "mercredi 31 décembre 2014, 00:15:01" :
DATE=`date +"%A %d %B %Y, %H:%M:%S"`

# récupération de la date et l'heure du jour sous un autre format ; on obtient ici un résultat sous la forme suivante : XX-YY-ZZZZ (ex: 31-12-2014) :
DATE2=`date +"%d-%m-%Y"`

# définition du chemin du répertoire à créer :
REP="/var/www/html/temp/$DATE2"

# le fichier à créer dans ce répertoire est "temperature.html"
FICHIER="${REP}/temp.html"

# Si le répertoire n'existe pas on le crée
if [ ! -d "$REP" ];then
 mkdir "$REP"
fi

# Si le fichier n'existe pas on le crée et on y injecte le code html minimum
if [ ! -f "$FICHIER" ];then
 touch "$FICHIER" &&
 echo "<!DOCTYPE html><html><head><meta charset='utf-8' /></head><body><center>" > "$FICHIER"
fi


# Tests des températures

# pour les températures inférieures à 40°C, on écrit la valeur en bleu dans le fichier.
if [ $TEMP -lt 40 ]; then
    echo "<font face='Courier'>${DATE}<br><strong><font color='blue'>${TEMP}°C</font></font></strong><br><br>" >> "$FICHIER"

# pour les températures comprises entre +40 et 50°C, on écrit la valeur en vert dans le fichier.
elif [ $TEMP -ge 40 ] && [ $TEMP -lt 50 ];then
    echo "<font face='Courier'>${DATE}<br><strong><font color='green'>${TEMP}°C</font></font></strong><br><br>" >> "$FICHIER"

# pour les températures comprises entre +50 et 70°C, on écrit la valeur en orange dans le fichier.
elif [ $TEMP -ge 50 ] && [ $TEMP -lt 70 ];then
    echo "<font face='Courier'>${DATE}<br><strong><font color='orange'>${TEMP}°C</font></font></strong><br><br>" >> "$FICHIER"

# pour les températures comprises entre +70 et 75°C, on écrit la valeur en rouge dans le fichier ; on envoi une alerte "surchauffe" par mail
elif [ $TEMP -ge 70 ] && [ $TEMP -lt 75 ];then
    echo "<font face='Courier'>${DATE}<br><strong><font color='red'>${TEMP}°C</font></font></strong><br><br>" >> "$FICHIER"
    echo "" | mutt -s "RPi (R4) - Arrêt immédiat, Température anormalement excessive = ${TEMP}°C" mon_email
    sudo shutdown -h now

# pour les températures dépassant 75°, on écrit la valeur en noir dans le fichier ; on envoi une alerte "température anormale" par mail et on ordonne l'arrêt du RPi.
elif [ $TEMP -ge 75 ];then
    echo "<font face='Courier'>${DATE}<br><strong><font color='black'>${TEMP}°C</font></font></strong><br><br>" >> "$FICHIER"
    echo "" | mutt -s "RPi (R5) - Arrêt immédiat, Température radioactive = ${TEMP}°C" mon_email
    sudo shutdown -h now

fi
exit 0
