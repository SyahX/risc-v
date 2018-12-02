cp ./src/$1.S ../tools/
cd ../tools/
python handle.py $1.S
python data2bin.py $1.data > $1.bin
cp ./$1.data ../test/data/
cd ../test/data/
cp $1.data test.data
