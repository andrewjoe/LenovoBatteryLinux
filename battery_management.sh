#!/bin/bash

chargelevel=$(cat /sys/class/power_supply/BAT1/capacity)

if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

function charge_to_60 {
if (("$chargelevel" => "60")); then
  echo '\_SB.PCI0.LPCB.EC0.VPC0.SBMC 4' > /proc/acpi/call
  echo "Done, battery charged to $chargelevel"
fi
}

echo "Current charge level: $chargelevel"
echo ==================================
echo "1 Install battery protection mode(Charge level about 55~59%)"
echo "2 Disable battery protection mode(Charge level 100%)"
echo "3 Charge battery to 60% and stop charge"
echo ==================================
echo -n "Choose an action: "
read item
case "$item" in
    1)echo "Installing battery protection mode"
      echo '\_SB.PCI0.LPCB.EC0.VPC0.SBMC 4' > /proc/acpi/call
        ;;
    2)echo "Disabling battery protection mode"
      echo '\_SB.PCI0.LPCB.EC0.VPC0.SBMC 5' > /proc/acpi/call
        ;;
    3)
    if (("$chargelevel" <= "60")); then
      echo "ERROR, battery currently charged over 60%"
      exit
    fi
    echo '\_SB.PCI0.LPCB.EC0.VPC0.SBMC 5' > /proc/acpi/call
    while [ "$loop" = "yes" ]
    do
    charge_to_60
    sleep 1m
    done
        ;;
    *) echo "Noting Entered"
        ;;
esac
