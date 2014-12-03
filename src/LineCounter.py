#LineCounter.py by Piero Tofy 2005
#Web: http://www.pierotofy.it

#Utilizzo: copiare questo script nella cartella desiderata e avviarlo con:
#python LineCounter.py Path (Un filtro, ad esempio *.*)
#es: python LineCounter.py *.pas (Analizza tutti i files denominati .pas)


import sys, os, fnmatch

def countLines(File):
        data = open(File,"r").readlines()
        count = 0
        for line in data:
            count += 1
        return count
          

if (__name__ == "__main__"):
    if len(sys.argv) < 2:
        print "Usage: LineCounter.py Path"
        sys.exit(0)

    FilesList = os.listdir(os.getcwd())
    FileCount = 0
    LineCount = 0
    for File in FilesList:
        if os.path.isfile(File) & fnmatch.fnmatch(File,sys.argv[1]):
            LineCount += countLines(File)
            FileCount += 1
    print "Ho analizzato",FileCount,"files e ho contato",LineCount, "righe al loro interno"
    