imgName=intertino
srcDir=$HOME/lav/media/
case $1 in
	start)
		docker start $imgName
		docker attach $imgName
	;;
	stop)
		docker stop $imgName
		#docker kill $imgName
	;;
	run)
		docker run -it --name $imgName --privileged -v $srcDir:$srcDir -p 2221:22 -p 8081:80 $imgName /bin/bash #--restart="always" 
	;;
	commit)
		docker commit $(docker ps -a | grep $imgName | awk '{print $1}' ) $imgName
	;;
	port)
		iptables -t nat -A DOCKER -p tcp --dport $LOCALHOSTPORT -j DNAT --to-destination $CONTAINERIP:$PORT
	;;
	save)
		docker save $imgName > $srcDir/docker/$imgName.tar
	;;
	exec)
		docker exec -it $imgName /bin/bash
	;;
	push)
		docker login
		docker push $imgName
		docker logout
	;;
	ps)
		docker ps -a
	;;
	rm)
		docker rm $(docker ps -a | grep $imgName)
	;;
	inspect)
		docker inspect $imgName
	;;
	build)
		docker build -f $srcDir/docker/$imgName.txt
	;;
	on-fly)
		docker run --rm $imgName env
	;;
	*)
		echo "docker utils"
		exit 1
esac
