cur="$(awk -F'[][]' '/Left:/ { print $2 }' <(amixer sget Master))"
echo ${cur%\%*}
res="$(zenity --scale --text='Lautstärke' --value=${cur%\%*} --min-value='0' --max-value='100' –step='5')"
amixer set Master $res%
