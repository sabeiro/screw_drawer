CMD_PY="sudo pip install"
reqL=$(grep library $(find . -name "*.R") | awk -F '(' '{print $2}' | sed 's/\([[:punct:]]\)//g' | uniq)
for i in reqL
do
	CDM_PY i
done


