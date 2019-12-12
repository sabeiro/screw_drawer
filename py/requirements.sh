CMD_PY="sudo pip install"
reqL=$(grep import *.py | gawk '{print $2}' | gawk -F "." '{print $1}' | uniq)

for i in reqL
do
	CDM_PY i
done


