win_moves_in_3=( 1 2 3 4 5 6 7 8 9 1 4 7 2 5 8 3 6 9 1 5 9 3 5 7 )

draw_board(){
    board=( " ${table[0]} | ${table[1]} | ${table[2]}"\
        "---|---|---"\
        " ${table[3]} | ${table[4]} | ${table[5]}"\
        "---|---|---"\
    " ${table[6]} | ${table[7]} | ${table[8]}\n")
    printf "\n"
    for (( i=0; i<5; i++ ));
    do
        echo -e "   ${board[$i]}";
    done
}


check_if_won_or_done(){
    
    won_game=false
    for(( i=0; i<8;i++ ));
    do
        w1="${table[${win_moves_in_3[ 3*${i} ]} - 1]}"
        w2="${table[${win_moves_in_3[ 3*${i}+1 ]} - 1]}"
        w3="${table[${win_moves_in_3[ 3*${i}+2 ]} - 1]}"
        if [ "${w1}" = "${current_player}" ] && [ "${w2}" = "${current_player}" ] && [ "${w3}" = "${current_player}" ]
        then
            won_game=true
            break
        fi
    done
    
    if [[ "${won_game}" == true ]]
    then
        echo "WIN"
    else
        if [[ "${counter}" == "9" ]]
        then
            echo "DRAW"
        else
            echo "CONTINUE"
        fi
    fi
    
    
}

set_move_in_board(){
    if [[ "${current_player}" = "X" ]]
    then
        table[$Field-1]='X'
        next_player='O'
    else
        table[$Field-1]='O'
        next_player='X'
    fi
    draw_board
    
}

move_with_validation(){
    if [[ "${Field}" =~ ^[1-9]$ ]]
    then
        if [[ "${table[${Field}-1]}" =~ ^[1-9]$ ]]
        then
            set_move_in_board
        else
            while [[ ! "${table[${Field}-1]}" =~ ^[1-9]$ ]]
            do
                printf "Already taken - try again!\n"
                read -sn1 Field
            done
            set_move_in_board
            
        fi
    else
        while [[ ! "${Field}" =~ ^[1-9]$ ]]
        do
            printf "Invalid format - try again!\n"
            read -sn1 Field
        done
        set_move_in_board
    fi
    counter=$((counter+1))
}

computer_move_rand(){
    free_fields=()
    for((i=0; i<9; i++))
    do
        if [[ "${table[${i}]}" =~ ^[1-9]$ ]]
        then
            free_fields[${#arrVar[@]}]=$((${i}+1))
        fi
    done
    rand=$(($RANDOM % ${#free_fields[@]}))
    Field=${free_fields[$rand]}
}

moves(){
    while true;
    do
        current_player=${next_player}
        if [ "${user_mode}" = "true" ]
        then
            printf "Player ${current_player} move:\n"
            read -sn1 Field
        else
            if [ "${computer_move}" = "true" ]
            then
                computer_move_rand
                computer_move="false"
            else
                printf "Your move, your are ${next_player}\n"
                read -sn1 Field
                computer_move="true"
            fi
        fi
        move_with_validation
        has_ended=$(check_if_won_or_done)
        if [ "${has_ended}" = "DRAW" ]
        then
            printf " ---------------------------\n"
            printf "Draw!"
            printf "\n ---------------------------\n"
            break
        else
            if [ "${has_ended}" = "WIN" ]
            then
                printf " ---------------------------\n"
                printf "Player ${current_player} Won!"
                printf "\n ---------------------------\n"
                break
            fi
        fi
    done
}

empty_board_init(){
    table=(1 2 3 4 5 6 7 8 9)
    counter=0
    next_player="X"
    draw_board
}

choose_who_first(){
    first_move=$(($RANDOM % 2))
    if [ "${first_move}" = "0" ]
    then
        printf "Computer starts!\n"
        computer_move="true"
    else
        computer_move="false"
    fi
}

game(){
    read -rsn1 Input
    case "$Input" in
        "1")
            empty_board_init
            user_mode="true"
            moves
            
        ;;
        "2")
            empty_board_init
            user_mode="false"
            choose_who_first
            moves
        ;;
        "3")
            { read -a table; read next_player; read user_mode; read counter; read computer_move; } <"$FILE"
            draw_board
            moves
        ;;
    esac
    printf "Thank You! Choose option \n 1. Play with collegue\n 2. Play with computer\n 3. Resume previous game\n"
}

trap_ctrlC() {
    if [ ! "${has_ended}" = "WIN" ] &&  [ ! "${has_ended}" = "DRAW" ] &&  [ ! ${#table[@]} -eq 0 ]
    then
                { echo "${table[*]}"; echo ${next_player}; echo ${user_mode}; echo ${counter}; echo ${computer_move}; } >"$FILE"
                printf "Game saved before closure!\n"
            fi
    exit 1
}

printf "Hello! Choose option \n 1. Play with collegue\n 2. Play with computer\n"
FILE=last_game.txt
if test -f "$FILE"; 
then
    printf " 3. Resume previous game\n"
fi
trap trap_ctrlC INT

while true
do
    game "$@"
    
done

