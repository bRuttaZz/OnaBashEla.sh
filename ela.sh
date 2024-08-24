#!/bin/bash
trap "tput reset; tput cnorm; exit" 2


DICTIONARY='
Word dictionary
----------------
thumb   -> often referred to as tip of the leaf `vazha thumb` in malayalam
ela     -> leaf (in this context banana leaf, more like a cut piece of banana lief)
vachaela    -> banana leaf (more descriptive term)
'

function iter_chars() {     # to draw a character repeatedly
    # loading pos args
    times=${1:-10}
    char=${2:-"*"}
    for (( i=0; i< times; i++ )); do
        echo -n "$char"
    done;
}

function draw_ela() {     # by the way `ela` -> `vazha ela` -> banana leaf
    # loading pos args
    start_padding=${1:-4}
    height=${2:-10};    # should be even number
    width=${3:-50};
    ela_a=${4:-11};  # ela `thumb` semi major axis

    ela_b=$(($height/2));    # ela `thumb` semi minor axis

    tput setaf 2; tput bold ;   # font settings

    for (( y=0; y <= $height; y++ )); do
        iter_chars $start_padding " ";

        if (( y==height | y==0 )); then
            echo -n " "                         # adding that corner radius
            iter_chars $(( width -1 )) "*"
        else
            iter_chars $width "*"
        fi;

        # for vachaela thumb
        # the distance formula for elipse (i.e, our ela thumb) from minor axis
        # x = a * sqrt(1 - (y^2)/(b^2))
        ext=$(( y - ela_b ));
        dist=$(echo "scale=5;  $ela_a * sqrt( 1 - ($ext ^ 2) / ($ela_b ^ 2) )" | bc -l)
        iter_chars ${dist%.*} "*";
        # next line
        echo
    done;
}

echo
echo

draw_ela 5;

echo
echo
