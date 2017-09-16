
last_id=182
current_id=1
image_id=1

skip_ids=(149 151 152 168)

until [ $current_id -gt $last_id ]
do
  #curl http://fgosimulator.webcrow.jp/Material/i/icon_servants/$current_id.jpg -o ./servant_images_jp/servant-$(printf "%03d" $current_id).jpg
  if [ $image_id -eq 152 ]
  then
    image_id=$(($image_id+1))
  fi
  
  if [ $image_id -eq 176 ]
  then
    #special for 182
    curl http://file.fgowiki.fgowiki.com/fgo/head/$(printf "%03d" 182).jpg -o ./servant_images/servant-$(printf "%03d" 176).jpg
    image_id=$(($image_id+1))
  else
    #normal
    if [[ ! " ${skip_ids[@]} " =~ " ${current_id} " ]]; then
      curl http://file.fgowiki.fgowiki.com/fgo/head/$(printf "%03d" $current_id).jpg -o ./servant_images/servant-$(printf "%03d" $image_id).jpg
      image_id=$(($image_id+1))
    else
      echo skip $current_id
    fi
    current_id=$(($current_id+1))
  fi
  
  
  
done

