#!/bin/bash

IP_ADDRESS_OUTPUT=$(ip address)
INTERFACE_BLOCKS=($(echo "$IP_ADDRESS_OUTPUT" | awk '/^[0-9]+:/ {print NR}'))

if [ ${#INTERFACE_BLOCKS[@]} -eq 0 ]
then
    echo "No interfaces found."
    exit 1
fi

declare -a INTERFACE_AND_ITS_IP

for i in `seq 0 $((${#INTERFACE_BLOCKS[@]}-1))`
do
    NEXT=$(($i+1))

    if [[ ! -z ${INTERFACE_BLOCKS[$NEXT]} ]]
    then
        RANGE="NR==${INTERFACE_BLOCKS[$i]},NR==${INTERFACE_BLOCKS[$NEXT]}"
    else
        RANGE="NR>=${INTERFACE_BLOCKS[$i]}"
    fi

    CURRENT_BLOCK=$(echo "$IP_ADDRESS_OUTPUT" | awk "$RANGE {print}")
    CURRENT_BLOCK_INTERFACE=$(echo "$CURRENT_BLOCK" | awk 'NR==1 {print $2}')
    CURRENT_BLOCK_IP=$(echo "$CURRENT_BLOCK" | awk '/ inet / {print $2}')

    INTERFACE_AND_ITS_IP[$i]="$CURRENT_BLOCK_INTERFACE $CURRENT_BLOCK_IP"
done

printf "%s\n" "${INTERFACE_AND_ITS_IP[@]}" | sort
