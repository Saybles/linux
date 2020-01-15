#!/bin/bash

usd_byr_prev='data-ua-hash="finance.tut.by_main_right_kurs_best_usd"></a><i class="b-icon icon-rate-up" ></i><p>'
usd_byr_after='</p>'
eur_byr_prev='data-ua-hash="finance.tut.by_main_right_kurs_best_eur"></a><i class="b-icon icon-rate-up" ></i><p>'
eur_byr_after='</p>'

get_best_usd_to_byr_convertation() {
    wget https://finance.tut.by/ -q -O - | grep  -o -P "(?<=$usd_byr_prev).*(?=$usd_byr_after)"
}

get_best_eur_to_byr_convertation() {
    wget https://finance.tut.by/ -q -O - | grep  -o -P "(?<=$eur_byr_prev).*(?=$eur_byr_after)"
}

case_choice() {
    ch=$1

    case $ch in
        usd|USD) echo "Best of USD->BYR: " $(get_best_usd_to_byr_convertation)
            ;;
        eur|EUR) echo "Best of EUR->BYR: " $(get_best_eur_to_byr_convertation)
            ;;
        *) echo "Best of USD->BYR: " $(get_best_usd_to_byr_convertation);
           echo "Best of EUR->BYR: " $(get_best_eur_to_byr_convertation);
            ;;
    esac
}


if [ $1 ]; then
    choice=$1
    case_choice $choice
else
    read -p "Enter prefered convertation (USD->BYR: USD/usd, EUR->BYR: EUR/eur, enter to see both):" choice
    case_choice $choice
fi