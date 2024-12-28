#!/usr/bin/env zsh

# Displays:
#       Power draw        | Time remaining until battery 0%
#       GPU Power status  | Screen refresh rate
#
# Intended to be displayed by Plasma's command output widget

bat="/sys/class/power_supply/BAT1"

watts=$(awk '{printf("%.2fW", $1*10^-6)}' "$bat/power_now")
cstatus=$(cat "$bat/status")
symbol="-"

if [[ "$cstatus" == "Charging" ]]; then
    symbol="+"
fi


pnow=$(cat "$bat/power_now")
enow=$(cat "$bat/energy_now")

remaining=$(($enow / "$pnow.0"))
remaining_h=$(($remaining|0))
remaining_m_f=$((($remaining - $remaining_h)*60))
remaining_m=$(($remaining_m_f|0))
remaining_m_padded=${(l:2::0:)remaining_m}

gpu_status=$(cat /sys/class/drm/card0/device/power_state)

rrate=$(xrandr | grep '*+' | sed -r -e 's/(^\s+\S+\s+)|([^0-9\.])//g')
rrate_hz=$(printf "%.0fHz" "$rrate")

c1_1="${symbol}${watts}"
c1_2="$remaining_h:$remaining_m_padded"
c2_1="$gpu_status"
c2_2="$rrate_hz"

col1_len=${#c1_1}
col2_len=${#c1_2}

if [[ ${#c2_1} -ge $col1_len ]]; then
    col1_len=${#c2_1}
fi
if [[ ${#c2_2} -ge $col2_len ]]; then
    col2_len=${#c2_2}
fi

col1_pad=$(( (col1_len + 1) / 2))
col2_pad=$(( (col2_len + 1) / 2))


cells=($c1_1 $c1_2 $c2_1 $c2_2)

for ((i = 1; i <= $#cells; i++)); do

    mod=$(( (i - 1) % 2 ))
    target=$col1_len
    if [[ $mod -eq 1 ]]; then
        target=$col2_len
    fi

    s=$cells[$i]

    while (( ${#s} < $target )); do
        s=" $s"
        if [[ ${#s} < $target ]]; then
            s="$s "
        fi
    done

    cells[$i]=$s
done;


line1="$cells[1] | $cells[2]"
line2="$cells[3] | $cells[4]"

echo $line1
echo $line2
