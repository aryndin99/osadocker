#!/usr/bin/env bash

SUPPORTED_AWK_VERSION="4"

first_line=$(awk --version | head -n 1)

IFS=" " read -r -a first_line_array <<< ${first_line}
main_ver=${first_line_array[2]:0:1}

if (( SUPPORTED_AWK_VERSION > main_ver )); then
    >&2 echo "*****************************************"
    >&2 echo "Awk is not supported. Actual version:" ${full_ver}
    >&2 echo "Supported version:" ${SUPPORTED_AWK_VERSION} "and more"
    >&2 echo "*****************************************"
    exit 1
fi

sed -ue 's/\r//g' | awk -vFPAT='[^,]*|"[^"]*"' 'NR==1{
	for (i=1;i<=NF;i++){
		if (substr($i,0,1)!="\"")
			fields[i]=("\""$i"\"")
		else
			fields[i]=($i)
	};
}
NR>1{
	printf "%s","{ "
	for (i=1;i<=NF;i++){
		if (substr($i,0,1)=="\"")
			v=($i)
		else if (($i)=="true" || ($i)=="false")
			v=($i)
		else if (match($i,"^-?[0-9]+(.[0-9]+)?$"))
			v=($i)
		else
			v=("\""$i"\"")
		printf "%s : %s%s",fields[i],v,(i==NF ? "" : ", ")
	};
	print " }"
}'

