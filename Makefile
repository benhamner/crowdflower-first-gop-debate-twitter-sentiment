input/Sentiment.csv:
	mkdir -p input
	curl http://cdn2.hubspot.net/hubfs/346378/DFE_CSVs/GOP_REL_ONLY.csv -o input/Sentiment.csv
input: input/Sentiment.csv

output/Sentiment.csv: input/Sentiment.csv
	mkdir -p working
	mkdir -p output
	python src/process.py
csv: output/Sentiment.csv

working/noHeader/Sentiment.csv: output/Sentiment.csv
	mkdir -p working/noHeader
	tail +2 $^ > $@

output/database.sqlite: working/noHeader/Sentiment.csv
	-rm output/database.sqlite
	sqlite3 -echo $@ < working/import.sql
db: output/database.sqlite

output/hashes.txt: output/database.sqlite
	-rm output/hashes.txt
	echo "Current git commit:" >> output/hashes.txt
	git rev-parse HEAD >> output/hashes.txt
	echo "\nCurrent input/ouput md5 hashes:" >> output/hashes.txt
	md5 output/*.csv >> output/hashes.txt
	md5 output/*.sqlite >> output/hashes.txt
	md5 input/*.csv >> output/hashes.txt
hashes: output/hashes.txt

release: output/database.sqlite output/hashes.txt
	zip -r -X output/open-food-facts-release-`date -u +'%Y-%m-%d-%H-%M-%S'` output/*

all: csv db hashes release

clean:
	rm -rf working
	rm -rf output
