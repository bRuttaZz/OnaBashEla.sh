#!/bin/bash
trap "tput reset; tput cnorm; exit" 2


DICTIONARY='
Word dictionary
----------------
thumb   -> often referred to as tip of the leaf `vazha thumb` in malayalam
ela     -> leaf (in this context banana leaf, more like a cut piece of banana lief)
vachaela    -> banana leaf (more descriptive term)
----------------
For tput color codes and detailed docs : https://linuxcommand.org/lc3_adv_tput.php
'

# Globals
UPDATE_INTERVEL=10   # in seconds
GREET_COLORS=( 1 3 5 6)
GREET_COLOR_COUNT=${#GREET_COLORS[@]}

ROWS=0
COLS=0

function update_row_col() {
    ROWS=$(tput lines)
    COLS=$(tput cols)
}
trap 'update_row_col' WINCH

ONAM_QUOTES=(
    "Uthraadam ucchayaakumpol acchimaarkku veppraalam"
    "Kaanam vittum onam unnanam"
    "Thaali vittum onamunnanam"
    "Onatthinnidayil puttu kacchavadam"
    "Onam undariyanam"
    "Onam kazhinjaal oolappura oottappura"
    "Chinga maasatthile thiruvonanaalil poocchakku vayaru vedana"
)
AUTHORS_ASSIST=(
    "the ancient relic that just won't go extinct"
    "NB: subjected to market risks"
    "NB: subjected to relationship risks"
    "classic troll for the business-savvy homie /s"
    "onam is a foodie’s festival"
    "a saying that reflects the consumer culture"
    "sometimes it's all about privilege.."
)

for str in ${ONAM_QUOTES[@]}; do
  echo $str
done


function iter_chars() {         # to draw a character repeatedly
    # loading pos args
    times=${1:-10}
    char=${2:-"*"}
    for (( i=0; i< times; i++ )); do
        echo -n "$char"
    done;
}

function draw_ela() {           # by the way `ela` -> `vazha ela` -> banana leaf
    # loading pos args
    start_padding=${1:-4}
    width=${2:-40};
    height=${3:-10};    # should be even number
    ela_a=${4:-11};  # ela `thumb` semi major axis


    ela_b=$(($height/2));    # ela `thumb` semi minor axis
    char_="x";

    tput setaf 2; tput bold ;   # font settings

    for (( y=0; y <= $height; y++ )); do
        iter_chars $start_padding " ";

        if (( y==height | y==0 )); then
            echo -n " "                         # adding that corner radius
            iter_chars $(( width -1 )) $char_
        else
            iter_chars $width $char_
        fi;

        # for vachaela thumb
        # the distance formula for elipse (i.e, our ela thumb) from minor axis
        # x = a * sqrt(1 - (y^2)/(b^2))
        ext=$(( y - ela_b ));
        dist=$(echo "scale=5;  $ela_a * sqrt( 1 - ($ext ^ 2) / ($ela_b ^ 2) )" | bc -l)
        iter_chars ${dist%.*} $char_;
        # next line
        echo
    done;
    tput setaf 9; tput sgr0;                # reset font
}

function draw_elipse_item() {   # to draw a eliptical object
    # pos args
    left_padding=${1:-10}
    top_padding=${2:-10}
    item_a=${3:-5}      # semi major axis
    item_b=${4:-3}      # semi minor axis
    char=${5:-"*"}
    color=${6:-7}     # color code

    tput setaf $color; tput bold ;   # font settings

    for (( h=0; h<(item_b*2); h++ )); do
        ext=$(( h - item_b ));
        dist=$(echo "scale=5;  $item_a * sqrt( 1 - ($ext ^ 2) / ($item_b ^ 2) )" | bc -l)
        dist=${dist%.*}
        tput cup $(( top_padding + h )) $((left_padding + item_a - dist))
        iter_chars $((dist * 2)) $char
    done

    tput setaf 9; tput sgr0;    # reset font
}

function onam_quote() {         # to draw onam quote
    height=${1:-18}

    head="Ona-Quote:"
    tput setaf 7;

    padding=$((  COLS/2 - ${#head}/2 ))
    tput cup $height $padding;
    tput smul; echo -n $head ; tput rmul;

    choice=$(( RANDOM % ${#ONAM_QUOTES[@]} ))
    quote=${ONAM_QUOTES[$choice]}
    padding=$((  COLS/2 - ${#quote}/2 ))
    tput cup $(( height + 1)) $padding;
    tput bold; echo -n \"$quote\"; tput sgr0;

    tput setaf 7;
    authors_note=${AUTHORS_ASSIST[$choice]}
    padding=$((COLS - ${#authors_note} - 1))
    tput cup $((ROWS-2)) $padding
    echo -n $authors_note
    tput setaf 9; tput sgr0;
}

function recipe_index() {     # prit an index table
    tput setaf 7;
    tput cup $(( ROWS - 9 )) 0
    tput smul; echo -n "Ona sadhya recipe" ; tput rmul;

    tput cup $(( ROWS - 8 )) 0
    echo -ne "x :\tbanana leaf"

    tput cup $(( ROWS - 7 )) 0
    echo -ne "K :\tkichadi"

    tput cup $(( ROWS - 6 )) 0
    echo -ne "P :\tpinapple kichadi"

    tput cup $(( ROWS - 5 )) 0
    echo -ne "B :\tpachadi"

    tput cup $(( ROWS - 4 )) 0
    echo -ne "E :\tginger Curry"

    tput cup $(( ROWS - 3 )) 0
    echo -ne "o :\tpappadam"

    tput cup $(( ROWS - 2 )) 0
    echo -ne "0 :\trice"

    tput setaf 9; tput sgr0;
}

function draw_onaSHadhya() {   # draw ona sadhya
    clear;
    tput civis;

    width=39
    padding_left=$((  COLS/2 - width/2 - 11/2 ))
    padding_top=$(( ROWS/2 - 10 ))
    if ((padding_top < 0)); then
        padding_top=2
    fi;
    if ((padding_left < 0)); then
        padding_left=2
    fi;
    padding_top_top=$(( padding_top -1 ))

    # ela, chor & curry
    (( padding_top ++ ))
    (( padding_top ++ ))
    tput cup $padding_top 0;
    draw_ela $padding_left $width 10;
    draw_elipse_item $((padding_left+8))  $((padding_top+4)) 13 3 0 7 ;    # chor vannu
    draw_elipse_item $((padding_left+6)) $((padding_top+1)) 2 2 K 5 ;     # kichadi
    draw_elipse_item $((padding_left+14)) $((padding_top)) 2 2 P 3 ;    # some yellow curry
    draw_elipse_item $((padding_left+21)) $((padding_top)) 2 2 B 7 ;    # pachadi
    draw_elipse_item $((padding_left+29)) $((padding_top+1)) 2 2 E 1 ;    # ginger curry
    draw_elipse_item $((padding_left+28)) $((padding_top+3)) 6 3 o 3 ;    # pappadam vannu

    # recipe
    recipe_index;

    # onam quote
    onam_quote $(( padding_top+13 )) ;

    # credit
    msg="github.com/bRuttaZz/OnaBashEla.sh"
    msg_="\e]8;;https://github.com/bRuttaZz/OnaBashEla.sh\e\\$msg\e]8;;\e\\"
    tput setaf 7;
    tput cup $ROWS $((  COLS/2 - ${#msg}/2  ))
    echo -e $msg_
    tput setaf 9;


    # wish
    wish="MERRY ONAM!"
    padding=$((  COLS/2 - ${#wish}/2 ))
    for counter in $(seq $UPDATE_INTERVEL); do
        tput setaf ${GREET_COLORS[$(( counter % GREET_COLOR_COUNT ))]}; tput bold;
        tput cup $padding_top_top $padding;
        tput smul; echo -n $wish; tput rmul;

        tput cup 1 1 ; tput sgr0; tput setaf 7;
        echo -n "next quote @ $(( UPDATE_INTERVEL - counter ))s"

        tput setaf 9; tput sgr0;
        sleep 1;
    done;

}

function main() {
    update_row_col
    while true; do
        draw_onaSHadhya;
    done;
}

# the execution block
main;
