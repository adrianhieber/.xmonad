vol="$(pactl list sinks | grep '^[[:space:]]Volume:' | \
    head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')"
res="$(zenity --scale --text='Lautstärke' --value=$vol --min-value='0' --max-value='100' –step='5' --title='volume_adjuster')"
pactl set-sink-volume @DEFAULT_SINK@ $res%
