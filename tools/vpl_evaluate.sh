#!/bin/bash

cat << EOF > vpl_execution
#!/bin/bash

id=\$(head -n 4 "${VPL_SUBFILE0}" | grep '# id: ' | cut -d' ' -f3)

[[ "\$id" =~ ^[0-9]{6}$ ]] || { echo -e "Comment :=>> Invalid ID in your source file!\nGrade :=>> 0" && exit 1 ; }

wget "https://your-url.here/r-course/\${id}/test.R" -O testme.R

ptsrunning=0
ptstotal=0
ptscorrect=0
while IFS= read -r line;
do
  if [[ "\$line" =~ ^@ERROR@ ]]; then
      echo "Comment :=>> Could not load source file! Often this is an issue with unmatching opened and closed brackets. Did you run your solution successfully on your computer?"
      exit 1
    elif [[ "\$line" =~ ^@START@ ]]; then
      fun=\$(echo \$line | cut -d'@' -f3)
      echo "Comment :=>> Function: '\$fun'"
    elif [[ "\$line" =~ ^@OK@ ]]; then
      what=\$(echo \$line | cut -d'@' -f3)
      echo "Comment :=>> Test OK: '\$what'"
      ptsrunning=\$((ptsrunning+1))
    elif [[ "\$line" =~ ^@FAIL@ ]]; then
      what=\$(echo \$line | cut -d'@' -f3)
      echo "Comment :=>>   Test FAILED: '\$what'"
    elif [[ "\$line" =~ ^@NTESTS@ ]]; then
      n=\$(echo \$line | cut -d'@' -f3)
      ptstotal=\$((ptstotal + n))
      ptscorrect=\$((ptscorrect + ptsrunning))
      echo "Comment :=>> Points: \$ptsrunning / \$n"
      echo "Comment :=>> "
      ptsrunning=0
    elif [[ "\$line" =~ ^@END@ ]]; then
      #~ grade=\$(awk -vn=\$ptscorrect -vall=\$ptstotal  'BEGIN{printf("%.2f\n",n/all*100)}')
      #~ echo "Grade :=>> \$grade"
      echo "Grade :=>> \$ptscorrect"
    fi
done < <( Rscript testme.R "${VPL_SUBFILE0}" )

EOF
chmod +x vpl_execution
./vpl_execution
rm -f vpl_execution testme.R
