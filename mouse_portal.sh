#!/bin/bash
# mouse_portal.sh
# when mouse cursor reaches final pixel on edge of screen, cursor gets looped to opposite side

# true = on
on_off_toggle=true

check_if_script_already_running () {
    for pid in $(pidof -x mouse_portal.sh); do
        if [ $pid != $$ ]; then
            echo "Exiting, script is already running ($pid)"
            exit 1
        fi
    done
}

check_package_dependencies () {
    command -v xrandr >/dev/null 2>&1 || { echo "Please install xrandr to run this script.">&2; exit 1; }
    command -v xdotool >/dev/null 2>&1 || { echo "Please install xdotool to run this script.">&2; exit 1; }
}    


get_screen_resolution_and_set_vars () {
    Xaxis=$((xrandr --current 2> /dev/null) | grep '* ' | uniq | awk '{print $1}' | cut -d 'x' -f1)
    Yaxis=$((xrandr --current 2> /dev/null) | grep '* ' | uniq | awk '{print $1}' | cut -d 'x' -f2)
    (( Xaxis_minus_one = Xaxis - 1 ))
    (( Xaxis_minus_two = Xaxis - 2 ))
    (( Yaxis_minus_one = Yaxis - 1 ))
    (( Yaxis_minus_two = Yaxis - 2 ))
}

get_current_mouse_coords () {
    eval $(xdotool getmouselocation --shell 2> /dev/null)
    current_x=$X
    current_y=$Y
    return 0
}

move_mouse_if_necessary () {
    case $current_x in
        0) xdotool mousemove $Xaxis_minus_two $current_y;;
        $Xaxis_minus_one) xdotool mousemove 0 $current_y;;
    esac   
    case $current_y in
        # 0) xdotool mousemove $current_x $Yaxis_minus_two;;    #comment this if your panel is at the top
        $Yaxis_minus_one) xdotool mousemove $current_x 0;;     #comment this if your panel is at the bottom
    esac
    return 0
}

check_if_script_already_running
check_package_dependencies
get_screen_resolution_and_set_vars

while $on_off_toggle;
do 
    get_current_mouse_coords
    move_mouse_if_necessary
    sleep 0.1
done
