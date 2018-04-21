echo "hello"
yy=$(date +%Y)
mm=$(date +%m)
dd=$(date +%d)
HH=$(date +%H)
MM=$(date +%M)
SS=$(date +%S)

filename="11111"
filepostfix=".md"


cd source/_posts

touch $filename$filepostfix
echo > $filename$filepostfix
echo "---" >> $filename$filepostfix
echo "title: $filename" >> $filename$filepostfix
echo "date: $yy-$mm-$dd $HH:$MM:$SS" >> $filename$filepostfix
echo "tags: [列表,2222,3333,4444]" >> $filename$filepostfix
echo "categories: 5555" >> $filename$filepostfix
echo "toc: true" >> $filename$filepostfix
echo "mathjax: true" >> $filename$filepostfix
echo "---" >> $filename$filepostfix
echo "" >> $filename$filepostfix
echo "<!-- more -->" >> $filename$filepostfix
cd ../..