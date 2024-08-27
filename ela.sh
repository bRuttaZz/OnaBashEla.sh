#!/bin/bash

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
UPDATE_INTERVEL=15   # in seconds
GREET_COLORS=( 1 3 5 6)
GREET_COLOR_COUNT=${#GREET_COLORS[@]}

ROWS=0
COLS=0
MIN_ROWS=24
MIN_COLS=62
g_sec_counter=0
g_loop_flag=true


# try to keep the length max to `MIN_COLS-3` chars (otherwise construct a
# function to draw multiline printing (POV: me being lazy))
ONAM_QUOTES=(
    "Uthraadam ucchayaakumpol acchimaarkku veppraalam"
    "Kaanam vittum onam unnanam"
    "Thaali vittum onamunnanam"
    "Onatthinnidayil puttu kacchavadam"
    "Onam undariyanam"
    "Onam kazhinjaal oolappura oottappura"
    "Chinga maasatthile thiruvonanaalil poocchakku vayaru vedana"
)
# keep it under `MIN_COLS-3` char length
AUTHORS_ASSIST=(
    "the ancient relic that just won't go extinct"
    "NB: subjected to market risks"
    "NB: subjected to relationship risks"
    "classic troll for the business-savvy homie /s"
    "onam is a foodie’s festival"
    "a saying that reflects the consumer culture"
    "sometimes it's all about privilege.."
)

# recipe
declare -A RECIPE=(
    ["X"]="banana leaf"
    ["K"]="kichadi"
    ["P"]="pinapple kichadi"
    ["B"]="pachadi"
    ["E"]="ginger curry"
    ["o"]="pappadam"
    ["0"]="rice"
)


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
    char_="X";

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

    head="Ona-Quote"
    tput setaf 7;

    padding=$((  COLS/2 - ${#head}/2 ))
    tput cup $height $padding;
    tput smul; echo -n $head ; tput rmul;

    choice=$(( RANDOM % ${#ONAM_QUOTES[@]} ))
    quote=${ONAM_QUOTES[$choice]}
    padding=$(( (COLS/2 - ${#quote}/2)-1 ))
    if ((${#quote}>=COLS)); then padding=0; fi
    tput cup $(( height + 1)) $padding;
    tput bold; echo -n \"$quote\"; tput sgr0;

    tput setaf 7;
    authors_note="(${AUTHORS_ASSIST[$choice]})"
    padding=$(( (COLS/2 - ${#authors_note}/2) - 1))
    if ((${#authors_note}>=COLS)); then padding=0; fi
    tput cup $(( height + 2)) $padding;
    echo -n $authors_note
    tput setaf 9; tput sgr0;
}

function print_recipe() {     # to show recipe (as you have already guessed)
    # finding max section length
    section_max_len=0
    recipe_item_len="${#RECIPE[@]}"
    section_padding=3
    for recipe in "${!RECIPE[@]}"; do
        rec="${RECIPE[$recipe]}"
        len=$(( ${#rec} + ${#recipe} + 3 + $section_padding))
        if ((len > section_max_len)); then
            section_max_len=$len
        fi
    done

    sections=$(( COLS / section_max_len ))
    section_rows=$(( recipe_item_len / sections ))
    if (( (sections * section_rows) < recipe_item_len )); then
        ((section_rows ++))
    fi

    row=$(( ROWS - section_rows - 3 ))
    col=2
    tput setaf 7;
    tput cup $row 1; iter_chars $((COLS-2)) "─"
    tput cup $row 0; echo -n "┌"
    tput cup $row $COLS; echo -n "┐"
    (( row ++ ))
    tput cup $row $col
    tput smul; tput bold; echo -n "Recipe" ; tput sgr0; tput rmul;
    tput cup $row 0; echo -n "│"
    tput cup $row $COLS; echo -n "│"
    (( row ++ ))

    sec=0
    for recipe in "${!RECIPE[@]}"; do
        tput cup $row $col
        echo -n "$recipe: ${RECIPE[$recipe]}"
        tput cup $row 0; echo -n "│"
        tput cup $row $COLS; echo -n "│"

        (( sec ++))
        if ((sec >= sections)); then
            sec=0
            (( row ++ ))
            col=2
        else
            col=$(( col + section_max_len ))
        fi
    done
    ((row ++))
    tput cup $row 1;  iter_chars $((COLS-2)) "─"
    tput cup $row 0; echo -n "└"
    tput cup $row $COLS; echo -n "┘"

    tput setaf 9; tput sgr0;
}

function window_size_checker() {    # check and throw a warning on windows sizing issues
    if ((ROWS < MIN_ROWS || COLS < MIN_COLS )); then
        >&2 echo -e "\033[0;31mOops! Looks like your terminal grid is too small ($ROWS x $COLS)\033[0m"
        >&2 echo "OnaBashEla.sh requires a minimum of $MIN_ROWS x $MIN_COLS terminal dimention. Try resizing the terminal window :)"
        exit 3
    fi
}

function draw_onaBashEla() {   # draw ona sadhya
    clear;
    tput civis;

    ROWS=$(tput lines)
    COLS=$(tput cols)

    window_size_checker;

    width=39
    padding_left=$((  COLS/2 - width/2 - 11/2 ))
    padding_top=$(( ROWS/2 - 12 ))
    c=$padding_top
    if ((padding_top < 0)); then
        padding_top=0
    fi;
    if ((padding_left < 0)); then
        padding_left=1
    fi;
    padding_init_top=$padding_top

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
    print_recipe;

    # onam quote
    onam_quote $(( padding_top+12 )) ;

    # credit
    msg="[source]"
    msg_="\e]8;;https://github.com/bRuttaZz/OnaBashEla.sh\e\\$msg\e]8;;\e\\"
    tput setaf 7;
    tput cup 0 $((  COLS - ${#msg} - 1))
    echo -e $msg_
    tput setaf 9;


    # wish
    wish="MERRY ONAM!"
    padding=$((  COLS/2 - ${#wish}/2 ))
    while $g_loop_flag; do
        ((g_sec_counter ++))
        if ((g_sec_counter > UPDATE_INTERVEL)); then
            g_sec_counter=0
            break;
        fi
        tput setaf ${GREET_COLORS[$(( g_sec_counter % GREET_COLOR_COUNT ))]}; tput bold;
        tput cup $padding_init_top $padding;
        tput smul; echo -n $wish; tput rmul;

        tput cup 0 1 ; tput sgr0; tput setaf 7;
        echo -n "next quote @ $(( UPDATE_INTERVEL - g_sec_counter ))s  "

        tput setaf 9; tput sgr0;
        sleep 1;
    done;

    # you may wondering why the recursion based rerendering of the whole page..
    # well, I'm adicted to the slow rendering effects of bash script
    g_loop_flag=true
    draw_onaBashEla
}

function main() {
    trap "tput reset; tput cnorm; exit" 2
    trap 'g_loop_flag=false' WINCH
    draw_onaBashEla;
}

# the execution block
main;
