
last_id=182
current_id=1

until [ $current_id -gt $last_id ]
do
  curl http://file.fgowiki.fgowiki.com/fgo/head/$(printf "%03d" $current_id).jpg -o ./servant_images/$(printf "%03d" $current_id).jpg
  current_id=$(($current_id+1))
done