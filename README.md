# FindSimilarPDFs
Traverses the current directory tree and locates similar PDF documents.

Just execute ```./findSimilarPDFs.sh```. The script will report all PDF couples with >30% similarity to the standart output. Also, it will create a ```duplicates.txt``` that lists the similar PDF files, excluding the originals. You can delete these possible duplicates using ```./deleteDuplicates.sh```.
