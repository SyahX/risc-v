cp ./src/$1.S ../tools/
cd ../tools/
python handle.py $1.S
cp ./$1.data ../test/data/
cd ../test/data/
cp $1.data test.data
