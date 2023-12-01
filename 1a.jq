# invoke with jq -R -s -f <this file> <input file>

split("\n")					# get lines and put them into a JSON array ("a\nb" -> ["a", "b"])
| map(
	[scan("\\d"; "g")]		# get all digits in each line and put them in an array (["12"] -> [[1, 2]])
	| .[0] + .[-1]			# concatenate first and last digits (["1", "2", "3"] -> "13")
	| tonumber?				# convert to number
	)
| add						# sum all the numbers
