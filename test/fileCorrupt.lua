file.open('filecorruptempty.txt', 'w+')
file.write('something')
file.close()

file.open('filecorrupt.html')
contents = file.read()
file.close()
print(contents)