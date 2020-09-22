import sqlite3
from array import *
from copy import copy, deepcopy
import os
import sys, getopt
import numpy as np
 
from nltk.corpus import words
import enchant
from PyDictionary import PyDictionary

minSize = 3
spellcheckDictionary = enchant.Dict("en_US")
dictionary = PyDictionary()

allWords = set(words.words())
# with open("wordlist.txt") as f:
# 	contents = f.read()
# 	allWords = contents.splitlines()

class DBPuzzle:
	def __init__(self, ringCount, segmentCount, letters, center, words):
		self.ringCount = ringCount
		self.segmentCount = segmentCount
		self.letters = letters
		self.center = center
		self.words = words

	def __str__(self):
		return str({"ringCount": self.ringCount, 
			"segmentCount": self.segmentCount, 
			"letters": self.letters,
			"center": self.center,
			"words": self.words.keys()})

	def allPossibilities(ringIndex, ringCount, segmentCount, rings, centerLetter):
		if ringIndex < 0:
		  return [centerLetter]
		
		result = [];
		p = DBPuzzle.allPossibilities(ringIndex-1, ringCount, segmentCount, rings, centerLetter)
		for s in range(0, segmentCount):
			mirror = int(s + segmentCount / 2) % segmentCount
			ring = rings[ringIndex]
			result = result + list(map(lambda e: ring[s] + e + ring[mirror], p))

		return result;

	def getRandomString(length):
		frequency = {
			'E':	12.02,
			'T':	9.10,
			'A':	8.12,
			'O':	7.68,
			'I':	7.31,
			'N':	6.95,
			'S':	6.28,
			'R':	6.02,
			'H':	5.92,
			'D':	4.32,
			'L':	3.98,
			'U':	2.88,
			'C':	2.71,
			'M':	2.61,
			'F':	2.30,
			'Y':	2.11,
			'W':	2.09,
			'G':	2.03,
			'P':	1.82,
			'B':	1.49,
			'V':	1.11,
			'K':	0.69,
			'X':	0.17,
			'Q':	0.11,
			'J':	0.10,
			'Z':	0.08,
		}

		letters = np.array(list(frequency.keys()))
		distribution = np.array(list(frequency.values()))
		distribution = distribution / distribution.sum()
		return ''.join(np.random.choice(letters, length, p=distribution, replace=True))

	def findWords(words):
		result = dict()
		result = {"AAATESTAAA": {"NOUNTEST" : ["NICENICdfdfE''", "NICENCEIZZdfdfd"] } }
		if len(words) == 0:
			return result

		length = len(words[0])
		center = int(length / 2)
		for size in range(minSize, length): 
			start = center - size + 1 if center >= size else 0
			end = center + 1 if center >= size else length - size + 1
			for i in range(len(words)):
				word = words[i]
				for j in range(start, end):
					s = word[j:j + size].lower()
					if s not in result and spellcheckDictionary.check(s) and s in allWords:
						m = dictionary.meaning(s, disable_errors=True)
						if m != None:
							result[s] = m
		
		return result;

	def randomPuzzle(ringCount, segmentCount, centerLetter=getRandomString(1)):
		rings = [DBPuzzle.getRandomString(segmentCount) for x in range(ringCount)]
		possibleArrangements = DBPuzzle.allPossibilities(ringCount - 1, ringCount, segmentCount, rings, centerLetter);
		words = DBPuzzle.findWords(possibleArrangements);
		return DBPuzzle(ringCount, segmentCount, rings, centerLetter, words);

	def saveToDB(self):
		conn = sqlite3.connect('puzzles.db')
		c = conn.cursor()
		c.execute("INSERT INTO puzzles(ringCount, segmentCount, letters, center) VALUES ({0}, {1}, '{2}', '{3}')".format(p.ringCount, p.segmentCount, ''.join(p.letters), p.center))
		c.execute('SELECT max(id) FROM puzzles')
		id = c.fetchone()[0]
		for word, definitions in self.words.items():
			for pos, defs in definitions.items():
				for d in defs:				
					c.execute("REPLACE INTO definitions(word, pos, definition) VALUES ('{0}', '{1}', \"{2}\")".format(word, pos, d))
			c.execute("INSERT INTO solutions(puzzle, word) VALUES ({0}, '{1}')".format(id, word))
		conn.commit()
		conn.close()

conn = sqlite3.connect('puzzles.db')
c = conn.cursor()
c.execute('''DROP TABLE IF EXISTS puzzles ''')
c.execute('''DROP TABLE IF EXISTS solutions ''')
c.execute('''DROP TABLE IF EXISTS definitions ''')
c.execute('''CREATE TABLE puzzles (id INTEGER PRIMARY KEY AUTOINCREMENT, ringCount INTEGER, segmentCount INTEGER, letters TEXT, center CHAR)''')
c.execute('''CREATE TABLE solutions (puzzle INTEGER, word TEXT, FOREIGN KEY(puzzle) REFERENCES puzzles(id), FOREIGN KEY(word) REFERENCES definitions(word))''')
c.execute('''CREATE TABLE definitions (word TEXT, pos TEXT, definition TEXT, unique(word, definition))''')
conn.commit()


ringCount = 3
segmentCount = 8
centerLetter = None
try:
	opts, args = getopt.getopt(sys.argv[1:], "hr:s:c:", ["ringCount=","segmentCount=","centerLetter="])
except getopt.GetoptError:
	print('{} -r <ringCount> -s <segmentCount>'.format(sys.argv[0]))
	sys.exit(2)
for opt, arg in opts:
	if opt == '-h':
		print('{} -r <ringCount> -s <segmentCount>'.format(sys.argv[0]))
		sys.exit()
	elif opt in ("-r", "--ringCount"):
		ringCount = int(arg)
	elif opt in ("-s", "--segmentCount"):
		segmentCount = int(arg)
	elif opt in ("-c", "--centerLetter"):
		centerLetter = arg

running = True
while running:
	print("Getting puzzle")
	if centerLetter != None:
		p = DBPuzzle.randomPuzzle(ringCount, segmentCount, centerLetter)
	else:
		p = DBPuzzle.randomPuzzle(ringCount, segmentCount)
	if len(p.words) == 0:
		continue
	while True:
		print()
		print(p)
		print('Want to save this? (s)ave / (n)o / (q)uit / (p)rintdb / (r)emove word / (c)heck definition')
		x = input()
		if x.lower() == "s":
			p.saveToDB()
			print("Saved.")
			break
		elif x.lower() == "n":
			print("Okay, skipping that one.")
			break
		elif x.lower() == "q":
			running = False
			print("Bye.")
			break
		elif x.lower() == "p":
			conn = sqlite3.connect('puzzles.db')
			c = conn.cursor()
			for row in c.execute('SELECT * FROM puzzles'):
				print(row)
			print()
			for row in c.execute('SELECT * FROM solutions'):
				print(row)
			print()
			for row in c.execute('SELECT * FROM definitions ORDER BY word'):
				print(row)
			print()
		elif x.lower().startswith("r "):
			r = x[2:]
			if r in p.words:
				del p.words[r]
				print('Removed ' + r)
			else:
				print('Invalid word.')
		elif x.lower().startswith("c "):
			r = x[2:]
			print(dictionary.meaning(r))
		else:
			print('What?')
