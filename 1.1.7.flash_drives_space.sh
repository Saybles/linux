flash_info=`df -P | grep "media"`
sum_volume=`echo $flash_info | awk '{sum+=$2}END{print sum}'`
echo $sum_volume kB