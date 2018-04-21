#!/bin/sh

PROGNAME=$(basename $0)
VERSION="1.0"

usage() {
    echo "Usage: $PROGNAME [OPTIONS] FILE"
    echo "  This script is ~."
    echo
    echo "Options:"
    echo "  -h, --help"
    echo "      --version"
    echo "  -i, --input ARG"
    echo "  -o, --output [ARG]"
    echo "  -c, --long-c"
    echo
    exit 1
}

for OPT in "$@"
do
    case "$OPT" in
        '-h'|'--help' )
            usage
            exit 1
            ;;
        '--version' )
            echo $VERSION
            exit 1
            ;;
        '-i'|'--input' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            input="$2"
            shift 2
            ;;
        '-o'|'--output' )
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            output="$2"
            shift 2
            ;;
        '-r'|'--restraint' )
	    R_flag=1
            shift 1
            ;;
        '--'|'-' )
            shift 1
            param+=( "$@" )
            break
            ;;
        -*)
            echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
            exit 1
            ;;
        *)
            if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                #param=( ${param[@]} "$1" )
                param+=( "$1" )
                shift 1
            fi
            ;;
    esac
done

if type gsed 2>/dev/null 1>/dev/null;then
  SED=gsed
else
  SED=sed
fi

# if [ -z $param ]; then
#     echo "$PROGNAME: too few arguments" 1>&2
#     echo "Try '$PROGNAME --help' for more information." 1>&2
#     exit 1
# fi

##################
python ~/apps/acpype.py -p ${input}.top -x ${input}.crd
rm md.mdp em.mdp
if [ ! -e ${input}_GMX.gro ];then
    echo "No ${input}_GMX.gro file. Exit."
    exit 1
fi
mv ${input}_GMX.top ${output}.top
mv ${input}_GMX.gro ${output}.gro
${SED} -i -e "s/  IP  /  Na+ /g" ${output}.top
${SED} -i -e "s/  IM  /  Cl- /g" ${output}.top
${SED} -i -e "s/NA+/Na+/g" ${output}.top
${SED} -i -e "s/NA+/Na+/g" ${output}.gro
${SED} -i -e "s/CL-/Cl-/g" ${output}.top
${SED} -i -e "s/CL-/Cl-/g" ${output}.gro

##insert position restraint files into the top file##
if [ $R_flag ]; then
    echo "insert position restraint files into the top file..."
    #search the second [ moleculetype ] block, or [ system ] block."
    moleculetypearray=()
    moleculetypearray+=(`grep "\[ moleculetype \]" ${output}.top -n | sed -e "s/:\[ moleculetype \]//g"`)
    if [ ${#moleculetypearray[@]} -gt 1 ]; then
      i=${moleculetypearray[1]}
    elif [ ${#moleculetypearray[@]} -eq 1 ]; then
      i=`grep "\[ system \]" ${output}.top -n | sed -e "s/:\[ system \]//g"`
    else
      echo "Not found [ moleculetype ] in ${output}.top"
      exit 1
    fi
    j=`expr ${i} - 1`
    ${SED} -i -e "${j}a ; Include Position restraint file\n#ifdef POSRES1000\n#include \"posre1000.itp\"\n#endif\n#ifdef POSRES500\n#include \"posre500.itp\"\n#endif\n#ifdef POSRES200\n#include \"posre200.itp\"\n#endif\n#ifdef POSRES100\n#include \"posre100.itp\"\n#endif\n#ifdef POSRES50\n#include \"posre50.itp\"\n#endif\n#ifdef POSRES20\n#include \"posre20.itp\"\n#endif\n#ifdef POSRES10\n#include \"posre10.itp\"\n#endif\n#ifdef POSRES0\n#include \"posre0.itp\"\n#endif\n" ${output}.top
    ##end of insertion##
    echo "Done!"

    echo "making position restraints file..."
    perl ~/apps/gen_posre_mori.pl ${output}.gro
    echo "Done!"
fi

##round charges##
echo "Round off to 5 decimal place..."
num=`grep "\[ atoms \]" ${output}.top -n | sed -e 's/:.*//g' | head -1`
bondnum=`grep "\[ bonds \]" ${output}.top -n | sed -e 's/:.*//g' | head -1`
lines=$(( bondnum - num + 1 ))
gawk -v num=${num} -v bondnum=${bondnum} '{if (NR > num && NR < bondnum && $1 !~ ";" && $7 ~ /(^[0-9\.]+$|^-[0-9\.]+$)/){ chg=sprintf("%.5f",$7) ; gsub($7, chg);print } else{ print }}' ${output}.top > ${output}.top.out
mv ${output}.top.out ${output}.top
echo "Done!"
