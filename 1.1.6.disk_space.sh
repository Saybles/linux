sum_volume=`df -P | awk 'NR>2{sum+=$2}END{print sum}'`
echo $sum_volume kB