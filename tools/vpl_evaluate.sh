#!/bin/bash
source vpl_environment.sh

id=$(head -n 4 "${VPL_SUBFILE0}" | grep '# id: ' | cut -d' ' -f3)
id=${id//[$'\t\r\n']} # remove leading and trailing newlines/tabs from id

[[ "$id" =~ ^[0-9]{5}$ ]] || { echo -e "Comment :=>> Invalid ID in your source file!\nGrade :=>> 0" && exit 1 ; }

task=$(head -n 4 "${VPL_SUBFILE0}" | grep '# task: ' | cut -d' ' -f3)
task=${task//[$'\t\r\n']} # remove leading and trailing newlines/tabs from task

wget "https://your-url.here/r-course/test/${task}/${id}" -O testme.R

# check if testme.R contains a JSON. in that case, an error occurred retrieving the testfile
python3 -mjson.tool testme.R > /dev/null
[ $? == 0 ] && echo "Comment :=>> error retrieving the test file" && exit 1


ptsrunning=0
ptstotal=0
ptscorrect=0
while IFS= read -r line;
do
  if [[ "$line" =~ ^@ERROR@ ]]; then
      echo "Comment :=>> Could not load source file! Often this is an issue with unmatching opened and closed brackets. Did you run your solution successfully on your computer?"
      exit 1
    elif [[ "$line" =~ ^@START@ ]]; then
      fun=$(echo $line | cut -d'@' -f3)
      echo "Comment :=>> Function: '$fun'"
    elif [[ "$line" =~ ^@OK@ ]]; then
      what=$(echo $line | cut -d'@' -f3)
      echo "Comment :=>> Test OK: '$what'"
      ptsrunning=$((ptsrunning+1))
    elif [[ "$line" =~ ^@FAIL@ ]]; then
      what=$(echo $line | cut -d'@' -f3)
      echo "Comment :=>>   Test FAILED: '$what'"
    elif [[ "$line" =~ ^@NTESTS@ ]]; then
      n=$(echo $line | cut -d'@' -f3)
      ptstotal=$((ptstotal + n))
      ptscorrect=$((ptscorrect + ptsrunning))
      echo "Comment :=>> Points: $ptsrunning / $n"
      echo "Comment :=>> "
      ptsrunning=0
    elif [[ "$line" =~ ^@END@ ]]; then
      #~ grade=\$(awk -vn=\$ptscorrect -vall=\$ptstotal  'BEGIN{printf("%.2f\n",n/all*100)}')
      #~ echo "Grade :=>> \$grade"
      echo "Grade :=>> $ptscorrect"
    fi
done < <( Rscript testme.R "${VPL_SUBFILE0}" )

rm -f testme.R
