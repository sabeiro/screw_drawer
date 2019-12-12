##%h %l %u %t "%r" %>s %b "%{Referer}i" "%{User-agent}i"
colN=1
fileN=access.log
pageN="guestbook\.html"
#unique user agent
awk -F\" '{print $6}' $fileN | sort | uniq -c | sort -fr

awk -F\" '($6 ~ /Googlebot/){print $2}' $fileN | awk '{print $2}'
awk -v page="$pageN" -F\" '($2 ~ /$page/){print $6}' $fileN
#errors
awk '{print $9}' $fileN | sort | uniq -c | sort
awk '($9 ~ /404/)' $fileN
#hotlinking images
awk -F\" '($2 ~ /\.(jpg|gif)/ && $4 !~ /^http:\/\/www\.example\.net/){print $4}' $fileN | sort | uniq -c | sort
awk '($9 ~ /403/)' $fileN | awk -F\" '($2 ~ /\.(jpg|gif)/){print $4}' | sort | uniq -c | sort
#blank user agent, ip to black list
awk -F\" '($6 ~ /^-?$/)' combined_log | awk '{print $1}' | sort | uniq | logresolve


