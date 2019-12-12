#rsync -urltv --delete -e ssh intertino sabeiro@intertino:/var/www/html/
case 
	git)
		git commit -m "commit $(date) "
		git push origin master
	;;
	svn)

		svn ci script/* -m "automatic update"
		rsync -av -e --delete "ssh -l sabeiro" node sabeiro@intertino:/home/sabeiro/lav/media
	;;
	*)
	;;
esac
rsync -rvz --no-g -e ssh --delete intertino/ intertino:"/var/www/html"
rsync -avz -e ssh --delete rep/ intertino:"/var/www/webdav/report"
rsync -avz -e ssh --delete intertino/tutorial dauvi.org:"/var/www/tutorial"
rsync -avz --exclude ".git/" -e ssh --delete src intertino:"~/lav/media/"
rsync -avz -e ssh --delete raw intertino:"~/lav/media/"
rsync -avz -e ssh --delete out intertino:"~/lav/media/"
rsync -avz -e ssh --delete train intertino:"~/lav/media/"
rsync -avz -e ssh --delete credenza intertino:"~/lav/media/"



