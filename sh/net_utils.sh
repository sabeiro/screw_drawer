#check port status
port=21
hostA=localhost
case $1 in
	map) #which ports are mapped
		nmap $hostA
		curl $hostA:$port
	;;
	port) #connect to port
		telnet $hostA $port
		netcat -p $port -w 5 $hostA 42
	;;
	proc) #process on port
		lsof -i :$port
		nstat -tln | grep $port
		netstat -ntpl | grep $port
		sudo netstat -tulpn | grep -i listen 
	;;
	ip) #network spec
		nslookup $hostA
	;;
	firewall) #firewall
		sudo ufw status 
		sudo iptables -L
		#sudo ufw enable
		#sudo ufw disable
		#sudo ufw allow ssh
	;;
	network) #hardware
		iconfig -a
	;;
	*)
		echo "net utils"
	;;
#mysql 3306, postgresql 5432, cassandra 7199, mongodb 27017, neo4j 7474, elastic 9300, kibana 5601 
esac
