if
	zenity --question --text="Shutdown?"
then
	shutdown --poweroff now
fi
