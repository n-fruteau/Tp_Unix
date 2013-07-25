# FRUTEAU DE LACLOS Nicolas 2A IR 
init(){
	if [ -e Data ] 
	then
		rm -r Data
	fi
	if [ -e tafWeb.html ]
	then
		rm tafWeb.html
	fi	
	if [ -e Plan-Vol.html ]
	then
		rm Plan-Vol.html
	fi
}

CreateDossier(){
	if [ ! -d Data ]
	then
		mkdir Data
	fi
}

download()
{
 CreateDossier
 if [ $1 = fr ] || [ $1 = de ] || [ $1 = it ] || [ $1 = bl ] || [ $1 = es ] || [ $1 = po ] ||[ $1 = ch ] || [ $1 = as ]
 then
	if [ -e Data/"$1"-taf.html ] && [ -e Data/"$1"-taf.txt ]
	then
		echo " "
	else
		curl http://wx.rrwx.com/taf-$1-txt.htm > "./Data/$1-taf.txt"
		curl http://wx.rrwx.com/taf-$1.htm > "./Data/$1-taf.html"
	fi
 else
	echo "Le taf de "$1" n'est pas disponible"
 fi
}

extract(){
region="$2"
tafRegion=$(grep "nowrap>$region</td>" Data/$1-taf.html )
longVille=71+$(expr length "$region")
grep ${tafRegion:longVille:4} Data/$1-taf.txt | sed "s/<[^>]*>/ /g" | sed "s/ +/ /g" | sed "s/ -/ /g" | sed "s/ [a-zA-Z][a-zA-Z] / /g" | sed "s/ [a-zA-Z][a-zA-Z] / /g" | sed 's/ [a-zA-Z][a-zA-Z][a-zA-Z] / /g' | sed 's/ [a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z] / /g'  | sed 's/ [a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z] / /g' | sed 's/ [0-9][0-9][0-9][0-9] / /g' | sed 's/^/  TAF /g' | sed "s/$region/ /g"  > Data/tafExtrac.txt
}

headerWeb(){
rm -f tafWeb.html
echo >> tafWeb.html '
<!DOCTYPE html>
<HTML>
  <head>
    <meta charset="utf-8" />
    <TITLE> TAF </TITLE>
  </head>
<BODY>
'
}

footerWeb(){
echo >> tafWeb.html '
</BODY>
</HTML>
'
}

analyse(){
echo >> tafWeb.html '<H2> TAF </H2>
<UL>'
cat 'Data/tafExtrac.txt' | while read ligne
do
set $ligne
echo $ligne
motTest=$1
vartaf=0
while [ "$1" ] ; do 
	while [ "$motTest" = "TAF" ] || [ "${motTest:0:4}" = "PROB" ] ; do
		if [ "$motTest" = "TAF" ]
			then
			shift
			echo >> tafWeb.html '<LI> Airport : '$1' </LI>' 
			
			shift
			jourHeure=$1
			jour=${jourHeure:0:2}
			mois=`date '+%h'`     
			heure=${jourHeure:2:2}
			min=${jourHeure:4:2}
			shift
			echo >> tafWeb.html '<LI> Emitted : '$jour' '$mois' @ '$heure'H'$min'M </LI>'
		elif [ "${motTest:0:4}" = "PROB" ]
			then
			pourcent=${motTest:4:2}
			echo >> tafWeb.html ' <H2> Probality '$pourcent'% </H2>
			<UL>
			</UL>'
			shift
		fi
		while [ "$vartaf" = 0 ] || [ "$1" = "BECMG" ] || [ "$1" = "TEMPO" ] ; do
			if [ "$1" = "BECMG" ]
				then
				echo -e >> tafWeb.html '<H2> Becoming </H2><UL>'
				vartaf=2
			elif [ "$1" = "TEMPO" ]
				then
				echo >> tafWeb.html '<H2> Temporary </H2><UL>'
				vartaf=2
			else 
				vartaf=1
			fi
			if [ "$vartaf" != 1 ]
				then
				shift
			fi
			valid=$1
			jourd=${valid:0:2}
			jourf=${valid:5:2} 
			heured=${valid:2:2}
			heuref=${valid:7:2}
			shift
			echo >> tafWeb.html '<LI> Periode : '$jourd' '$mois' @ '$heured'H00M .. '$jourf' '$mois' '$heuref'H00M </LI>'
			nuage=$1
			nua=${nuage:0:3}
			if [ "$1" != "TEMPO" ] && [ "$nua" != "SCT" ] && [ "$nua" != "BKN" ] && [ "$nua" != "FEW" ] && [ "$nua" != "CAV" ] && [ "$nua" != "OVC" ] && [ "$nua" != "PRO" ] && [ "$nua" != "BEC" ]
				then
				vent=$1
				degree=${vent:0:3}
				vitmoyen=${vent:3:2}
				rafale=${vent:5:1}
				erreur=${vent:0:1}
				if [ "$degree" = "VRB" ]
					then
					echo >> tafWeb.html '<LI> Wind : Variable @ '$vitmoyen' KT </LI>'
				elif [ "$rafale" = "G" ]
					then
			        rafale=${vent:6:2}
					echo >> tafWeb.html '<LI> Wind : '$degree' @ '$vitmoyen' KT avec rafales a '$rafale' noeuds</LI>'
				elif expr "$erreur" : [0-9] > /dev/null
					then
					echo >> tafWeb.html '<LI> Wind : '$degree' @ '$vitmoyen' KT </LI>'
				fi
				shift
			fi
			nuage=$1
				while [ "${nuage:0:3}" = "SCT" ] || [ "${nuage:0:3}" = "BKN" ] || [ "${nuage:0:3}" = "FEW" ] || [ "${nuage:0:3}" = "CAV" ] || [ "${nuage:0:3}" = "OVC" ] ; do
					ft=${nuage:3:1}
					ft1=${nuage:4:1}
					if [ "$ft" = "0" ]
						then
						if [ "$ft1" = "0" ]
							then
							ft_n=${nuage:5:1}
						else
							ft_n=${nuage:4:2}
						fi
					else
						ft_n=${nuage:3:3}
					fi
					if [ ${nuage:0:3} = "SCT" ]
						then
						echo >> tafWeb.html '<LI> Clouds : scattered @ '$ft_n'00 ft </LI>'
					elif [ ${nuage:0:3} = "BKN" ]
						then
						echo >> tafWeb.html '<LI> Clouds : broken @ '$ft_n'00 ft </LI>'
					elif [ ${nuage:0:3} = "CAV" ]
						then
						echo >> tafWeb.html '<LI> Clouds : OK </LI>'
					elif [ ${nuage:0:3} = "FEW" ]
						then
						echo >> tafWeb.html '<LI> Clouds : few clouds @ '$ft_n'00 ft </LI>'
					elif [ ${nuage:0:3} = "OVC" ]
						then
						echo >> tafWeb.html '<LI> Clouds : Overcast @ '$ft_n'00 ft </LI>'
					fi
				shift
				nuage=$1	
				done
			echo >> tafWeb.html '</UL>'
motTest=$1
		done
	done 
shift
done
done
}

while [ "$1" ] && [ "$1" != "-t" ] ; do
case "$1" in
	"-i")
	init
	shift;;
	"-d")
	download $2
	shift
	shift;;
	"-e") 
	extract $2 "$3"
	shift
	shift
	shift;;
	"-a")
	headerWeb
	analyse
	footerWeb
	shift;;
	"-p")
	download $2
	extract $2 "$3"
	headerWeb
	analyse
	footerWeb
	shift 
	shift
	shift;;
	*) echo "Commande non reconnue" break;
esac
done
if [ "$1" = "-t" ] 
	then
	if [ -e Plan-Vol.html ]
		then 
		rm Plan-Vol.html
	fi
	headerWeb
	while [ "$2" ] ; do
	download $2
	extract $2 "$3"
	analyse 
	shift
	shift
	done
	footerWeb
	mv tafWeb.html Plan-Vol.html
fi
