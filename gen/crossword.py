
class Crossword:
	def __init__(self, matrix):
		self.matrix = matrix
		self.rowCount = len(matrix)
		self.colCount = len(matrix[0])

	def __str__(self):
		result = ""
		for row in self.matrix:
			result += ' '.join(row) + os.linesep
		return result;

	def getCrosswords(words):
		# Init the crossword
		w, h = 15, 15;
		crossword = [["_" for x in range(w)] for y in range(h)] 
		words.sort(key=len, reverse=True)

		# Insert first word in the center
		first = words[0]
		start = int(w / 2 - (len(first) / 2))
		for i in range(len(first)):
			crossword[int(h / 2)][start + i] = first[i]

		return [x for x in getAllCrossword(words[1:], crossword) if x.isValid(words)]

	def getAllCrossword(words, crossword):
		# Base case, is no remaining words then just return the one crossword
		if len(words) == 0: 
			return [Crossword(crossword)]

		# Search for a place
		result = []
		word = words[0]
		for rowIndex in range(len(crossword)):
			for colIndex in range(len(crossword[rowIndex])):
				c = crossword[rowIndex][colIndex]

				# Skip empty
				if c == '_': 
					continue

				# Check this word for matches
				for i in range(len(word)):
					# Found a matching character!
					if word[i] == c:
						# Check if there is space horizontally
						if colIndex-i+len(word) < len(crossword[rowIndex]) and all(crossword[rowIndex][colIndex-i+x] == word[x] or crossword[rowIndex][colIndex-i+x] == '_' for x in range(len(word))):
							#print("horizontally")
							newCrossword = deepcopy(crossword)
							for w in range(len(word)):
								newCrossword[rowIndex][colIndex-i+w] = word[w]
							result += getAllCrossword(words[1:], newCrossword)

						# Check if there is space vertically
						if rowIndex-i+len(word) < len(crossword) and all(crossword[rowIndex-i+x][colIndex] == word[x] or crossword[rowIndex-i+x][colIndex] == '_' for x in range(len(word))):
							#print("vertically")
							newCrossword = deepcopy(crossword)
							for w in range(len(word)):
								newCrossword[rowIndex-i+w][colIndex] = word[w]
							result += getAllCrossword(words[1:], newCrossword)
		return result



	def isValid(self, words):
		words.sort(key=len, reverse=True)
		wordSet = set(words)
		foundWords = set()

		# Check that every word is found
		for word in words:
			for rowIndex in range(self.rowCount):
				row = self.getRow(rowIndex)
				rowString = ''.join(row)
				if rowString.find(word) != -1:
					foundWords.add(word)

			for colIndex in range(self.colCount):
				col = self.getCol(colIndex)
				colString = ''.join(col)
				if colString.find(word) != -1:
					foundWords.add(word)

		if len(foundWords) != len(words): 
			return False

		# Check that every string is a valid word
		for rowIndex in range(self.rowCount):
			row = self.getRow(rowIndex)
			rowElements = ''.join(row).split("_")
			for element in rowElements:
				if len(element) > 1 and element not in wordSet:
					return False

		for colIndex in range(self.colCount):
			col = self.getCol(colIndex)
			colElements = ''.join(col).split("_")
			for element in colElements:
				if len(element) > 1 and element not in wordSet:
					return False

		# If it passed everything, then its good to go
		return True

	def getRow(self, index):
		return self.matrix[index]

	def getCol(self, index):
		return [row[index] for row in self.matrix]

	def getHeight(self):
		start = -1
		end = -1
		for rowIndex in range(self.rowCount):
			row = self.getRow(rowIndex)
			if start == -1:
				if any([r != '_' for r in row]):
					start = rowIndex
			elif end == -1:
				if all([r == '_' for r in row]):
					end = rowIndex
			else:
				return end - start
		return self.rowCount

	def getWidth(self):
		start = -1
		end = -1
		for colIndex in range(self.rowCount):
			col = self.getCol(colIndex)
			if start == -1:
				if any([r != '_' for r in col]):
					start = colIndex
			elif end == -1:
				if all([r == '_' for r in col]):
					end = colIndex
			else:
				return end - start
		return self.colCount

	def getAverageDim(self):
		return (self.getHeight() + self.getWidth()) / 2

	def getDistance(self):
		return abs(self.getAverageDim() - self.getHeight()) + abs(self.getAverageDim() - self.getWidth())
